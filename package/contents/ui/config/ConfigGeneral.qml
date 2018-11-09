import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.5 as Kirigami

import "../lib"

ColumnLayout {
	property alias cfg_domain: domainTextField.text
	property alias cfg_updateIntervalInMinutes: updateIntervalInMinutesSpinBox.value

	ColumnLayout {
		Layout.alignment: Qt.AlignTop

		Kirigami.FormLayout {
			Layout.fillWidth: true
			wideMode: true

			TextField {
				id: domainTextField
				Kirigami.FormData.label: i18n("Domain:")
				Layout.fillWidth: true
			}

			ConfigStringList {
				id: productTextField
				Kirigami.FormData.label: i18n("Project:")
				configKey: 'productList'
				Layout.fillWidth: true
			}

			ConfigRadioButtonGroup {
				Kirigami.FormData.label: i18n("Issues:")
				configKey: "issueState"
				model: [
					{ value: "open", text: i18n("Open Issues") },
					{ value: "closed", text: i18n("Closed Issues") },
					{ value: "all", text: i18n("Open + Closed Issues") },
				]
			}

			SpinBox {
				id: updateIntervalInMinutesSpinBox
				Kirigami.FormData.label: i18n("Update Every:")
				stepSize: 5
				minimumValue: 5
				maximumValue: 24 * 60
				suffix: i18nc("Polling interval in minutes", "min")
			}

			ConfigCheckBox {
				configKey: "showHeading"
				text: i18n("Show Heading")
			}

			ConfigCheckBox {
				configKey: "showBackground"
				text: i18n("Desktop Widget: Show background")
			}
		}
	}
}
