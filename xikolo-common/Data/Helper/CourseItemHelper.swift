//
//  CourseItemHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Result

class CourseItemHelper {

    static private let entity = NSEntityDescription.entityForName("CourseItem", inManagedObjectContext: CoreDataHelper.managedContext)!

    static func getItemRequest(section: CourseSection) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section = %@", section)
        let titleSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }
    
    static func getItemRequest(course: Course) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section.course = %@", course)
        let titleSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }
    
    static func initializeSectionResultsController(request: NSFetchRequest) -> NSFetchedResultsController {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataHelper.managedContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    static func initializeItemResultsController(request: NSFetchRequest) -> NSFetchedResultsController {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataHelper.managedContext, sectionNameKeyPath: "section.title", cacheName: nil)
    }

    static func syncCourseItems(section: CourseSection) -> Future<[CourseItem], XikoloError> {
        return CourseItemProvider.getCourseItems(section.id).flatMap { spineItems in
            future(context: ImmediateExecutionContext) {
                do {
                    let request = getItemRequest(section)
                    let cdItems = try SpineModelHelper.syncObjects(request, spineObjects: spineItems, inject:["section": section], save: true)
                    return Result.Success(cdItems as! [CourseItem])
                } catch let error as XikoloError {
                    return Result.Failure(error)
                } catch {
                    return Result.Failure(XikoloError.UnknownError(error))
                }
            }
        }
    }

}
