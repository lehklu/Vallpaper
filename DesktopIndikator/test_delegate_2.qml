import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    visible: false
    Component.onCompleted: {
        console.log("Checking Kirigami.ItemDelegate...")
        // We can't easily check for type existence without trying to instantiate it
        Qt.quit()
    }
}
