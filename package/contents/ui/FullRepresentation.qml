import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"
import "lib/TimeUtils.js" as TimeUtils

Item {
	id: popup

	Layout.minimumWidth: 300 * units.devicePixelRatio
	Layout.minimumHeight: 200 * units.devicePixelRatio
	Layout.preferredHeight: 600 * units.devicePixelRatio

	RelativeDateTimer { id: relativeDateTimer }

	ColumnLayout {
		anchors.fill: parent
		visible: widget.hasProduct

		PlasmaComponents.Label {
			id: heading
			Layout.fillWidth: true
			visible: plasmoid.configuration.showHeading
			text: plasmoid.configuration.productList.join(', ')
			font.weight: Font.Bold
			font.pixelSize: 24
			elide: Text.ElideRight
			wrapMode: Text.NoWrap

			PlasmaCore.ToolTipArea {
				anchors.fill: parent
				enabled: parent.truncated
				subText: parent.text
			}
		}

		ScrollView {
			id: scrollView
			Layout.fillWidth: true
			Layout.fillHeight: true

			ListView {
				id: listView
				width: scrollView.width

				model: issuesModel
				delegate: ColumnLayout {
					spacing: 0
					width: listView.width
						
					property var issue: modelData
					readonly property bool issueClosed: {
						return issue.status == 'RESOLVED' || issue.status == 'CLOSED'
					}
					readonly property bool issueOpen: !issueClosed
					readonly property string issueHtmlLink: 'https://' + plasmoid.configuration.domain + '/show_bug.cgi?id=' + issue.id
					readonly property int issueCommentCount: issue.comment_count || 0
					readonly property string issueCreatorName: issue.creator_detail.real_name || issue.creator_detail.name

					Rectangle {
						visible: (heading.visible && index == 0) || index > 0
						Layout.fillWidth: true
						color: theme.textColor
						Layout.preferredHeight: 1 * units.devicePixelRatio
						opacity: 0.3
					}
					
					RowLayout {
						Layout.fillWidth: true

						property int sidePadding: 16 * units.devicePixelRatio
						Layout.rightMargin: sidePadding
						Layout.leftMargin: sidePadding

						property int padding: 8 * units.devicePixelRatio
						Layout.topMargin: padding
						Layout.bottomMargin: padding

						TextLabel {
							id: issueTitleIcon
							
							text: {
								// if (issue.pull_request) {
								// 	if (issue.state == 'open') {
								// 		return octicons.gitPullRequest
								// 	} else { // 'closed'
								// 		// Note, there's currently no way to tell if a pull request was merged
								// 		// or if it was closed. To find that out, we'd need to query 
								// 		// the pull request api endpoint as well.
								// 		if (true) { // issue.merged
								// 			return octicons.gitMerge
								// 		} else {
								// 			return octicons.gitPullRequest
								// 		}
								// 	}
								// } else {
									if (issueOpen) {
										return octicons.issueOpened
									} else {
										return octicons.issueClosed
									}
								// }
							}
							color: {
								if (issueOpen) {
									return '#28a745'
								} else { // 'closed'
									// if (issue.pull_request) {
									// 	// Note: Assume it was merged
									// 	if (true) { // issue.merged
									// 		return '#6f42c1'
									// 	} else {
									// 		return '#cb2431'
									// 	}
									// } else {
										return '#cb2431'
									// }
								}
							}
							font.family: "fontello"
							font.pointSize: -1
							font.pixelSize: 16 * units.devicePixelRatio
							// font.weight: Font.Bold
							Layout.alignment: Qt.AlignTop
							Layout.minimumWidth: 16 * units.devicePixelRatio
							Layout.minimumHeight: 16 * units.devicePixelRatio
						}

						ColumnLayout {
							spacing: 4 * units.devicePixelRatio

							TextButton {
								id: issueTitleLabel

								Layout.fillWidth: true
								text: issue.summary
								font.weight: Font.Bold

								onClicked: Qt.openUrlExternally(issueHtmlLink)

								onLineLaidOut: {
									if (line.number == 0) {
										var indent = productTag.width + productTag.rightMargin
										line.x += indent
										line.width -= indent
									}
								}

								TextTag {
									id: productTag
									text: issue.product

									function alpha(c, a) {
										return Qt.rgba(c.r, c.g, c.b, a)
									}
									function lerpColor(a, b, ratio) {
										return Qt.tint(a, alpha(b, ratio))
									}
									backgroundColor: lerpColor(theme.backgroundColor, theme.textColor, 0.2)
									textColor: lerpColor(theme.backgroundColor, theme.textColor, 0.85)
									font.weight: Font.Bold
									font.pixelSize: 12 * units.devicePixelRatio
									lineHeight: 15 * units.devicePixelRatio
									property int rightMargin: 4 * units.devicePixelRatio
								}
							}

							TextLabel {
								id: timestampText
								Layout.fillWidth: true
								wrapMode: Text.Wrap
								font.family: 'Helvetica'
								font.pointSize: -1
								font.pixelSize: 12 * units.devicePixelRatio
								opacity: 0.6

								text: ""
								property var dateTime: {
									if (issueOpen) { // '#19 opened 7 days ago by RustyRaptor'
										return issue.creation_time
									} else { // 'closed'   #14 by JPRuehmann was closed on 5 Jul 
										return issue.last_change_time
									}
								}
								property string dateTimeText: ""
								Component.onCompleted: timestampText.updateText()
								
								Connections {
									target: relativeDateTimer
									onTriggered: timestampText.updateText()
								}

								function updateRelativeDate() {
									dateTimeText = TimeUtils.getRelativeDate(dateTime)
								}

								function updateText() {
									updateRelativeDate()
									if (issueOpen) { // '#19 opened 7 days ago by RustyRaptor'
										text = i18n("#%1 opened %2 by %3", issue.id, dateTimeText, issueCreatorName)
									} else { // 'closed'   #14 by JPRuehmann was closed on 5 Jul
										// if (issue.pull_request && true) { // Assume issue.merged=true
										// 	text = i18n("#%1 by %3 was merged %2", issue.id, dateTimeText, issueCreatorName)
										// } else {
											text = i18n("#%1 by %3 was closed %2", issue.id, dateTimeText, issueCreatorName)
										// }
									}
								}
							}
						}

						MouseArea {
							id: commentButton
							Layout.alignment: Qt.AlignTop
							implicitWidth: commentButtonRow.implicitWidth
							implicitHeight: commentButtonRow.implicitHeight

							visible: typeof issue.comment_count !== "undefined"
							
							hoverEnabled: true
							cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
							property color textColor: containsMouse ? PlasmaCore.ColorScope.highlightColor : PlasmaCore.ColorScope.textColor

							onClicked: Qt.openUrlExternally(issueHtmlLink)

							RowLayout {
								id: commentButtonRow
								spacing: 0

								TextLabel {
									text: octicons.comment
									
									color: commentButton.textColor
									font.family: "fontello"
									// font.weight: Font.Bold
									font.pointSize: -1
									font.pixelSize: 16 * units.devicePixelRatio
									Layout.preferredHeight: 16 * units.devicePixelRatio
								}

								TextLabel {
									text: " " + (commentButton.visible ? issue.comment_count : 0)
									
									color: commentButton.textColor
									font.family: "Helvetica"
									// font.weight: Font.Bold
									font.pointSize: -1
									font.pixelSize: 12 * units.devicePixelRatio
									Layout.preferredHeight: 12 * units.devicePixelRatio
									Layout.alignment: Qt.AlignTop
								}
							}
						}
					}
					
				}
			}
		}

	}

	PlasmaComponents.Button {
		anchors.centerIn: parent
		visible: !widget.hasProduct
		text: plasmoid.action("configure").text
		onClicked: plasmoid.action("configure").trigger()
	}
}
