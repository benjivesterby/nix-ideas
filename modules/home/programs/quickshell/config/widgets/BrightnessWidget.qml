import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "../services"
import "../services" as Services

Item {
    id: root
    implicitWidth: row.width
    height: 60

    // Theme colors
    property color animIconColor: Colors.dark.text
    property color animBarColor: Colors.dark.yellow // Using yellow/gold for brightness
    property color animBgColor: Colors.dark.surface0

    readonly property int percentage: Services.Brightness.percentage

    // Combine hover states to prevent widget collapsing when interacting with slider
    property bool hovered: mouseArea.containsMouse || sliderMouseArea.containsMouse

    MouseArea {
        id: mouseArea
        anchors.fill: background
        hoverEnabled: true
        // Removed imperative onEntered/onExited, using binding above
        
        // Scroll to change brightness
        onWheel: (wheel) => {
            let step = 5;
            if (wheel.angleDelta.y < 0) {
                Services.Brightness.setBrightness(Math.max(0, Services.Brightness.percentage - step));
            } else {
                Services.Brightness.setBrightness(Math.min(100, Services.Brightness.percentage + step));
            }
        }
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
        anchors.leftMargin: 6
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        height: Math.max(textContainer.height, iconContainer.height)

        // Text and Slider Container
        Item {
            id: textContainer
            height: Math.max(textColumn.implicitHeight, sliderContainer.implicitHeight)
            width: 0 // Start closed
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            
            Row {
                id: expandedContent
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                // Brightness Slider
                Item {
                    id: sliderContainer
                    width: 100
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter
                    
                    // Track
                    Rectangle {
                        width: parent.width
                        height: 4
                        radius: 2
                        color: Colors.light.subtext1
                        opacity: 0.3
                        anchors.centerIn: parent
                        
                        // Fill
                        Rectangle {
                            width: parent.width * (root.percentage / 100)
                            height: parent.height
                            radius: 2
                            color: root.animBarColor
                        }
                    }
                    
                    // Handle
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root.animBarColor
                        anchors.verticalCenter: parent.verticalCenter
                        x: (parent.width - width) * (root.percentage / 100)
                    }

                    MouseArea {
                        id: sliderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true // Enable to keep widget open
                        onPressed: (mouse) => updateBrightness(mouse)
                        onPositionChanged: (mouse) => {
                            if (pressed) updateBrightness(mouse);
                        }
                        
                        function updateBrightness(mouse) {
                            let val = mouse.x / width * 100;
                            val = Math.max(0, Math.min(100, val));
                            Services.Brightness.setBrightness(Math.round(val));
                        }
                    }
                }

                // Text Column
                Column {
                    id: textColumn
                    anchors.verticalCenter: parent.verticalCenter
                    
                    StyledText {
                        text: root.percentage + "%"
                        font.pixelSize: 20
                        color: Colors.light.text
                        anchors.right: parent.right
                    }
                }
            }
        }

        // Icon Container
        Item {
            id: iconContainer
            width: 56
            height: 35
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: icon
                width: 22 
                height: 22
                anchors.centerIn: parent
                
                // Sun Body (Outline)
                Rectangle {
                    id: sunBody
                    width: 14
                    height: 14
                    radius: 7
                    color: "transparent"
                    border.width: 2
                    border.color: root.animIconColor
                    anchors.centerIn: parent
                    
                    // Sun Fill (Dynamic Opacity)
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2 // Inside the border
                        radius: width / 2
                        color: root.animIconColor
                        opacity: root.percentage / 100
                    }
                }

                // Sun Rays
                Repeater {
                    model: 8
                    Item {
                        width: 22
                        height: 2
                        anchors.centerIn: parent
                        rotation: index * 45
                        
                        Rectangle {
                            width: 3
                            height: 2
                            radius: 1
                            color: root.animIconColor
                            anchors.right: parent.right
                        }
                        
                        Rectangle {
                            width: 3
                            height: 2
                            radius: 1
                            color: root.animIconColor
                            anchors.left: parent.left
                        }
                    }
                }
            }
             
             // Overlay to show "fill" level on the icon? 
             // Maybe a circular progress bar around the sun?
             // For simplicity and matching style, let's just use the text percentage and a static icon that matches the theme.
        }
    }
    
    // States for hover
    states: [
        State {
            name: "hovered"
            when: root.hovered || Niri.overviewActive
            PropertyChanges {
                target: background
                opacity: 1.0
                anchors.leftMargin: -10
            }
            PropertyChanges {
                target: textContainer
                width: expandedContent.implicitWidth + 15
            }
            PropertyChanges {
                target: root
                animIconColor: Colors.light.text
                animBarColor: Colors.light.yellow
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: background; property: "opacity"; to: 1.0; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animIconColor"; duration: 300 }
                    ColorAnimation { target: root; property: "animBarColor"; duration: 300 }
                }
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
                ParallelAnimation {
                    NumberAnimation { target: textContainer; property: "width"; to: 0; duration: 250; easing.type: Easing.InQuad }
                    NumberAnimation { target: background; property: "anchors.leftMargin"; to: 6; duration: 250; easing.type: Easing.InQuad }
                }
                ParallelAnimation {
                    NumberAnimation { target: background; property: "opacity"; to: 0.0; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animIconColor"; duration: 250 }
                    ColorAnimation { target: root; property: "animBarColor"; duration: 250 }
                }
            }
        }
    ]
}
