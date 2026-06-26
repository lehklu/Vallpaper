import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

Kirigami.Page {
    id: page
    
    property string cfg_desktopSettings
    property var desktopSettings: ({})
    
    function updateDesktopSettings() {
        try {
            desktopSettings = JSON.parse(cfg_desktopSettings || "{}")
        } catch (e) {
            desktopSettings = {}
        }
    }

    onCfg_desktopSettingsChanged: updateDesktopSettings()
    Component.onCompleted: updateDesktopSettings()

    property int selectedIndex: 0
    
    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: i18n("Configure appearance for each virtual desktop")
            visible: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.largeSpacing

            // Left side: List of virtual desktops
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.6
                spacing: Kirigami.Units.largeSpacing

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.vertical: ScrollBar { }
                    
                    model: desktopInfo.desktopIds.length
                    
                    delegate: ItemDelegate {
                        width: listView.width
                        highlighted: page.selectedIndex === index
                        onClicked: page.selectedIndex = index

                        contentItem: RowLayout {
                            spacing: Kirigami.Units.largeSpacing

                            Label {
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                                text: desktopInfo.desktopNames[index] || i18n("Desktop %1", index + 1)
                                elide: Text.ElideRight
                            }

                            // Preview of the widget
                            Rectangle {
                                id: previewRect
                                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                                Layout.preferredWidth: Layout.preferredHeight * 4
                                radius: 2
                                clip: true

                                property var currentSettings: page.desktopSettings[desktopInfo.desktopIds[index]] || {}

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width * 0.75
                                        color: previewRect.currentSettings.dayBgColor || "#a0ffa0"

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 0
                                            Label {
                                                text: "Monday"
                                                font.family: previewRect.currentSettings.dayFontName || "Inconsolata"
                                                font.pointSize: (previewRect.currentSettings.dayFontSize || 12) / 4
                                                color: previewRect.currentSettings.dayTextColor || "#000000"
                                            }
                                            Label {
                                                text: "01.01"
                                                font.family: previewRect.currentSettings.dateFontName || "Cantarell"
                                                font.pointSize: (previewRect.currentSettings.dateFontSize || 12) / 4
                                                color: previewRect.currentSettings.dateTextColor || "#000000"
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width * 0.25
                                        color: previewRect.currentSettings.numBgColor || "#000000"

                                        Label {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            font.family: previewRect.currentSettings.numFontName || "Cantarell"
                                            font.pointSize: (previewRect.currentSettings.numFontSize || 18) / 4
                                            color: previewRect.currentSettings.numTextColor || "#a0ffa0"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillHeight: true
            }

            // Right side: Settings
            ScrollView {
                id: settingsScrollView
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.4
                visible: page.selectedIndex !== -1
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
            
                background: Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    Rectangle {
                        anchors.fill: parent
                        color: Kirigami.Theme.highlightColor
                        opacity: 0.1
                    }
                }

                DesktopSettingsView {
                    id: settingsView
                    width: settingsScrollView.availableWidth
                    desktopId: page.selectedIndex !== -1 ? desktopInfo.desktopIds[page.selectedIndex] : ""
                    desktopName: page.selectedIndex !== -1 ? (desktopInfo.desktopNames[page.selectedIndex] || i18n("Desktop %1", page.selectedIndex + 1)) : ""
                    settings: page.selectedIndex !== -1 ? (page.desktopSettings[desktopId] || {}) : {}

                    onDesktopSettingsChanged: (id, newSettings) => {
                        let updated = JSON.parse(JSON.stringify(page.desktopSettings));
                        updated[id] = newSettings;
                        page.desktopSettings = updated;
                        cfg_desktopSettings = JSON.stringify(updated);
                    }
                }
            }

            Label {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.4
                text: i18n("Select a desktop to configure")
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                visible: page.selectedIndex === -1
                leftPadding: Kirigami.Units.largeSpacing
            }
        }
    }
}
