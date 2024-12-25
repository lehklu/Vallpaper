/*
 *  Copyright 2024  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick 2.5

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: "Settings"
         icon: "settings-configure"
         source: "configSettings.qml"
    }
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "configAppearance.qml"
    }
}
