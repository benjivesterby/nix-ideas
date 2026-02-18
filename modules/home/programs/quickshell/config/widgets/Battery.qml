import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "../services"

Item {
    id: root
    implicitWidth: row.width + 20 // Add some padding for the background
    height: 60 // Adjust height as needed to fit standard bar width/height

    // Dynamic theme switching: Animated colors
    property color animIconColor: Colors.dark.text
    property color animRedColor: Colors.dark.red
    property color animChargingColor: Colors.dark.base
    property color animBoltColor: Colors.dark.peach // Light peach on dark background

    // Hover state handling
    property bool hovered: false

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    // Shared backdrop component
    HoverBackdrop {
        id: background
        anchors.top: row.top
        anchors.bottom: row.bottom
        anchors.topMargin: -10
        anchors.bottomMargin: -10
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

        // Percentage and Time Text Container (Clipped for animation)
        Item {
            id: textContainer
            height: textColumn.implicitHeight
            width: 0 // Start closed
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            
            Column {
                id: textColumn
                anchors.right: parent.right
                anchors.rightMargin: 4 // Reduced padding to bring closer to icon
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                
                StyledText {
                    id: percentageText
                    text: Math.round(Power.percentage) + "%"
                    font.pixelSize: 20
                    color: Colors.light.text // Light theme text
                    anchors.right: parent.right
                }
                
                StyledText {
                    id: timeText
                    text: Power.timeEstimate
                    font.pixelSize: 12
                    color: Colors.light.subtext0
                    anchors.right: parent.right
                    visible: Power.timeEstimate !== ""
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
                        color: (Power.percentage < 20 && !Power.isCharging) ? root.animRedColor : root.animIconColor
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Battery Body (Bottom)
                    Rectangle {
                        id: body
                        width: 14
                        height: 26
                        color: "transparent" // Outline only
                        border.color: (Power.percentage < 20 && !Power.isCharging) ? root.animRedColor : root.animIconColor
                        border.width: 2
                        radius: 2
                        anchors.top: tip.bottom
                        anchors.topMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Battery Fill
                        Rectangle {
                            id: fillRect
                            width: parent.width - 6
                            // Height proportional to capacity. Max height is parent.height - 6 (approx)
                            height: (parent.height - 6) * (Power.percentage / 100)
                            color: (Power.percentage < 20 && !Power.isCharging) ? root.animRedColor : root.animIconColor
                            radius: 1
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Charging Bolt (Right Side)
                Shape {
                    width: 8
                    height: 18
                    visible: Power.isCharging
                    anchors.verticalCenter: parent.verticalCenter
                    
                    ShapePath {
                        strokeWidth: 0
                        fillColor: root.animBoltColor
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
                width: textColumn.implicitWidth + 15 // Expand for text + padding
            }
            PropertyChanges {
                target: root
                animIconColor: Colors.light.text
                animRedColor: Colors.light.red
                animChargingColor: Colors.light.base
                animBoltColor: Colors.light.peach // Dark peach on light background
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
                    ColorAnimation { target: root; property: "animBoltColor"; duration: 300; easing.type: Easing.OutQuad }
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
                    ColorAnimation { target: root; property: "animBoltColor"; duration: 250; easing.type: Easing.InQuad }
                }
            }
        }
    ]
}
