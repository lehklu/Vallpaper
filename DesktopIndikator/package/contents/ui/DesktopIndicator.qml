/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick as QTQ
import QtQuick.Controls as QTQ_C
import org.kde.kirigami as Kirigami

import "../js/v.js" as VJS

QTQ.Item {
  id: _Root

  clip: true

  property int desktopNo: 1
  property string desktopName: qsTr("Desktop")
  property date currentDate: new Date()
  property bool interactive: false

  property real heightWidthRatio: 50

  property int sectionDateWidthWeight: 50
  property int sectionDesktopNameWidthWeight: 50
  property int sectionDesktopNumberWidthWeight: 50

  property string sectionOrder: "date,desktopName,desktopNumber"

  function sectionOrderIndex(section, fallback) {
    return VJS.sectionOrderIndex(_Root.sectionOrder, section, fallback)
  }

  readonly property int dateSectionOrder: sectionOrderIndex("date", 0)
  readonly property int nameSectionOrder: sectionOrderIndex("desktopName", 1)
  readonly property int sectionDesktopNumberOrder: sectionOrderIndex("desktopNumber", 2)

  property var dateBackgroundColor: "#ffffff"
  property var dayNameColor: "#071169"
  property var dayDateColor: "#071169"
  property string dayNameFont: "Sans Serif"
  property string dayDateFont: "Serif"
  property real dayNameScale: 50
  property real dayDateScale: 50

  property var desktopNameBackgroundColor: "#ffffff"
  property var desktopNameColor: "#071169"
  property string desktopNameFont: "Sans Serif"
  property real desktopNameScale: 50

  property var numberBackgroundColor: "#071169"
  property var numberTextColor: "#ffffff"
  property string numberFont: "Serif"
  property real numberScale: 50

  signal colorRequested(string target, var currentColor)
  signal styleRequested(string target)

  function totalSectionsWeight() {
    return VJS.totalSectionsWeight(sectionDateWidthWeight, sectionDesktopNameWidthWeight, sectionDesktopNumberWidthWeight)
  }

  function sectionWidth(weight) {
    return VJS.sectionWidth(contentItem.width, totalSectionsWeight(), weight)
  }

  function sectionOffset(order) {
    return VJS.sectionOffset(contentItem.width, totalSectionsWeight(), dateSectionOrder, nameSectionOrder, sectionDesktopNumberOrder, sectionDateWidthWeight, sectionDesktopNameWidthWeight, sectionDesktopNumberWidthWeight, order)
  }

  QTQ.Item {
    id: contentItem
    width: (_Root.heightWidthRatio > 0 && _Root.width * 10 > _Root.height * _Root.heightWidthRatio)
        ? Math.round(_Root.height * _Root.heightWidthRatio / 10)
        : _Root.width
    height: (_Root.heightWidthRatio > 0 && _Root.width * 10 > _Root.height * _Root.heightWidthRatio)
        ? _Root.height
        : (_Root.heightWidthRatio > 0 ? Math.round(_Root.width * 10 / _Root.heightWidthRatio) : _Root.height)
    anchors.centerIn: parent
    clip: true

    QTQ.Rectangle {
      id: dateBlock
      x: _Root.sectionOffset(_Root.dateSectionOrder)
      width: _Root.sectionWidth(_Root.sectionDateWidthWeight)
      height: parent.height
      visible: _Root.sectionDateWidthWeight > 0
      color: _Root.dateBackgroundColor
      border.color: _Root.interactive && dateMouse.containsMouse && !dayNameMouse.containsMouse && !dayDateMouse.containsMouse
          ? Kirigami.Theme.highlightColor : "transparent"
      border.width: 2

      QTQ.MouseArea {
        id: dateMouse
        anchors.fill: parent
        hoverEnabled: _Root.interactive
        enabled: _Root.interactive
        onClicked: _Root.colorRequested("date", dateBlock.color)
      }

      QTQ.Text {
        id: dayNameText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        text: Qt.locale().toString(_Root.currentDate, "dddd")
        color: _Root.dayNameColor
        font.family: _Root.dayNameFont
        font.pixelSize: Math.max(1, parent.height * (_Root.dayNameScale / 100))
        font.weight: 400

        QTQ.MouseArea {
          id: dayNameMouse
          anchors.fill: parent
          hoverEnabled: _Root.interactive
          enabled: _Root.interactive
          onClicked: _Root.styleRequested("dayName")
        }

        QTQ.Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.color: _Root.interactive && dayNameMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
          border.width: 2
        }
      }

      QTQ.Text {
        id: dayDateText
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        text: Qt.locale().toString(_Root.currentDate, "dd.MM")
        color: _Root.dayDateColor
        font.family: _Root.dayDateFont
        font.pixelSize: Math.max(1, parent.height * (_Root.dayDateScale / 100))
        font.weight: 600

        QTQ.MouseArea {
          id: dayDateMouse
          anchors.fill: parent
          hoverEnabled: _Root.interactive
          enabled: _Root.interactive
          onClicked: _Root.styleRequested("dayDate")
        }

        QTQ.Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.color: _Root.interactive && dayDateMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
          border.width: 2
        }
      }
    }

    QTQ.Rectangle {
      id: nameBlock
      x: _Root.sectionOffset(_Root.nameSectionOrder)
      width: _Root.sectionWidth(_Root.sectionDesktopNameWidthWeight)
      height: parent.height
      visible: _Root.sectionDesktopNameWidthWeight > 0
      color: _Root.desktopNameBackgroundColor
      border.color: _Root.interactive && nameMouse.containsMouse && !desktopNameTextMouse.containsMouse
          ? Kirigami.Theme.highlightColor : "transparent"
      border.width: 2

      QTQ.MouseArea {
        id: nameMouse
        anchors.fill: parent
        hoverEnabled: _Root.interactive
        enabled: _Root.interactive
        onClicked: _Root.colorRequested("desktopNameBackground", nameBlock.color)
      }

      QTQ_C.Label {
        id: desktopNameText
        anchors.centerIn: parent
        width: Math.max(0, parent.width - Kirigami.Units.smallSpacing * 2)
        text: _Root.desktopName
        color: _Root.desktopNameColor
        font.family: _Root.desktopNameFont
        font.pixelSize: Math.max(1, parent.height * (_Root.desktopNameScale / 100))
        horizontalAlignment: QTQ.Text.AlignHCenter
        elide: QTQ.Text.ElideRight

        QTQ.MouseArea {
          id: desktopNameTextMouse
          anchors.fill: parent
          hoverEnabled: _Root.interactive
          enabled: _Root.interactive
          onClicked: _Root.styleRequested("desktopName")
        }

        QTQ.Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.color: _Root.interactive && desktopNameTextMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
          border.width: 2
        }
      }
    }

    QTQ.Rectangle {
      id: numberBlock
      x: _Root.sectionOffset(_Root.sectionDesktopNumberOrder)
      width: _Root.sectionWidth(_Root.sectionDesktopNumberWidthWeight)
      height: parent.height
      visible: _Root.sectionDesktopNumberWidthWeight > 0
      color: _Root.numberBackgroundColor
      border.color: _Root.interactive && numberMouse.containsMouse && !numberTextMouse.containsMouse
          ? Kirigami.Theme.highlightColor : "transparent"
      border.width: 2

      QTQ.MouseArea {
        id: numberMouse
        anchors.fill: parent
        hoverEnabled: _Root.interactive
        enabled: _Root.interactive
        onClicked: _Root.colorRequested("number", numberBlock.color)
      }

      QTQ.Text {
        id: numberText
        anchors.centerIn: parent
        text: _Root.desktopNo
        color: _Root.numberTextColor
        font.family: _Root.numberFont
        font.pixelSize: Math.max(1, parent.height * (_Root.numberScale / 100))
        font.weight: 700

        QTQ.MouseArea {
          id: numberTextMouse
          anchors.fill: parent
          hoverEnabled: _Root.interactive
          enabled: _Root.interactive
          onClicked: _Root.styleRequested("numberText")
        }

        QTQ.Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.color: _Root.interactive && numberTextMouse.containsMouse ? Kirigami.Theme.highlightColor : "transparent"
          border.width: 2
        }
      }
    }
  }
}