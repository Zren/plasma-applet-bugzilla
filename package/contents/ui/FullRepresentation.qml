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
		issueId: issue.id
		issueSummary: issue.summary
		tagBefore: plasmoid.configuration.productList.length >= 2 ? issue.product : ""
		issueCreatorName: issue.creator_detail.real_name || issue.creator_detail.name
		issueHtmlLink: 'https://' + plasmoid.configuration.domain + '/show_bug.cgi?id=' + issue.id

		// As of writing, KDE's bugzilla v5.0.4 does respond with comment_count,
		// while Mozilla's bugzilla does.
		property bool supportsComments: typeof issue.comment_count !== "undefined"
		// Note: The "reporter comment" is included in the total,
		// so we subtract by 1 to get the number of responses.
		showNumComments: supportsComments && numComments > 0
		numComments: supportsComments ? (issue.comment_count - 1) : 0

		dateTime: {
			if (issueOpen) {
				return issue.creation_time
			} else { // Closed
				return issue.last_change_time
			}
		}

		issueState: {
			if (issueOpen) {
				return 'opened'
			} else { // Closed
				return 'closed'
			}
		}
	}
}
