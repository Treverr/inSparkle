//
//  MyTimecardWeekSelectionTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/30/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class MyTimecardWeekSelectionTableViewController: UITableViewController {
    
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    
    var weekLabels : [UILabel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekLabels.append(mondayLabel)
        weekLabels.append(tuesdayLabel)
        weekLabels.append(wednesdayLabel)
        weekLabels.append(thursdayLabel)
        weekLabels.append(fridayLabel)
        weekLabels.append(saturdayLabel)
        weekLabels.append(sundayLabel)
        
        setDayLabel()
        
        
    }
    
    func setDayLabel() {
        
        for day in weekLabels {
        
        }
        
    }
    
    func getDateForLabel(labelDate : Int, day : String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        let currentCalendar = NSCalendar.currentCalendar()
        let date = currentCalendar.dateByAddingUnit([.Day], value: labelDate, toDate: NSDate(), options: [])
        let stringDate = dateFormatter.stringFromDate(date!)
        
        return day + " " + stringDate
    }
    
    
    func getDayOfWeek()->Int? {
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar?.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents?.weekday
        return weekDay
    }
    
    func firstDayOfWeekFromDate() {
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        let date = NSDate()
        let currentDateComponents = calendar.components([.YearForWeekOfYear, .WeekOfYear ], fromDate: date)
        let startOfWeek = calendar.dateFromComponents(currentDateComponents)
        var startDate : NSDate?
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfWeek, interval: nil, forDate: date)
    }
    
}
