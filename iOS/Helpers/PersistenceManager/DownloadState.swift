//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

enum DownloadState: String {
    case notDownloaded  // not downloaded at all
    case pending  // waiting for downloaded to start
    case downloading  // download in progress
    case downloaded  // downloaded and saved on disk

    static let didChangeNotification = Notification.Name("de.xikolo.ios.download.stateChanged")
}

typealias DownloadProgress = Double

extension DownloadProgress {
    static let didChangeNotification = Notification.Name("de.xikolo.ios.download.progressChanged")
}

struct DownloadNotificationKey {

    static let resourceId = "ResourceIdKey"
    static let downloadState = "ResourceDownloadStateKey"
    static let downloadProgress = "ResourceDownloadProgressKey"
    static let downloadType = "DownloadTypeKey"

}
