import QtQuick
import Quickshell
import "../services/"
import "." as Widgets

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
            }
            // Force window to extend slightly past screen edge for consistency
            margins.left: -2

            implicitHeight: screen.height
            implicitWidth: 300 // Expanded width to prevent cropping
            color: "transparent"

            exclusionMode: ExclusionMode.Ignore

            mask: Region {
                Region {
                    item: clock
                }
                Region {
                    item: workspaces
                }
                Region {
                    item: tray
                }
            }

            Backdrop {
                // enabled: Niri.hasLeftOverflow
                enabled: !Niri.overviewActive
                width: 56
                anchors.left: parent.left
            }

            SysTray {
                id: tray
                width: 56
                anchors.left: parent.left
                anchors.leftMargin: 0
                y: 10
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

                Behavior on spacing { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

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

                Behavior on spacing { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

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
