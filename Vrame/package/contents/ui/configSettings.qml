/*
 *  Copyright 2024  Werner Lechner <werner.lechner@lehklu.at>
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 6.3 as QtDialogs
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils

SimpleKCM {
	id: generalPage

	property var cfg_vrame6
	property var cfg_vrame6Default

	Kirigami.FormLayout {

		ColumnLayout {

			RowLayout { // Manage/Select Desktop

				QQC2.Label {
					text: "Desktop"
				}

				QQC2.ComboBox {
					id: dateDisplayFormat
      		model: [
          	"model1",
            "model2",
            "model3"
					]
				}

				QQC2.Button {
					text: "Add"
          icon.name: "list-add"
				}

				QQC2.Button {
          icon.name: "edit-delete-remove"
				}
			}

			RowLayout { // Timeline
			}

			RowLayout { // Settings
			}
		}
	}
}