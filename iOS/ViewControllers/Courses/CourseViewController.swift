//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleView: UILabel!

    private var courseAreaViewController: UIViewController?
    private var courseAreaListViewController: CourseAreaListViewController? {
        didSet {
            self.courseAreaListViewController?.delegate = self
        }
    }

    private var courseObserver: ManagedObjectObserver?

    var course: Course! {
        didSet {
            self.updateView()
            self.courseObserver = ManagedObjectObserver(object: self.course) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }
        }
    }

    var content: CourseArea? {
        didSet {
            guard self.viewIfLoaded != nil else { return }
            self.updateContainerView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.decideContent()

        SpotlightHelper.shared.setUserActivity(for: self.course)
        CrashlyticsHelper.shared.setObjectValue(self.course.id, forKey: "course_id")
    }

    private func updateView() {
        self.titleView.text = self.course.title

        if let titleView = self.navigationItem.titleView, let text = self.titleView.text {
            let titleWidth = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: self.titleView.font]).width
            var frame = titleView.frame
            frame.size.width = titleWidth + 2
            titleView.frame = frame
            titleView.setNeedsLayout()
        }
    }

    private func closeCourse() {
        let courseNavigationController = self.navigationController as? CourseNavigationController
        courseNavigationController?.closeCourse()
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        self.closeCourse()
    }

    private func decideContent() {
        if !self.course.hasEnrollment {
            self.content = .courseDetails
        } else {
            self.content = self.course.accessible ? .learnings : .courseDetails
        }

        self.courseAreaListViewController?.refresh(animated: false)
    }

    private func updateContainerView() {
        let animationTime: TimeInterval = 0.2

        self.courseAreaViewController?.willMove(toParentViewController: nil)

        // swiftlint:disable multiple_closures_with_trailing_closure
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut, animations: {
            self.courseAreaViewController?.view.alpha = 0
        }) { _ in
            self.courseAreaViewController?.view.removeFromSuperview()
            self.courseAreaViewController?.removeFromParentViewController()
            self.courseAreaViewController = nil

            guard let newViewController = self.content?.viewController else { return }
            newViewController.configure(for: self.course, delegate: self)
            newViewController.view.frame = self.containerView.bounds
            newViewController.view.alpha = 0

            self.containerView.addSubview(newViewController.view)
            self.addChildViewController(newViewController)
            self.courseAreaViewController = newViewController

            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut, animations: {
                newViewController.view.alpha = 1
            }) { _ in
                newViewController.didMove(toParentViewController: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseAreaListViewController = segue.destination as? CourseAreaListViewController {
            self.courseAreaListViewController = courseAreaListViewController
        }
    }

    @IBAction func shareCourse(_ sender: UIBarButtonItem) {
        let activityItems = ([self.course.title, self.course.url] as [Any?]).compactMap { $0 }
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            let context: [String: String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.shared.createEvent(.shareCourse, resourceType: .course, resourceId: self.course.id, context: context)
        }

        self.present(activityViewController, animated: true)
    }

}

extension CourseViewController: CourseAreaListViewControllerDelegate {

    var accessibleContent: [CourseArea] {
        if self.course.hasEnrollment && self.course.accessible {
            return CourseArea.orderedValues
        } else {
            return CourseArea.orderedValues.filter { $0.acessibleWithoutEnrollment }
        }
    }

    var selectedContent: CourseArea? {
        return self.content
    }

    func change(to content: CourseArea) {
        self.content = content
    }

}

extension CourseViewController: CourseAreaViewControllerDelegate {

    func enrollmentStateDidChange() {
        self.decideContent()
    }

}
