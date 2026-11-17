import QtQuick as QTQ
import QtQuick.Layouts as QTQ_L

/*
  Needs: _FontMetrics, _ActiveSystemPalette
 */

QTQ.Rectangle {
  QTQ_L.Layout.fillWidth: true
  QTQ_L.Layout.preferredHeight: _FontMetrics.height

  color: "transparent"

  QTQ.Rectangle {
    anchors.centerIn: parent
    width: parent.width * .95
    height: 1

    color: _ActiveSystemPalette.mid
  }
}