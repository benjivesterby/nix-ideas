import QtQuick
import QtQuick.Effects
import "../services"

Rectangle {
    id: root
    
    color: Colors.light.base
    radius: 10
    opacity: 0.0
    
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
