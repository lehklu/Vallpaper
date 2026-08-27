import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nc("@title:group", "Appearance")
        icon: "preferences-desktop-color"
        source: "../config/main.qml"
    }
}
