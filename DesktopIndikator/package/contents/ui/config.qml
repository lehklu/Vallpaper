import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import QtQuick.Layouts as QTQ_L
import org.kde.kirigami as KDE_kirigami
import org.kde.taskmanager as KDE_taskmanager

KDE_kirigami.Page { id: _Root

  property string cfg_desktopindikator601
  property var desktopSettings: ({})

  function updateDesktopSettings() {
    try {
      desktopSettings = JSON.parse(cfg_desktopindikator601 || "{}")
    } catch (e) {
      desktopSettings = {}
    }
  }

  onCfg_desktopindikator601Changed: updateDesktopSettings()
  QTQ.Component.onCompleted: updateDesktopSettings()

  property int selectedIndex: 0

  KDE_taskmanager.VirtualDesktopInfo {
    id: desktopInfo
  }

  QTQ_L.ColumnLayout {
    anchors.fill: parent
    spacing: KDE_kirigami.Units.largeSpacing

    QTQ_L.RowLayout {
      QTQ_L.Layout.fillWidth: true
      QTQ_L.Layout.fillHeight: true
      spacing: KDE_kirigami.Units.largeSpacing


      KDE_kirigami.InlineMessage {
        QTQ_L.Layout.fillWidth: true
        text: i18n("Configure appearance for each virtual desktop")
        visible: true
      }

      QTQ_C.Button { id: _BtnDonate

        text: 'Donate with PayPal'
        leftPadding: 14
        rightPadding: 14
        topPadding: 8
        bottomPadding: 8
        contentItem: QTQ_C.Label {
          text: _BtnDonate.text
          font.pointSize: parent.font.pointSize * 0.8
          font.bold: true
          color: '#ffffff'
          horizontalAlignment: QTQ.Text.AlignHCenter
          verticalAlignment: QTQ.Text.AlignVCenter
        }
        background: QTQ.Rectangle {
          radius: 4
          color: _BtnDonate.pressed ? '#005a94' : (_BtnDonate.hovered ? '#005ea6' : '#0070ba')
        }
        onClicked: QTQ.Qt.openUrlExternally('https://www.paypal.com/donate/?hosted_button_id=U5UKKNTXNPTLN')
      }
    }

    QTQ_L.RowLayout {
      QTQ_L.Layout.fillWidth: true
      QTQ_L.Layout.fillHeight: true
      spacing: KDE_kirigami.Units.largeSpacing

      // Left side: List of virtual desktops
      QTQ_L.ColumnLayout {
        QTQ_L.Layout.fillWidth: true
        QTQ_L.Layout.fillHeight: true
        QTQ_L.Layout.preferredWidth: parent.width * 0.6
        spacing: KDE_kirigami.Units.largeSpacing

        QTQ.ListView {
          id: listView
          QTQ_L.Layout.fillWidth: true
          QTQ_L.Layout.fillHeight: true
          clip: true
          QTQ_C.ScrollBar.vertical: QTQ_C.ScrollBar { }

          model: desktopInfo.desktopIds.length

          delegate: QTQ_C.ItemDelegate {
            width: listView.width
            highlighted: _Root.selectedIndex === index
            onClicked: _Root.selectedIndex = index

            contentItem: QTQ_L.RowLayout {
              spacing: KDE_kirigami.Units.largeSpacing

              QTQ_C.Label {
                QTQ_L.Layout.preferredWidth: KDE_kirigami.Units.gridUnit * 10
                text: desktopInfo.desktopNames[index] || i18n("Desktop %1", index + 1)
                elide: QTQ.Text.ElideRight
              }

              // Preview of the widget
              QTQ.Rectangle {
                id: previewRect
                QTQ_L.Layout.preferredHeight: KDE_kirigami.Units.gridUnit * 2
                QTQ_L.Layout.preferredWidth: QTQ_L.Layout.preferredHeight * 4
                radius: 2
                clip: true

                property var currentSettings: _Root.desktopSettings[desktopInfo.desktopIds[index]] || {}

                QTQ_L.RowLayout {
                  anchors.fill: parent
                  spacing: 0

                  QTQ.Rectangle {
                    QTQ_L.Layout.fillHeight: true
                    QTQ_L.Layout.preferredWidth: parent.width * 0.75
                    color: previewRect.currentSettings.dayBgColor || "#a0ffa0"

                    QTQ_L.ColumnLayout {
                      anchors.centerIn: parent
                      spacing: 0
                      QTQ_C.Label {
                        text: "Monday"
                        font.family: previewRect.currentSettings.dayFontName || "Inconsolata"
                        font.pointSize: (previewRect.currentSettings.dayFontSize || 12) / 4
                        color: previewRect.currentSettings.dayTextColor || "#000000"
                      }
                      QTQ_C.Label {
                        text: "01.01"
                        font.family: previewRect.currentSettings.dateFontName || "Cantarell"
                        font.pointSize: (previewRect.currentSettings.dateFontSize || 12) / 4
                        color: previewRect.currentSettings.dateTextColor || "#000000"
                      }
                    }
                  }

                  QTQ.Rectangle {
                    QTQ_L.Layout.fillHeight: true
                    QTQ_L.Layout.preferredWidth: parent.width * 0.25
                    color: previewRect.currentSettings.numBgColor || "#000000"

                    QTQ_C.Label {
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

      KDE_kirigami.Separator {
        QTQ_L.Layout.fillHeight: true
      }

      // Right side: Settings
      QTQ_C.ScrollView {
        id: settingsScrollView
        QTQ_L.Layout.fillHeight: true
        QTQ_L.Layout.preferredWidth: parent.width * 0.4
        visible: _Root.selectedIndex !== -1
        clip: true
        QTQ_C.ScrollBar.horizontal.policy: QTQ_C.ScrollBar.AlwaysOff
        QTQ_C.ScrollBar.vertical.policy: QTQ_C.ScrollBar.AsNeeded

        background: QTQ.Rectangle {
          color: KDE_kirigami.Theme.backgroundColor
          QTQ.Rectangle {
            anchors.fill: parent
            color: KDE_kirigami.Theme.highlightColor
            opacity: 0.1
          }
        }

        DesktopSettingsView {
          id: settingsView
          width: settingsScrollView.availableWidth
          desktopId: _Root.selectedIndex !== -1 ? desktopInfo.desktopIds[_Root.selectedIndex] : ""
          desktopName: _Root.selectedIndex !== -1 ? (desktopInfo.desktopNames[_Root.selectedIndex] || i18n("Desktop %1", _Root.selectedIndex + 1)) : ""
          settings: _Root.selectedIndex !== -1 ? (_Root.desktopSettings[desktopId] || {}) : {}

          onDesktopSettingsChanged: (id, newSettings) => {
            let updated = JSON.parse(JSON.stringify(_Root.desktopSettings));
            updated[id] = newSettings;
            _Root.desktopSettings = updated;
            cfg_desktopindikator601 = JSON.stringify(updated);
          }
        }
      }

      QTQ_C.Label {
        QTQ_L.Layout.fillHeight: true
        QTQ_L.Layout.preferredWidth: parent.width * 0.4
        text: i18n("Select a desktop to configure")
        horizontalAlignment: QTQ.Text.AlignLeft
        verticalAlignment: QTQ.Text.AlignVCenter
        visible: _Root.selectedIndex === -1
        leftPadding: KDE_kirigami.Units.largeSpacing
      }
    }
  }
}
