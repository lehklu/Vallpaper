/*
 *  Copyright 2025  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
  ConfigCategory {
    name: "Settings"
    icon: "settings-configure"
    source: "configSettings.qml"
  }
}
