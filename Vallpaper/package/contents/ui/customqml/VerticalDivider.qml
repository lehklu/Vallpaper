import QtQuick as QTQ
import QtQuick.Layouts as QTQ_L

QTQ.Canvas {
  width: _FontMetrics.averageCharacterWidth *1/ 3
  QTQ_L.Layout.preferredHeight: _FontMetrics.height * 1.4
  onPaint: {
    var ctx = getContext("2d");
    ctx.lineWidth = width;
    //ctx.setLineDash([1, 1]);
    ctx.strokeStyle = _ActiveSystemPalette.dark

    ctx.moveTo(0, 0)
    ctx.lineTo(0, height)

    ctx.stroke()
  }
}