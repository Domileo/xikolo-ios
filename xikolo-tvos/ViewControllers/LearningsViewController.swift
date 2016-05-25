//
//  LearningsViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import AVKit
import CoreData
import UIKit

class LearningsViewController : UIViewController {

    @IBOutlet weak var sectionTableView: UITableView!
    @IBOutlet weak var itemCollectionView: UICollectionView!

    var courseTabBarController: CourseTabBarController!
    var course: Course!

    var sectionResultsController: NSFetchedResultsController!
    var itemResultsController: NSFetchedResultsController?
    var itemResultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation!

    override func viewDidLoad() {
        courseTabBarController = self.tabBarController as! CourseTabBarController
        course = courseTabBarController.course

        if course.id != nil {
            let request = CourseSectionHelper.getSectionRequest(course)
            sectionResultsController = CourseSectionHelper.initializeFetchedResultsController(request)
            sectionResultsController.delegate = self

            itemResultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(itemCollectionView)
            itemResultsControllerDelegateImplementation.delegate = self

            do {
                try sectionResultsController.performFetch()

                if sectionResultsController.fetchedObjects!.count > 0 {
                    sectionTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Middle)
                    if let section = sectionResultsController.fetchedObjects![0] as? CourseSection {
                        loadItemsForSection(section)
                    }
                }
            } catch {
                // TODO: Error handling.
            }

            CourseSectionHelper.syncCourseSections(course)
        }
    }

    func loadItemsForSection(section: CourseSection) {
        if section.id != nil {
            let request = CourseItemHelper.getItemRequest(section)
            itemCollectionView.reloadData()
            itemResultsController = CourseItemHelper.initializeFetchedResultsController(request)
            itemResultsController!.delegate = itemResultsControllerDelegateImplementation

            do {
                try itemResultsController!.performFetch()
            } catch {
                // TODO: Error handling
            }

            CourseItemHelper.syncCourseItems(section)
        }
    }

}

extension LearningsViewController : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = sectionResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseSectionCell", forIndexPath: indexPath) as! CourseSectionCell
        self.configureSectionCell(cell, atIndexPath: indexPath)
        return cell
    }

    func configureSectionCell(cell: CourseSectionCell, atIndexPath indexPath: NSIndexPath) {
        let section = sectionResultsController.objectAtIndexPath(indexPath) as! CourseSection
        cell.configure(section)
    }

}

extension LearningsViewController : NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        sectionTableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            sectionTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            sectionTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            sectionTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            sectionTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            // No need to update a cell that has not been loaded.
            if let cell = sectionTableView.cellForRowAtIndexPath(indexPath!) as? CourseSectionCell {
                configureSectionCell(cell, atIndexPath: indexPath!)
            }
        case .Move:
            sectionTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            sectionTableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        sectionTableView.endUpdates()
    }

}

extension LearningsViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let section = sectionResultsController.objectAtIndexPath(indexPath) as! CourseSection
        loadItemsForSection(section)
        return indexPath
    }

}

extension LearningsViewController : UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = itemResultsController?.sections {
            return sections.count
        } else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sections = itemResultsController!.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseItemCell", forIndexPath: indexPath) as! CourseItemCell
        configureItemCell(cell, indexPath: indexPath)
        return cell
    }

}

extension LearningsViewController : CollectionViewResultsControllerDelegateImplementationDelegate {

    func configureCell(delegateImplementation: CollectionViewResultsControllerDelegateImplementation, cell: UICollectionViewCell, indexPath: NSIndexPath) {
        configureItemCell(cell as! CourseItemCell, indexPath: indexPath)
    }

    func configureItemCell(cell: CourseItemCell, indexPath: NSIndexPath) {
        let item = itemResultsController!.objectAtIndexPath(indexPath) as! CourseItem
        cell.configure(item)
    }

}

extension LearningsViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = itemResultsController!.objectAtIndexPath(indexPath) as! CourseItem
        showItem(item)
    }

    func showItem(item: CourseItem) {
        if let content_type = item.content_type {
            switch content_type {
                case "video":
                    performSegueWithIdentifier("ShowCourseItemVideoSegue", sender: item)
                default:
                    // TODO: show error: unsupported type
                    break;
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "ShowCourseItemVideoSegue"?:
                let vc = segue.destinationViewController as! AVPlayerViewController
                //let item = sender as! CourseItem
                // TODO: Fetch real URL.
                let mockUrl = NSURL(string: "https://player.vimeo.com/external/164726756.m3u8?s=69976e2f9e2216472fa63f8feff4503ee2d6513b&oauth2_token_id=621239406")!
                let avPlayer = AVPlayer(URL: mockUrl)
                avPlayer.play()
                vc.player = avPlayer
            default:
                break
        }
    }

}
