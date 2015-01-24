//
//  HourSystemViewControllerManager.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/19/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//
import UIKit

class HourSystemViewControllerManager: UIViewController, UIPageViewControllerDataSource {

    let numberToHebrewNumbersMale = [1:"ראשון", 2:"שני", 3:"שלישי", 4:"רביעי", 5:"חמישי", 6:"שישי", 7:"שבת"]
    private let numberOfPages = 6
    // MARK: - Variables
    private var pageViewController: UIPageViewController?

    // Initialize it right away here

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControl()
    }

    private func createPageViewController() {

        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("HourSystem") as UIPageViewController
        pageController.dataSource = self
        //pageController.automaticallyAdjustsScrollViewInsets = false

        //Calculate date of today
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = NSDate(timeIntervalSinceNow: 0)
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: todayDate)
        let weekDay = myComponents.weekday

        let firstController = getItemController((weekDay == 7 ? 0 : weekDay - 1))!
        let startingViewControllers: NSArray = [firstController]
        pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }

    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.blackColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        //appearance.backgroundColor = UIColor(red: 102, green: 255, blue: 204, alpha: 1)
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        let itemController = viewController as HourSys

        if itemController.itemIndex!+1 < numberOfPages {
            return getItemController(itemController.itemIndex!+1)
        }

        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        let itemController = viewController as HourSys

        if itemController.itemIndex! > 0 {
            return getItemController(itemController.itemIndex!-1)
        }

        return nil
    }

    private func getItemController(itemIndex: Int) -> HourSys? {

        if itemIndex < numberOfPages {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("HourSystemContent") as HourSys
            pageItemController.itemIndex = itemIndex
            return pageItemController
        }

        return nil
    }

    // MARK: - Page Indicator

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return numberOfPages
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        //Calculate date of today
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = NSDate(timeIntervalSinceNow: 0)
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay == 7 ? 6 : 6 - weekDay
    }
}

