import QtQuick
import Quickshell
import "../services"

Item {
    id: root
    // Width adapts to children. Extra padding to ensure backdrop doesn't clip
    implicitWidth: mainRow.width + 20
    height: 60
    
    property bool hovered: false
    
    // Dynamic theme colors (Latte on hover, Catppuccin Macchiato/Dark otherwise)
    property color animTextColor: Colors.dark.text
    property color animSubtextColor: Colors.dark.subtext0
    property color animOverlayColor: Colors.dark.overlay0
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }
    
    // Shared backdrop component
    HoverBackdrop {
        id: backdrop
        anchors.top: mainRow.top
        anchors.bottom: mainRow.bottom
        anchors.topMargin: -10
        anchors.bottomMargin: -10
        anchors.left: mainRow.left
        anchors.leftMargin: 6 
        anchors.right: mainRow.right
        anchors.rightMargin: 6
    }
    
    Row {
        id: mainRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        
        // Clock Column (Always Visible - behaves as the "Icon")
        Item {
            id: clockContainer
            width: 56 // Matches the sidebar standard width
            height: 60
            anchors.verticalCenter: parent.verticalCenter
            
            Column {
                id: clockColumn
                anchors.centerIn: parent
                spacing: -4
                
                StyledText {
                    text: Datetime.hours
                    color: root.animTextColor
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    text: Datetime.minutes
                    color: root.animSubtextColor
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    text: Datetime.seconds
                    color: root.animOverlayColor
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // Date Container (Revealed on hover)
        Item {
            id: dateContainer
            width: 0 // Animated expansion
            height: dateColumn.implicitHeight
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            
            Column {
                id: dateColumn
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                
                StyledText {
                    text: Datetime.date ? Datetime.date.toLocaleDateString(Qt.locale(), "dddd") : ""
                    color: root.animTextColor
                    font.pixelSize: 14
                    font.bold: true
                }
                StyledText {
                    text: Datetime.date ? Datetime.date.toLocaleDateString(Qt.locale(), "d MMMM") : ""
                    color: root.animSubtextColor
                    font.pixelSize: 13
                }

                Row {
                    id: weatherRow
                    spacing: 12
                    anchors.left: parent.left
                    
                    StyledText {
                        text: Weather.icon
                        color: root.animTextColor
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: Math.round(Weather.temp) + "°"
                        color: root.animSubtextColor
                        font.pixelSize: 14
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: " " + Weather.humidity + "%"
                        color: root.animOverlayColor
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
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
                target: backdrop
                opacity: 1.0
                anchors.rightMargin: -10 // Expand to cover revealed text
            }
            PropertyChanges {
                target: dateContainer
                width: dateColumn.implicitWidth + 15
            }
            PropertyChanges {
                target: root
                animTextColor: Colors.light.text
                animSubtextColor: Colors.light.subtext1
                animOverlayColor: Colors.light.subtext0
            }
        }
    ]
    
    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            SequentialAnimation {
                // 1. Fade in backdrop and switch theme colors
                ParallelAnimation {
                    NumberAnimation { target: backdrop; property: "opacity"; to: 1.0; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animTextColor"; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animSubtextColor"; duration: 300; easing.type: Easing.OutQuad }
                    ColorAnimation { target: root; property: "animOverlayColor"; duration: 300; easing.type: Easing.OutQuad }
                }
                // 2. Expand width to reveal date
                ParallelAnimation {
                    NumberAnimation { target: dateContainer; property: "width"; duration: 300; easing.type: Easing.OutQuad }
                    NumberAnimation { target: backdrop; property: "anchors.rightMargin"; duration: 300; easing.type: Easing.OutQuad }
                }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            SequentialAnimation {
                // 1. Collapse width back to icon size
                ParallelAnimation {
                    NumberAnimation { target: dateContainer; property: "width"; to: 0; duration: 250; easing.type: Easing.InQuad }
                    NumberAnimation { target: backdrop; property: "anchors.rightMargin"; to: 6; duration: 250; easing.type: Easing.InQuad }
                }
                // 2. Fade out backdrop and restore dark theme colors
                ParallelAnimation {
                    NumberAnimation { target: backdrop; property: "opacity"; to: 0.0; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animTextColor"; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animSubtextColor"; duration: 250; easing.type: Easing.InQuad }
                    ColorAnimation { target: root; property: "animOverlayColor"; duration: 250; easing.type: Easing.InQuad }
                }
            }
        }
    ]
}
