pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property double percentage: 0
    property bool isCharging: false
    property string timeEstimate: ""
    property string statusText: ""

    // Initial fetch
    Component.onCompleted: refresh()

    // Monitor for changes
    Process {
        id: monitor
        command: ["upower", "--monitor"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                // Any change to any power device triggers a refresh
                if (line.includes("battery_BAT0") || line.includes("line_power")) {
                    root.refresh()
                }
            }
        }
    }

    function refresh() {
        batteryInfo.running = true
    }

    Process {
        id: batteryInfo
        command: ["upower", "-i", "/org/freedesktop/UPower/devices/battery_BAT0"]
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(":");
                if (parts.length < 2) return;
                
                const key = parts[0].trim();
                const value = parts[1].trim();
                
                if (key === "percentage") {
                    root.percentage = parseFloat(value);
                } else if (key === "state") {
                    root.isCharging = (value === "charging" || value === "fully-charged");
                    root.statusText = value;
                } else if (key === "time to empty" || key === "time to full") {
                    const valStr = value.split(" ")[0].replace(",", ".");
                    const val = parseFloat(valStr);
                    if (!isNaN(val)) {
                        const h = Math.floor(val);
                        const m = Math.floor((val - h) * 60);
                        root.timeEstimate = h + "h " + m + "m";
                    } else {
                        root.timeEstimate = value;
                    }
                } else if (root.statusText === "fully-charged") {
                    root.timeEstimate = "Full";
                }
            }
        }
    }
}
