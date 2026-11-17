import QtQuick
import org.kde.plasma.configuration

ConfigModel {
  ConfigCategory {
    name: "Settings"
    icon: "settings-configure"
    source: "config.qml" /* must be "config.qml" for vallpaper */
  }
}
