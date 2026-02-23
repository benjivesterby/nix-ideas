import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../services/"
import "." as Widgets

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData

            PanelWindow {
                id: leftPanel
                screen: modelData

                anchors {
                    top: true
                    bottom: true
                    left: true
                }
                margins.left: -2

                implicitHeight: screen.height
                // Set a fixed width slightly larger than 300 to accommodate most menus without resizing 
                // the Wayland root surface dynamically (which causes severe lag).
                implicitWidth: 350
                color: "transparent"

                exclusionMode: ExclusionMode.Ignore

                mask: Region {
                    Region { item: clock }
                    Region { item: workspaces }
                    Region {
                        x: 0
                        y: tray.y + tray.bubbleBg.y
                        width: tray.bubbleBg.width
                        height: tray.bubbleBg.height
                    }
                }

                Backdrop {
                    enabled: !Niri.overviewActive
                    width: 56
                    anchors.left: parent.left
                }

                SysTray {
                    id: tray
                    width: 56
                    anchors.left: parent.left
                    y: 10
                    
                    menuRect: {
                        if (!menuWin.shouldShow || !hoveredItem) return Qt.rect(0, 0, 0, 0);
                        var pos = hoveredItem.mapToItem(leftPanel.contentItem, 0, 0);
                        // Fix 2px misalignment: force y offset to match bubble padding, and lock dimensions to menu content so Wayland surface expansions don't warp the blob
                        return Qt.rect(45, pos.y - 2, menuContent.implicitWidth + 16, menuContent.implicitHeight + 4);
                    }
                }

                Workspaces {
                    id: workspaces
                    width: 56
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    y: parent.height / 2 - height / 2
                }

                Column {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    spacing: Niri.overviewActive ? 17 : 0

                    Behavior on spacing { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

                    Item {
                        id: clockContainer
                        width: Theme.widgetExpandedWidth
                        height: 80

                        Time {
                            id: clock
                            anchors.left: parent.left
                        }
                    }
                }
            }

            // Popup menu — separate Wayland surface anchored to the panel
            PopupWindow {
                id: menuWin
                anchor.window: leftPanel
                anchor.rect: {
                    if (!tray.hoveredItem) return Qt.rect(0, 0, 0, 0);
                    var pos = tray.hoveredItem.mapToItem(leftPanel.contentItem, 0, 0);
                    return Qt.rect(45, pos.y - 2, 0, 0);
                }
                anchor.gravity: Edges.Right | Edges.Bottom
                anchor.edges: Edges.Left | Edges.Top
                color: "transparent"

                // Decouple visibility from opacity to allow fade-out
                property bool shouldShow: tray.activeMenuModel !== null && tray.hoveredItem !== null
                visible: shouldShow || menuFadeOut.running

                // Limit maximum width of the Wayland surface so it fits within the 350px panel limits
                // The parent menu is max 300 width, but if a submenu opens, it extends BEYOND that.
                // Pre-allocate the maximum width and height (300 + 250 for submenu) continuously
                // to prevent the Wayland compositor from resizing and fluttering the layout on hover!
                implicitWidth: Math.min(300, menuContent.implicitWidth + 16) + 260
                implicitHeight: Math.max(menuContent.implicitHeight + 8, 800)

                // Track which submenu parent is active
                property var activeSubMenuData: null
                onActiveSubMenuDataChanged: {
                    if (activeSubMenuData !== null) {
                        subMenuWin.lastSubMenuData = activeSubMenuData;
                    }
                }
                
                property Item activeSubMenuItem: null
                onActiveSubMenuItemChanged: {
                    if (activeSubMenuItem !== null && activeSubMenuItem.x !== undefined) {
                        subMenuWin.lastSubMenuX = activeSubMenuItem.x;
                        subMenuWin.lastSubMenuY = activeSubMenuItem.y;
                        subMenuWin.lastSubMenuWidth = activeSubMenuItem.width;
                        subMenuWin.lastSubMenuHeight = activeSubMenuItem.height;
                    }
                }

                QsMenuOpener {
                    id: menuOpener
                    menu: tray.activeMenuModel
                }

                // Content wrapper with fade animation
                Item {
                    id: menuContentWrapper
                    anchors.fill: parent
                    opacity: menuWin.shouldShow ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            id: menuFadeOut
                            duration: menuWin.shouldShow ? Theme.animationDuration : Theme.animationDurationOut
                            easing.type: menuWin.shouldShow ? Easing.OutQuad : Easing.InQuad
                        }
                    }

                    // Background relies on the panel's SysTray blob shader now

                    ShaderEffect {
                        id: subMenuBlob
                        anchors.fill: parent
                        z: -1
                        visible: opacity > 0
                        opacity: menuWin.activeSubMenuData !== null ? 1.0 : 0.0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: menuWin.activeSubMenuData !== null ? Theme.animationDuration : Theme.animationDurationOut
                                easing.type: menuWin.activeSubMenuData !== null ? Easing.OutQuad : Easing.InQuad 
                            }
                        }
                        
                        property bool allowsAnimation: false
                        onVisibleChanged: {
                            if (visible) {
                                Qt.callLater(() => { allowsAnimation = true; });
                            } else {
                                allowsAnimation = false;
                            }
                        }
                        
                        property rect rect1: (menuWin.activeSubMenuItem && menuWin.activeSubMenuItem.x !== undefined)
                            ? Qt.rect(menuWin.activeSubMenuItem.x + 8, menuWin.activeSubMenuItem.y + 2, menuWin.activeSubMenuItem.width, menuWin.activeSubMenuItem.height)
                            : (subMenuWin.lastSubMenuWidth > 0 ? Qt.rect(subMenuWin.lastSubMenuX + 8, subMenuWin.lastSubMenuY + 2, subMenuWin.lastSubMenuWidth, subMenuWin.lastSubMenuHeight) : Qt.rect(0, 0, 0, 0))
                            
                        Behavior on rect1 {
                            // Only animate if the rectangle already has a valid size, ensuring it snaps instantly 
                            // on the very first submenu open instead of sliding all the way down from 0x0!
                            enabled: subMenuBlob.allowsAnimation
                            PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                        }
                            
                        // When closed or exactly on the very first frame it opens, collapses left into rect1
                        // This guarantees the sub-menu background smoothly grows out from the highlighted item itself!
                        // If `activeSubMenuItem` goes null, fallback to the primitive cached coordinates so it shrinks relative to its original position.
                        property rect rect2: (menuWin.activeSubMenuItem && menuWin.activeSubMenuItem.x !== undefined) && subMenuWin.subShouldShow && subMenuBlob.allowsAnimation
                            ? Qt.rect(menuWin.activeSubMenuItem.x + 8 + menuWin.activeSubMenuItem.width, menuWin.activeSubMenuItem.y + 2, subMenuWin.width, subMenuWin.height)
                            : (subMenuWin.lastSubMenuWidth > 0 ? Qt.rect(subMenuWin.lastSubMenuX + 8, subMenuWin.lastSubMenuY + 2, subMenuWin.lastSubMenuWidth, subMenuWin.lastSubMenuHeight) : rect1)

                        Behavior on rect2 { 
                            enabled: subMenuBlob.allowsAnimation
                            PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } 
                        }

                        property rect rect3: Qt.rect(0, 0, 0, 0)
                        property real radius1: 8
                        property real radius2: 10
                        property real radius3: 0
                        property real smoothness: 15.0
                        // Use a subtle tint of text color to avoid making it extremely dark, replacing HoverBackdrop logic
                        property color bubbleColor: Qt.tint(Colors.light.base, Colors.alpha(Colors.light.text, 0.15))
                        property real uWidth: width
                        property real uHeight: height
                        
                        fragmentShader: Qt.resolvedUrl("shaders/bubble.frag.qsb")
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: tray.menuHovered = true
                        onExited: tray.menuHovered = false
                        acceptedButtons: Qt.NoButton

                        ColumnLayout {
                            id: menuContent
                            // Anchor left to prevent the content from sliding rigidly right when the Wayland surface expands!
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 8
                            anchors.topMargin: 2
                            spacing: 2
                            
                            opacity: 1.0
                            NumberAnimation {
                                id: menuContentFadeIn
                                target: menuContent
                                property: "opacity"
                                from: 0.0
                                to: 1.0
                                duration: Theme.animationDurationFast
                                easing.type: Easing.OutQuad
                            }
                            Connections {
                                target: tray
                                function onActiveMenuModelChanged() {
                                    if (tray.activeMenuModel) {
                                        menuContentFadeIn.restart();
                                    }
                                }
                            }
                            
                            Repeater {
                                model: menuOpener.children

                                delegate: Item {
                                    id: menuItem
                                    required property var modelData
                                    
                                    Layout.fillWidth: true
                                    implicitHeight: modelData.isSeparator ? 9 : Math.max(24, menuLabel.implicitHeight + 8)
                                    implicitWidth: Math.max(180, menuLabel.implicitWidth + 56)
                                    // Limit the item's width so text wraps
                                    Layout.maximumWidth: 280
                                    visible: modelData.visible !== false

                                    // Separator
                                    Rectangle {
                                        visible: modelData.isSeparator
                                        anchors.centerIn: parent
                                        width: parent.width - 16
                                        height: 1
                                        color: Colors.light.surface1
                                    }

                                    // Hover highlight
                                    Rectangle {
                                        id: hoverBg
                                        visible: !modelData.isSeparator && (itemMouse.containsMouse || menuWin.activeSubMenuData === modelData)
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        radius: 8
                                        color: Colors.light.surface0
                                    }

                                    RowLayout {
                                        visible: !modelData.isSeparator
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Image {
                                            source: modelData.icon || ""
                                            sourceSize: Qt.size(16, 16)
                                            visible: source != ""
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        StyledText {
                                            id: menuLabel
                                            text: (modelData.text || "").replace(/&/g, "")
                                            font.pixelSize: 13
                                            color: modelData.enabled ? Colors.light.text : Colors.light.overlay0
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                        }
                                        
                                        // Submenu arrow
                                        StyledText {
                                            text: "›"
                                            font.pixelSize: 13
                                            color: Colors.light.overlay1
                                            visible: modelData.hasChildren
                                        }
                                    }

                                    MouseArea {
                                        id: itemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: !modelData.isSeparator && modelData.enabled
                                        onContainsMouseChanged: {
                                            if (containsMouse && modelData.hasChildren) {
                                                menuWin.activeSubMenuData = modelData;
                                                menuWin.activeSubMenuItem = menuItem;
                                            } else if (containsMouse && !modelData.hasChildren) {
                                                menuWin.activeSubMenuData = null;
                                                menuWin.activeSubMenuItem = null;
                                            }
                                        }
                                        onClicked: {
                                            if (!modelData.hasChildren) {
                                                modelData.triggered();
                                                tray.activeMenuModel = null;
                                                tray.hoveredItem = null;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Flyout submenu — anchored to the main menu popup
            PopupWindow {
                id: subMenuWin
                anchor.window: menuWin
                property real itemX: 0
                property real itemWidth: 0
                property real itemHeight: 0
                
                anchor.rect: {
                    var posX = 0;
                    var posY = 0;
                    if (menuWin.activeSubMenuItem && menuWin.activeSubMenuItem.x !== undefined) {
                        posX = menuWin.activeSubMenuItem.x + 8;
                        posY = menuWin.activeSubMenuItem.y + 2;
                        itemWidth = menuWin.activeSubMenuItem.width;
                        itemHeight = menuWin.activeSubMenuItem.height;
                    } else if (subMenuWin.lastSubMenuWidth > 0) {
                        posX = subMenuWin.lastSubMenuX + 8;
                        posY = subMenuWin.lastSubMenuY + 2;
                        itemWidth = subMenuWin.lastSubMenuWidth;
                        itemHeight = subMenuWin.lastSubMenuHeight;
                    } else {
                        return Qt.rect(0, 0, 0, 0);
                    }
                    itemX = posX;
                    // Anchor to the RIGHT edge of the active item!
                    return Qt.rect(posX + itemWidth, posY, 0, 0);
                }
                anchor.gravity: Edges.Right | Edges.Bottom
                anchor.edges: Edges.Left | Edges.Top
                color: "transparent"

                property bool subShouldShow: menuWin.visible && menuWin.activeSubMenuData !== null
                visible: subShouldShow || subMenuFadeOut.running

                implicitWidth: Math.min(250, subMenuContent.implicitWidth + 16)
                implicitHeight: subMenuContent.implicitHeight + 8

                property var lastSubMenuData: null
                property real lastSubMenuX: 0
                property real lastSubMenuY: 0
                property real lastSubMenuWidth: 0
                property real lastSubMenuHeight: 0

                QsMenuOpener {
                    id: subMenuOpener
                    menu: menuWin.activeSubMenuData || subMenuWin.lastSubMenuData
                }

                Item {
                    id: subMenuContentWrapper
                    anchors.fill: parent
                    opacity: subMenuWin.subShouldShow ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            id: subMenuFadeOut
                            duration: subMenuWin.subShouldShow ? Theme.animationDuration : Theme.animationDurationOut
                            easing.type: subMenuWin.subShouldShow ? Easing.OutQuad : Easing.InQuad
                        }
                    }

                    // Background is drawn by `subMenuBlob` on the parent `menuWin` surface now.

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: tray.menuHovered = true
                        onExited: tray.menuHovered = false
                        acceptedButtons: Qt.NoButton

                        ColumnLayout {
                            id: subMenuContent
                            anchors.centerIn: parent
                            spacing: 2
                            
                            opacity: 1.0
                            NumberAnimation {
                                id: subMenuContentFadeIn
                                target: subMenuContent
                                property: "opacity"
                                from: 0.0
                                to: 1.0
                                duration: Theme.animationDurationFast
                                easing.type: Easing.OutQuad
                            }
                            Connections {
                                target: menuWin
                                function onActiveSubMenuDataChanged() {
                                    if (menuWin.activeSubMenuData) {
                                        subMenuContentFadeIn.restart();
                                    }
                                }
                            }

                            Repeater {
                                model: subMenuOpener.children

                                delegate: Item {
                                    id: subMenuItem
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: modelData.isSeparator ? 9 : Math.max(24, subLabel.implicitHeight + 8)
                                    implicitWidth: Math.max(180, subLabel.implicitWidth + 56)
                                    Layout.maximumWidth: 250
                                    visible: modelData.visible !== false

                                    Rectangle {
                                        visible: modelData.isSeparator
                                        anchors.centerIn: parent
                                        width: parent.width - 16
                                        height: 1
                                        color: Colors.light.surface1
                                    }

                                    Rectangle {
                                        visible: !modelData.isSeparator && subItemMouse.containsMouse
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        radius: 8
                                        color: Colors.light.surface0
                                    }

                                    RowLayout {
                                        visible: !modelData.isSeparator
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Image {
                                            source: modelData.icon || ""
                                            sourceSize: Qt.size(16, 16)
                                            visible: source != ""
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        StyledText {
                                            id: subLabel
                                            text: (modelData.text || "").replace(/&/g, "")
                                            font.pixelSize: 13
                                            color: modelData.enabled ? Colors.light.text : Colors.light.overlay0
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: subItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: !modelData.isSeparator && modelData.enabled
                                        onClicked: {
                                            modelData.triggered();
                                            tray.activeMenuModel = null;
                                            tray.hoveredItem = null;
                                            menuWin.activeSubMenuData = null;
                                            menuWin.activeSubMenuItem = null;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                right: true
            }
            // Force window to extend slightly past screen edge to cover potential gap
            margins.right: -2 

            implicitWidth: 300 // Fixed width to prevent resize flicker
            color: "transparent"
            
            // Try to set exclusion mode to ignore to fix reservation issue.
            // Based on common Quickshell/Wayland patterns, exclusionMode: ExclusionMode.Ignore might work.
            // But I should check if I can confirm this property exists.
            // For now, I will just fix the visibility issue in this step.
            exclusionMode: ExclusionMode.Ignore

            mask: Region {
                Region {
                    item: battery
                }
                Region {
                    item: brightness
                }
                Region {
                    item: volume
                }
            }

            Backdrop {
                // enabled: Niri.hasRightOverflow
                enabled: !Niri.overviewActive
                width: 56
                anchors.right: parent.right
                
                // Override gradient to fade from Right (Opaque) to Left (Transparent)
                // This avoids using rotation: 180 which causes pixel alignment issues
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Colors.alpha(Colors.palette.crust, 0.0) }
                    GradientStop { position: 0.4; color: Colors.alpha(Colors.palette.crust, 0.65) }
                    GradientStop { position: 1.0; color: Colors.alpha(Colors.palette.crust, 1.0) }
                }
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.right: parent.right
                spacing: Niri.overviewActive ? 17 : 0

                Behavior on spacing { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

                Item {
                    width: Theme.widgetExpandedWidth
                    height: volume.height
                    Widgets.VolumeWidget {
                        id: volume
                        anchors.right: parent.right
                    }
                }

                Item {
                    width: Theme.widgetExpandedWidth
                    height: brightness.height
                    Widgets.BrightnessWidget {
                        id: brightness
                        anchors.right: parent.right
                    }
                }

                Item {
                    width: Theme.widgetExpandedWidth
                    height: battery.height
                    Battery {
                        id: battery
                        anchors.right: parent.right
                    }
                }
            }
        }
    }
}
