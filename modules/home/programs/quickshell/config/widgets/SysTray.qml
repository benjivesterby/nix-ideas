import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import "../services"

Item {
    id: root
    implicitWidth: 56
    implicitHeight: trayLayout.implicitHeight

    property var hoveredItem: null
    property var activeMenuModel: null
    property alias bubbleBg: bubbleBackground
    
    // Remember the last hovered item so we can animate from/to its center
    // when transitioning from/to the completely unhovered state
    property var lastHoveredItem: null
    
    // Unified hover state
    property bool iconHovered: false
    property bool menuHovered: false
    readonly property bool isHovered: iconHovered || menuHovered

    // No active logs in production

    Timer {
        id: closeTimer
        interval: 300
        running: !root.isHovered && root.activeMenuModel !== null
        onTriggered: {
            root.hoveredItem = null;
            root.activeMenuModel = null;
        }
    }

    // Menu popup dimensions (set from Bars.qml)
    property rect menuRect: Qt.rect(0, 0, 0, 0)

    ShaderEffect {
        id: bubbleBackground
        
        // Dynamically expand the shader bounds to cover both the tray icons and the menu
        property real minY: root.menuRect.width > 0 ? Math.min(0, root.menuRect.y - tray.y - 12) : 0
        property real maxY: root.menuRect.width > 0 ? Math.max(parent.height, root.menuRect.y - tray.y + root.menuRect.height + 12) : parent.height
        
        Behavior on minY { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        Behavior on maxY { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        
        x: 0
        y: minY
        width: root.menuRect.width > 0 ? 56 + root.menuRect.x + root.menuRect.width - tray.x + 12 : 56
        Behavior on width { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        
        height: maxY - minY
        z: -1
        visible: opacity > 0

        // Active item is only the currently hovered item, or the last one if we are fading out
        // BUT if we are completely invisible (opacity == 0), we want the bubble to snap to the NEW
        // item immediately without transitioning from the vastly outdated `lastHoveredItem`.
        property var activeItem: root.hoveredItem || root.lastHoveredItem
        property rect rect1: activeItem
            ? (root.hoveredItem || opacity > 0
                ? Qt.rect(activeItem.x - 2, activeItem.y - 2 - minY,
                          activeItem.width + 4, activeItem.height + 4)
                : Qt.rect(activeItem.x + activeItem.width / 2, activeItem.y + activeItem.height / 2 - minY, 0, 0))
            : Qt.rect(0, 0, 0, 0)
            
        Behavior on rect1 {
            enabled: bubbleBackground.opacity > 0.01
            PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
        }
            
        // When menu is closed, rect2 = rect1 so it smoothly grows out of/into the icon
        property rect rect2: root.menuRect.width > 0
            ? Qt.rect(root.menuRect.x - tray.x, root.menuRect.y - tray.y - minY,
                      root.menuRect.width, root.menuRect.height)
            : rect1
        property rect rect3: Qt.rect(0, 0, 0, 0)
        property real radius1: 10
        property real radius2: 10
        property real radius3: 14
        property real smoothness: 15.0
        property color bubbleColor: Colors.light.base
        property real uWidth: bubbleBackground.width
        property real uHeight: bubbleBackground.height

        Behavior on rect2 {
            enabled: bubbleBackground.opacity > 0.01
            PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
        }

        opacity: root.hoveredItem ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: root.hoveredItem ? Theme.animationDuration : Theme.animationDurationOut; easing.type: root.hoveredItem ? Easing.OutQuad : Easing.InQuad } }

        fragmentShader: Qt.resolvedUrl("shaders/bubble.frag.qsb")
    }

    ColumnLayout {
        id: trayLayout
        x: 0
        width: 56
        spacing: 1

        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: itemRoot
                required property SystemTrayItem modelData

                Layout.alignment: Qt.AlignCenter
                width: 24
                height: 24

                Image {
                    anchors.centerIn: parent
                    source: itemRoot.modelData.icon
                    sourceSize.width: 16
                    sourceSize.height: 16
                    smooth: true

                    layer.enabled: root.hoveredItem === itemRoot
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: Colors.light.text
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onEntered: {
                        root.iconHovered = true;
                        if (bubbleBackground.opacity === 0) {
                            // If completely hidden, update lastHoveredItem first to instantly snap there
                            // before the opacity animation re-enables the slide behavior from a stale position.
                            root.lastHoveredItem = itemRoot;
                        }
                        root.hoveredItem = itemRoot;
                        root.activeMenuModel = itemRoot.modelData.menu ?? null;
                    }
                    onExited: {
                        root.iconHovered = false;
                    }
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) itemRoot.modelData.activate();
                        else if (mouse.button === Qt.RightButton) itemRoot.modelData.contextMenu();
                        else if (mouse.button === Qt.MiddleButton) itemRoot.modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}
