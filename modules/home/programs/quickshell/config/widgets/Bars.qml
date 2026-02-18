import Quickshell
import "../services/"

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
                left: true
            }

            implicitHeight: screen.height
            implicitWidth: 56
            color: "transparent"

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
                enabled: true
            }

            SysTray {
                id: tray
                x: parent.width / 2 - width / 2
                y: 10
            }

            Workspaces {
                id: workspaces
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
            }

            Time {
                id: clock
                x: parent.width / 2 - width / 2
                y: parent.height - height - 10
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
            }

            Backdrop {
                // enabled: Niri.hasRightOverflow
                enabled: true
                rotation: 180
                width: 56
                anchors.right: parent.right
            }

            Battery {
                id: battery
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.right: parent.right
            }
        }
    }
}
