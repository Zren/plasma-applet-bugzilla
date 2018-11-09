import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"
import "lib/Requests.js" as Requests

Item {
	id: widget

	Logger {
		id: logger
		name: 'bugzilla'
		// showDebug: true
	}

	Plasmoid.icon: plasmoid.file("", "icons/bug.svg")
	Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground
	Plasmoid.hideOnWindowDeactivate: !plasmoid.userConfiguring

	readonly property bool hasProduct: plasmoid.configuration.domain && plasmoid.configuration.productList
	readonly property string issueState: plasmoid.configuration.issueState
	readonly property string issuesUrl: {
		var url = 'https://' + plasmoid.configuration.domain + '/rest/bug'
		var productList = plasmoid.configuration.productList
		for (var i = 0; i < productList.length; i++) {
			url += i == 0 ? '?' : '&'
			url += 'product=' + encodeURIComponent(productList[i])
		}
		url += '&limit=25&order=bug_id%20DESC'
		if (issueState == 'open') {
			url += '&bug_status=UNCONFIRMED&bug_status=CONFIRMED&bug_status=ASSIGNED&bug_status=REOPENED&bug_status=NEEDSINFO&bug_status=VERIFIED'
		} else if (issueState == 'closed') {
			url += '&bug_status=CLOSED&bug_status=RESOLVED'
		}
		return url
	}

	property var issuesModel: []

	Octicons { id: octicons }

	Plasmoid.fullRepresentation: FullRepresentation {}

	function updateIssuesModel() {
		if (widget.hasProduct) {
			logger.debug('issuesUrl', issuesUrl)
			Requests.getJSON({
				url: issuesUrl
			}, function(err, data, xhr){
				logger.debug(err)
				logger.debugJSON(data)
				widget.issuesModel = data.bugs
			})
		} else {
			widget.issuesModel = []
		}
	}
	Timer {
		id: debouncedUpdateIssuesModel
		interval: 400
		onTriggered: {
			logger.debug('debouncedUpdateIssuesModel.onTriggered')
			widget.updateIssuesModel()
		}
	}
	Timer {
		id: updateModelTimer
		running: true
		repeat: true
		interval: plasmoid.configuration.updateIntervalInMinutes * 60 * 1000
		onTriggered: {
			logger.debug('updateModelTimer.onTriggered')
			debouncedUpdateIssuesModel.restart()
		}
	}

	Connections {
		target: plasmoid.configuration
		onDomainChanged: debouncedUpdateIssuesModel.restart()
		onProductChanged: debouncedUpdateIssuesModel.restart()
		onIssueStateChanged: debouncedUpdateIssuesModel.restart()
	}

	function action_refresh() {
		debouncedUpdateIssuesModel.restart()
	}

	Component.onCompleted: {
		plasmoid.setAction("refresh", i18n("Refresh"), "view-refresh")

		updateIssuesModel()

		// plasmoid.action("configure").trigger() // Uncomment to test config window
	}
}
