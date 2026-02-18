import QtQuick
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
            }

            Backdrop {
                // enabled: Niri.hasRightOverflow
                enabled: true
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

            Battery {
                id: battery
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.right: parent.right
            }
        }
    }
}
