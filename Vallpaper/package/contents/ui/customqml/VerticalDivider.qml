import QtQuick as QTQ
import QtQuick.Layouts as QTQ_L

/*
  Needs _FontMetrics: QTQ.FontMetrics { id: _FontMetrics }
*/

QTQ.Canvas {
  contextType: "2d"

  width: _FontMetrics.averageCharacterWidth * 1/3
  QTQ_L.Layout.preferredHeight: _FontMetrics.height * 1.4

  onPaint: {

    context.lineWidth = width;
    //context.setLineDash([1, 1]);
    context.strokeStyle = _ActiveSystemPalette.dark

    context.moveTo(0, 0)
    context.lineTo(0, height)

    context.stroke()
  }
}