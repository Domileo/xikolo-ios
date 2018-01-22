//
//  RichTextHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 10.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct RichTextHelper {

    @discardableResult static func syncRichText(_ richText: RichText) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = RichTextHelper.FetchRequest.richText(withId: richText.id)
        let query = SingleResourceQuery(resource: richText)
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
