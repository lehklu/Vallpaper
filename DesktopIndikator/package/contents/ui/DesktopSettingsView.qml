import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing
    
    property string desktopId
    property string desktopName
    property var settings: ({})
    
    signal desktopSettingsChanged(string id, var newSettings)

    property string targetFontKey: ""
    property string targetColorKey: ""

    FontDialog {
        id: fontDialog
        onAccepted: {
            if (targetFontKey !== "") {
                let baseKey = targetFontKey.replace("FontName", "");
                updateSettings({
                    [baseKey + "FontName"]: fontDialog.selectedFont.family,
                    [baseKey + "FontSize"]: fontDialog.selectedFont.pointSize
                });
            }
        }
    }

    ColorDialog {
        id: colorDialog
        onAccepted: {
            if (targetColorKey !== "") {
                updateSetting(targetColorKey, colorDialog.selectedColor.toString())
            }
        }
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        wideMode: true

        // Day Text Settings
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Day Text")
            Kirigami.FormData.isSection: true
        }
        Button {
            Kirigami.FormData.label: i18n("Font")
            text: (settings.dayFontName || "Inconsolata") + ", " + (settings.dayFontSize || 12)
            font.family: settings.dayFontName || "Inconsolata"
            font.pointSize: settings.dayFontSize || 12
            onClicked: {
                root.targetFontKey = "dayFontName";
                fontDialog.selectedFont = Qt.font({
                    family: settings.dayFontName || "Inconsolata",
                    pointSize: settings.dayFontSize || 12
                });
                fontDialog.open();
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Text Color")
            spacing: Kirigami.Units.smallSpacing

            Button {
                padding: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                background: Rectangle {
                    radius: 2
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    color: settings.dayTextColor || "#000000"
                }

                onClicked: {
                    root.targetColorKey = "dayTextColor";
                    colorDialog.selectedColor = settings.dayTextColor || "#000000";
                    colorDialog.open();
                }
            }

            TextField {
                id: dayTextColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: settings.dayTextColor || "#000000"
                placeholderText: "#000000"
                onEditingFinished: updateSetting("dayTextColor", text)
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Background Color")
            spacing: Kirigami.Units.smallSpacing

            Button {
                padding: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                background: Rectangle {
                    radius: 2
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    color: settings.dayBgColor || "#a0ffa0"
                }

                onClicked: {
                    root.targetColorKey = "dayBgColor";
                    colorDialog.selectedColor = settings.dayBgColor || "#a0ffa0";
                    colorDialog.open();
                }
            }

            TextField {
                id: dayBgColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: settings.dayBgColor || "#a0ffa0"
                placeholderText: "#a0ffa0"
                onEditingFinished: updateSetting("dayBgColor", text)
            }
        }

        // Date Text Settings
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Date Text")
            Kirigami.FormData.isSection: true
        }
        Button {
            Kirigami.FormData.label: i18n("Font")
            text: (settings.dateFontName || "Cantarell") + ", " + (settings.dateFontSize || 12)
            font.family: settings.dateFontName || "Cantarell"
            font.pointSize: settings.dateFontSize || 12
            onClicked: {
                root.targetFontKey = "dateFontName";
                fontDialog.selectedFont = Qt.font({
                    family: settings.dateFontName || "Cantarell",
                    pointSize: settings.dateFontSize || 12
                });
                fontDialog.open();
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Text Color")
            spacing: Kirigami.Units.smallSpacing

            Button {
                padding: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                background: Rectangle {
                    radius: 2
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    color: settings.dateTextColor || "#000000"
                }

                onClicked: {
                    root.targetColorKey = "dateTextColor";
                    colorDialog.selectedColor = settings.dateTextColor || "#000000";
                    colorDialog.open();
                }
            }

            TextField {
                id: dateTextColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: settings.dateTextColor || "#000000"
                placeholderText: "#000000"
                onEditingFinished: updateSetting("dateTextColor", text)
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Background Color")
            spacing: Kirigami.Units.smallSpacing

            Button {
                padding: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                background: Rectangle {
                    radius: 2
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    color: settings.dateBgColor || "transparent"
                }

                onClicked: {
                    root.targetColorKey = "dateBgColor";
                    colorDialog.selectedColor = settings.dateBgColor || "transparent";
                    colorDialog.open();
                }
            }

            TextField {
                id: dateBgColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: settings.dateBgColor || "transparent"
                placeholderText: "transparent"
                onEditingFinished: updateSetting("dateBgColor", text)
            }
        }

        // Desktop Number Settings
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Desktop Number")
            Kirigami.FormData.isSection: true
        }
        Button {
            Kirigami.FormData.label: i18n("Font")
            text: (settings.numFontName || "Cantarell") + ", " + (settings.numFontSize || 18)
            font.family: settings.numFontName || "Cantarell"
            font.pointSize: settings.numFontSize || 18
            onClicked: {
                root.targetFontKey = "numFontName";
                fontDialog.selectedFont = Qt.font({
                    family: settings.numFontName || "Cantarell",
                    pointSize: settings.numFontSize || 18
                });
                fontDialog.open();
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Text Color")
            spacing: Kirigami.Units.smallSpacing

            Button {
                padding: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                background: Rectangle {
                    radius: 2
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    color: settings.numTextColor || "#a0ffa0"
                }

                onClicked: {
                    root.targetColorKey = "numTextColor";
                    colorDialog.selectedColor = settings.numTextColor || "#a0ffa0";
                    colorDialog.open();
                }
            }

            TextField {
                id: numTextColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: settings.numTextColor || "#a0ffa0"
                placeholderText: "#a0ffa0"
                onEditingFinished: updateSetting("numTextColor", text)
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Background Color")
            spacing: Kirigami.Units.smallSpacing

            Button {
                padding: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

                background: Rectangle {
                    radius: 2
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    color: settings.numBgColor || "#000000"
                }

                onClicked: {
                    root.targetColorKey = "numBgColor";
                    colorDialog.selectedColor = settings.numBgColor || "#000000";
                    colorDialog.open();
                }
            }

            TextField {
                id: numBgColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: settings.numBgColor || "#000000"
                placeholderText: "#000000"
                onEditingFinished: updateSetting("numBgColor", text)
            }
        }
    }
    
    function updateSetting(key, value) {
        let obj = {};
        obj[key] = value;
        updateSettings(obj);
    }

    function updateSettings(newKeyValues) {
        if (!desktopId) return;
        let newSettings = JSON.parse(JSON.stringify(settings));
        for (let key in newKeyValues) {
            newSettings[key] = newKeyValues[key];
        }
        desktopSettingsChanged(desktopId, newSettings);
    }
}
