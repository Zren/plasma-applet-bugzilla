import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"
import "lib/TimeUtils.js" as TimeUtils

IssueListView {
	id: issueListView

	isSetup: widget.hasProduct
	showHeading: plasmoid.configuration.showHeading
	headingText: plasmoid.configuration.productList.join(', ')

	delegate: IssueListItem {
		property bool issueClosed: {
			return issue.status == 'RESOLVED' || issue.status == 'CLOSED'
		}
		issueOpen: !issueClosed
		issueSummary: issue.summary
		tagBefore: issue.product
		issueHtmlLink: 'https://' + plasmoid.configuration.domain + '/show_bug.cgi?id=' + issue.id
		showNumComments: typeof issue.comment_count !== "undefined" && numComments > 0
		numComments: issue.comment_count || 0

		dateTime: {
			if (issueOpen) {
				return issue.creation_time
			} else { // Closed
				return issue.last_change_time
			}
		}
	}
}
