//
//  CourseHelper.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 30.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseHelper {

    static private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static private let managedContext = appDelegate.managedObjectContext
    static private let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: managedContext)!

    static func getAllCoursesRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Course")
        let startDateSort = NSSortDescriptor(key: "start_date", ascending: true)
        request.sortDescriptors = [startDateSort]
        return request
    }

    static func getMyCoursesRequest() -> NSFetchRequest {
        let request = getAllCoursesRequest()
        request.predicate = NSPredicate(format: "is_enrolled_int == true")
        return request
    }

    static func initializeFetchedResultsController(request: NSFetchRequest) -> NSFetchedResultsController {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    static func getNumberOfEnrolledCourses() throws -> Int {
        let request = getMyCoursesRequest()
        let courses = try managedContext.executeFetchRequest(request)
        return courses.count
    }

    static func refreshCourses() {
        CourseProvider.getCourses { (courses, error) in
            if let courses = courses {
                do {
                    try syncCourses(courses)
                } catch {
                    // TODO: Error handling
                }
            }
        }
    }

    private static func syncCourses(courses: [[String: AnyObject]]) throws {
        let request = NSFetchRequest(entityName: "Course")
        for course in courses {
            if let id = course["id"] as? String {
                let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                request.predicate = predicate

                var cdCourse: Course!
                let results = try managedContext.executeFetchRequest(request) as! [Course]
                if (results.count > 0) {
                    cdCourse = results[0]
                } else {
                    cdCourse = Course(entity: entity, insertIntoManagedObjectContext: managedContext)
                    cdCourse.id = id
                }
                cdCourse.loadFromDict(course)
            }
        }
        // TODO: Delete courses from CD that have not been returned
        try managedContext.save()
    }

}