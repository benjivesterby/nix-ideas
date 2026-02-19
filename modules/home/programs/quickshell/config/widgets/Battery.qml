import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../services"

Item {
    id: root
    implicitWidth: row.width // Match visible width exactly to prevent overlap
    height: 60 // Adjust height as needed to fit standard bar width/height

    // Dynamic theme switching: Animated colors
    property color animIconColor: Colors.dark.text
    property color animRedColor: Colors.dark.red
    property color animChargingColor: Colors.dark.base
    // animBoltColor is no longer used for a separate icon, but we keep it if needed or remove it.
    // The user requested monochrome inversion, so we'll strictly use iconColor and chargingColor (background).


    // Hover state handling
    property bool hovered: false

    // UPower integration: Mapping built-in service to UI variables
    readonly property real batteryPercentage: (UPower.displayDevice?.percentage ?? 0) * 100
    readonly property bool isCharging: {
        const state = UPower.displayDevice?.state;
        return state === UPowerDeviceState.Charging || state === UPowerDeviceState.FullyCharged;
    }

    onIsChargingChanged: {
        if (isCharging) {
            PowerProfiles.profile = PowerProfile.Balanced;
        } else {
            PowerProfiles.profile = PowerProfile.PowerSaver;
        }
    }
    
    readonly property string timeEstimate: {
        const device = UPower.displayDevice;
        if (!device) return "";
        if (device.state === UPowerDeviceState.FullyCharged) return "Full";
        
        // Use timeToFull if charging, otherwise fallback to timeToEmpty for discharge/pending
        let seconds = (device.state === UPowerDeviceState.Charging) ? device.timeToFull : device.timeToEmpty;
        
        if (seconds <= 0) return "";
        return durationToText(seconds);
    }

    function durationToText(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        return h + "h " + m + "m";
    }

    readonly property string powerProfileText: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return "Power Saver";
        if (p === PowerProfile.Balanced) return "Balanced";
        if (p === PowerProfile.Performance) return "Performance";
        return "";
    }

    readonly property int profileStepIndex: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return 0;
        if (p === PowerProfile.Balanced) return 1;
        if (p === PowerProfile.Performance) return 2;
        return 1;
    }

    readonly property color activeProfileColor: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return Colors.light.green;
        if (p === PowerProfile.Balanced) return Colors.light.blue;
        if (p === PowerProfile.Performance) return Colors.light.red;
        return Colors.light.subtext0;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background // Constrain hover area to the visual backdrop
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    // Shared backdrop component
    HoverBackdrop {
        id: background
        anchors.top: row.top
        anchors.bottom: row.bottom
        anchors.topMargin: -5
        anchors.bottomMargin: -5
        anchors.right: row.right
        anchors.rightMargin: 6
        anchors.left: row.left
        anchors.leftMargin: 6 // Start symmetric (match right margin for 10px padding)
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: 0
        
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0 // Spacing handled by text container margin
        
        // Stabilize height to prevent jump during animation
        height: Math.max(textContainer.height, iconContainer.height)

        // Percentage, Time, and Profile Selector Container
        Item {
            id: textContainer
            height: Math.max(textColumn.implicitHeight, profileSelector.implicitHeight)
            width: 0 // Start closed
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            
            Row {
                id: expandedContent
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                
                // Power Profile Slider Selector
                Column {
                    id: profileSelector
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    
                    StyledText {
                        text: root.powerProfileText + " Mode"
                        font.pixelSize: 10
                        color: Colors.light.subtext1
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item {
                        width: 90
                        height: 26
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        // Slider Track
                        Rectangle {
                            width: parent.width - 16
                            height: 2
                            color: Colors.light.subtext1
                            opacity: 0.2
                            radius: 1
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 8 // Moved down from center
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Step Markers (Static Dots)
                        Repeater {
                            model: 3
                            Rectangle {
                                width: 4
                                height: 4
                                radius: 2
                                color: Colors.light.subtext1
                                opacity: 0.2
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 8 // Match track offset
                                x: 8 + (index * (parent.width - 16) / 2) - width/2
                            }
                        }

                        // Moving Cursor
                        Rectangle {
                            id: sliderCursor
                            width: 8
                            height: 8
                            radius: 4
                            color: root.activeProfileColor
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 8 // Match track offset
                            x: 8 + (root.profileStepIndex * (parent.width - 16) / 2) - width/2
                            
                            Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }


                        // Profile Steps (Leaf, Scales, Bolt)
                        Item {
                            id: step0
                            width: 30
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            x: 8 - width/2 // Center on first step (x=8)
                            
                            StyledText {
                                text: "" // nf-fa-leaf (uf06c)
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                color: root.profileStepIndex === 0 ? root.activeProfileColor : Colors.light.subtext0
                                opacity: root.profileStepIndex === 0 ? 1.0 : 0.4
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                            }
                        }

                        Item {
                            id: step1
                            width: 30
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            x: 8 + (parent.width - 16)/2 - width/2 // Center on middle step
                            
                            StyledText {
                                text: "⚖"
                                font.pixelSize: 14 // Match leaf size
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                color: root.profileStepIndex === 1 ? root.activeProfileColor : Colors.light.subtext0
                                opacity: root.profileStepIndex === 1 ? 1.0 : 0.4
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: PowerProfiles.profile = PowerProfile.Balanced
                            }
                        }

                        Item {
                            id: step2
                            width: 30
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            x: 8 + (parent.width - 16) - width/2 // Center on last step
                            
                            StyledText {
                                text: ""
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                color: root.profileStepIndex === 2 ? root.activeProfileColor : Colors.light.subtext0
                                opacity: root.profileStepIndex === 2 ? 1.0 : 0.4
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: PowerProfiles.profile = PowerProfile.Performance
                            }
                        }
                    }
                }

                Column {
                    id: textColumn
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    
                    StyledText {
                        id: percentageText
                        text: Math.round(root.batteryPercentage) + "%"
                        font.pixelSize: 20
                        color: Colors.light.text // Light theme text
                        anchors.right: parent.right
                    }
                    
                    StyledText {
                        id: timeText
                        text: root.timeEstimate
                        font.pixelSize: 12
                        color: Colors.light.subtext1
                        anchors.right: parent.right
                        visible: root.timeEstimate !== ""
                    }
                }
            }
        }

        // Battery Icon Container (Fixed width to center icon in the "bar" area)
        Item {
            id: iconContainer
            width: 56 // Standard bar width
            height: 35 // Approx height of body + tip
            anchors.verticalCenter: parent.verticalCenter
            
            // Layout: Row to hold Icon and Bolt side-by-side
            Row {
                anchors.centerIn: parent
                spacing: 4

                // Battery Icon Wrapper
                Item {
                    width: 14 // Width of body
                    height: 35 // Total height (tip + body + margin)
                    
                    // Battery Tip (Top)
                    Rectangle {
                        id: tip
                        width: 6
                        height: 3
                        color: (root.batteryPercentage < 20 && !root.isCharging) ? root.animRedColor : root.animIconColor
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Battery Body (Bottom)
                    Rectangle {
                        id: body
                        width: 14
                        height: 26
                        color: "transparent" // Outline only
                        border.color: (root.batteryPercentage < 20 && !root.isCharging) ? root.animRedColor : root.animIconColor
                        border.width: 2
                        radius: 2
                        anchors.top: tip.bottom
                        anchors.topMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter

                        Shape {
                            anchors.centerIn: parent
                            width: 8
                            height: 18
                            // Remove visible binding to allow fade-out
                            opacity: root.isCharging ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                            
                            ShapePath {
                                strokeWidth: 0
                                fillColor: root.animIconColor // Foreground color
                                joinStyle: ShapePath.MiterJoin
                                capStyle: ShapePath.RoundCap
                                
                                startX: 5; startY: 0
                                PathLine { x: 0; y: 10 }
                                PathLine { x: 3; y: 10 }
                                PathLine { x: 1; y: 18 }
                                PathLine { x: 8; y: 7 }
                                PathLine { x: 4; y: 7 }
                                PathLine { x: 5; y: 0 }
                            }
                        }

                        // Battery Fill
                        Rectangle {
                            id: fillRect
                            width: parent.width - 6
                            // Height proportional to capacity. Max height is parent.height - 6 (approx)
                            height: (parent.height - 6) * (root.batteryPercentage / 100)
                            clip: true // Clip the "Filled" bolt to the fill level

                            color: (root.batteryPercentage < 20 && !root.isCharging) ? root.animRedColor : root.animIconColor
                            radius: 1
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            anchors.horizontalCenter: parent.horizontalCenter

                            // Bolt 2: The "Filled" part (Background Color). Visible inside the fill.
                            // We calculate Y manually because we want it fixed relative to the body (grandparent),
                            // but we are inside fillRect (parent) which moves/resizes.
                            // Body height 26, Bolt height 18. Centered Y in body = 4.
                            // FillRect bottom is at 23 (height-3). Top is at 23 - height.
                            // Relative Y = 4 - (23 - height) = height - 19.
                            Shape {
                                y: parent.height - 19
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 8
                                height: 18
                                // Remove visible binding to allow fade-out
                                opacity: root.isCharging ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 300 } }
                                
                                ShapePath {
                                    strokeWidth: 0
                                    fillColor: root.animChargingColor // Background color (inverted)
                                    joinStyle: ShapePath.MiterJoin
                                    capStyle: ShapePath.RoundCap
                                    
                                    startX: 5; startY: 0
                                    PathLine { x: 0; y: 10 }
                                    PathLine { x: 3; y: 10 }
                                    PathLine { x: 1; y: 18 }
                                    PathLine { x: 8; y: 7 }
                                    PathLine { x: 4; y: 7 }
                                    PathLine { x: 5; y: 0 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "hovered"
            when: root.hovered || Niri.overviewActive
            PropertyChanges {
                target: background
                opacity: 1.0
                anchors.leftMargin: -10 // Expand to cover text with padding
            }
            PropertyChanges {
                target: textContainer
                width: expandedContent.implicitWidth + 15 // Expand for buttons + text + padding
            }
            PropertyChanges {
                target: root
                animIconColor: Colors.light.text
                animRedColor: Colors.light.red
                animChargingColor: Colors.light.base
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            SequentialAnimation {
                // 1. Background appears and colors switch (symmetric) - Smoother fade in
                ParallelAnimation {
                    NumberAnimation { target: background; property: "opacity"; to: 1.0; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animIconColor"; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animRedColor"; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animChargingColor"; duration: 300; easing.type: Easing.OutQuad }
                }
                // 2. Expand text and background left margin together - Smoother expansion
                ParallelAnimation {
                    NumberAnimation { target: textContainer; property: "width"; duration: 300; easing.type: Easing.OutQuad }
                    NumberAnimation { target: background; property: "anchors.leftMargin"; duration: 300; easing.type: Easing.OutQuad }
                }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            SequentialAnimation {
                // 1. Collapse text and restore symmetric margin
                ParallelAnimation {
                    NumberAnimation { target: textContainer; property: "width"; to: 0; duration: 250; easing.type: Easing.InQuad }
                    NumberAnimation { target: background; property: "anchors.leftMargin"; to: 6; duration: 250; easing.type: Easing.InQuad }
                }
                // 2. Background disappears and colors revert
                ParallelAnimation {
                    NumberAnimation { target: background; property: "opacity"; to: 0.0; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animIconColor"; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animRedColor"; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animChargingColor"; duration: 250; easing.type: Easing.InQuad }
                }
            }
        }
    ]
}
