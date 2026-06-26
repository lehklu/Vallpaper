import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    width: 100
    height: 100
    
    Component.onCompleted: {
        console.log("Checking Kirigami.ItemDelegate...")
        try {
            var component = Qt.createComponent("import org.kde.kirigami; ItemDelegate {}");
            console.log("Kirigami.ItemDelegate status: " + component.status)
            if (component.status === Component.Error) {
                console.log("Error: " + component.errorString())
            }
        } catch (e) {
            console.log("Exception: " + e)
        }
        
        console.log("Checking QtQuick.Controls.ItemDelegate...")
        try {
            var component2 = Qt.createComponent("import QtQuick.Controls; ItemDelegate {}");
            console.log("QtQuick.Controls.ItemDelegate status: " + component2.status)
        } catch (e) {
            console.log("Exception: " + e)
        }
        
        Qt.quit()
    }
}
