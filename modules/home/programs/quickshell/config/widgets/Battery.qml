import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../services"

Item {
    id: root
    implicitWidth: row.width + 20 // Add some padding for the background
    height: 60 // Adjust height as needed to fit standard bar width/height

    property int capacity: 0
    property string status: "Discharging"
    property bool charging: status == "Charging" || status == "Full" || status == "Not charging" // "Not charging" usually means plugged in but full or threshold
    
    // Dynamic theme switching: Animated colors
    property color animIconColor: Colors.dark.text
    property color animRedColor: Colors.dark.red
    property color animChargingColor: Colors.dark.base

    // Timer to update battery status periodically
    Timer {
        interval: 5000 // 5 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
             capacityProcess.running = true
             statusProcess.running = true
        }
    }

    Process {
        id: capacityProcess
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        stdout: SplitParser {
            onRead: data => root.capacity = parseInt(data.trim())
        }
    }

    Process {
        id: statusProcess
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        stdout: SplitParser {
            onRead: data => root.status = data.trim()
        }
    }

    // Hover state handling
    property bool hovered: false

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    // Background with Shadow
    Rectangle {
        id: background
        anchors.top: row.top
        anchors.bottom: row.bottom
        anchors.topMargin: -10
        anchors.bottomMargin: -10
        anchors.right: row.right
        anchors.rightMargin: 6
        anchors.left: row.left
        anchors.leftMargin: 6 // Start symmetric (match right margin for 10px padding)
        
        color: Colors.light.base // Light theme background
        radius: 10
        opacity: 0.0 // Default invisible
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "black"
            shadowBlur: 1.0
            shadowOpacity: 0.5
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
        }
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: 0
        
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0 // Spacing handled by text container margin

        // Percentage Text Container (Clipped for animation)
        Item {
            id: textContainer
            height: percentageText.implicitHeight
            width: 0 // Start closed
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            
            StyledText {
                id: percentageText
                text: root.capacity + "%"
                font.pixelSize: 20
                color: Colors.light.text // Light theme text
                anchors.right: parent.right
                anchors.rightMargin: 4 // Reduced padding to bring closer to icon
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Battery Icon Container (Fixed width to center icon in the "bar" area)
        Item {
            width: 56 // Standard bar width
            height: 35 // Approx height of body + tip
            
            // Battery Icon Group
            Item {
                width: 24
                height: 35
                anchors.centerIn: parent

                // Battery Tip (Top)
                Rectangle {
                    id: tip
                    width: 6
                    height: 3
                    color: (root.capacity < 20 && !root.charging) ? root.animRedColor : root.animIconColor
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Battery Body (Bottom)
                Rectangle {
                    id: body
                    width: 14
                    height: 26
                    color: "transparent"
                    border.color: (root.capacity < 20 && !root.charging) ? root.animRedColor : root.animIconColor
                    border.width: 2
                    radius: 2
                    anchors.top: tip.bottom
                    anchors.topMargin: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Battery Fill
                    Rectangle {
                        width: parent.width - 6
                        // Height proportional to capacity. Max height is parent.height - 6 (approx)
                        height: (parent.height - 6) * (root.capacity / 100)
                        color: (root.capacity < 20 && !root.charging) ? root.animRedColor : root.animIconColor
                        radius: 1
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    // Charging symbol
                    Text {
                        visible: root.charging
                        text: "⚡"
                        font.pixelSize: 10
                        color: root.animChargingColor
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "hovered"
            when: root.hovered
            PropertyChanges {
                target: background
                opacity: 1.0
                anchors.leftMargin: -10 // Expand to cover text with padding
            }
            PropertyChanges {
                target: textContainer
                width: percentageText.implicitWidth + 15 // Expand for text + padding
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
                // 1. Background appears and colors switch (symmetric)
                ParallelAnimation {
                    NumberAnimation { target: background; property: "opacity"; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animIconColor"; duration: 150; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animRedColor"; duration: 150; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animChargingColor"; duration: 150; easing.type: Easing.OutQuad }
                }
                // 2. Expand text and background left margin together
                ParallelAnimation {
                    NumberAnimation { target: textContainer; property: "width"; duration: 200; easing.type: Easing.OutQuad }
                    NumberAnimation { target: background; property: "anchors.leftMargin"; duration: 200; easing.type: Easing.OutQuad }
                }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            SequentialAnimation {
                // 1. Collapse text and restore symmetric margin
                ParallelAnimation {
                    NumberAnimation { target: textContainer; property: "width"; to: 0; duration: 200; easing.type: Easing.InQuad }
                    NumberAnimation { target: background; property: "anchors.leftMargin"; to: 6; duration: 200; easing.type: Easing.InQuad }
                }
                // 2. Background disappears and colors revert
                ParallelAnimation {
                    NumberAnimation { target: background; property: "opacity"; to: 0.0; duration: 150; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animIconColor"; duration: 150; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animRedColor"; duration: 150; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animChargingColor"; duration: 150; easing.type: Easing.InQuad }
                }
            }
        }
    ]
}
