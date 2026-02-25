import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../services/"
import "." as Widgets

Scope {
    id: root
    property string time

    Component.onCompleted: {
        Quickshell.iconTheme = "Papirus";
    }

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
                // Set a fixed width large enough for expanded tray + menu
                implicitWidth: 650
                color: "transparent"

                exclusionMode: ExclusionMode.Ignore

                mask: Region {
                    Region { item: clock }
                    Region { item: workspaces }
                    Region { item: tray }
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
                    anchors.left: parent.left
                    y: 10
                    
                    menuRect: {
                        if (!mainTrayMenu.shouldShow || !hoveredItem) return Qt.rect(0, 0, 0, 0);
                        var pos = hoveredItem.mapToItem(leftPanel.contentItem, 0, 0);
                        // Increase overlap (248 < 260) for a smoother bridge transition
                        var menuX = tray.expanded ? 248 : 45;
                        // Align perfectly with the tray item top (pos.y) instead of offseting by -2
                        return Qt.rect(menuX, pos.y, mainTrayMenu.baseWidth, mainTrayMenu.baseHeight);
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

            // Replaced manual hardcoded menuWin & subMenuWin with reusable unified TrayMenu
            Widgets.TrayMenu {
                id: mainTrayMenu
                isSubmenu: false
                tray: tray
                sourceItem: tray.hoveredItem
                menuModel: tray.activeMenuModel
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
