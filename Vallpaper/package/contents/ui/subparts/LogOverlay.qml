import QtQuick as QTQ
import QtQuick.Controls as QTQ_C

QTQ.Rectangle { id: _LogBackground

  color: "transparent"
  anchors.fill: parent

  property var _textColor
  property var _maxLines: 30

  property int autoclear: 0

  function clear() {

    _Log.text = '';
    autoclear = 0;
  }

  function sayo($o) {

    say(JSON.stringify($o));
  }

  function say($text) {

    _Log.text = _Log.text + '\n' + $text;
    autoclear++;

    if (autoclear > _maxLines) { clear(); }
  }

  QTQ_C.ScrollView {
    anchors.fill: parent
    background: QTQ.Rectangle { color: '#0000ff00' }

    QTQ_C.TextArea { id: _Log
      readOnly: true

      color: _LogBackground._textColor ? _LogBackground._textColor : palette.text
      background: QTQ.Rectangle { color: '#00ffffff' }
      wrapMode: QTQ.TextEdit.Wrap
      horizontalAlignment: QTQ.TextEdit.AlignRight
    }
  }
}