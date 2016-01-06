//
//  Global.swift
//  inSparkle
//
//  Created by Trever on 11/19/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse
import AVFoundation

class DataManager: NSObject {
    
    static var passingObject : PFObject!
    
    static var isEditingSOIbject : Bool!
    
    static var lastUsedTypeSegment : Int!
      
}

class TimeClock : NSObject {
    
    static var timeInObject : NSDate!
    
    static var timeOutObject : NSDate!
    
    static var employeeName : String!
    
    static var timeOfPunch : NSDate!
    
    static var totalHours : String!
    
}

class TimeClockReportAllEmployee: NSObject {
    
    static var selectedStartDate : String!
    
    static var selectedEndDate : String!
    
    static var startEnd : String!
    
}

class AddEditEmpTimeCard: NSObject {
    
    static var employeeEditing : String!
    
    static var employeeEditingObject : Employee!
    
}

class EditPunch: NSObject {
    
    static var inTime : NSDate?
    
    static var outTime : NSDate?
    
    static var hours : Double?
    
    static var timeObj : PFObject!
}

class EditTimePunchesDatePicker: NSObject {
    
    static var dateToPass : NSDate!
    
    static var sender : UILabel!
}

class EmployeeData: NSObject {
    
    static var theEmployee : Employee!
    
}

class GoogleAddress: NSObject {
    
    static var address : String?
    
}

class AddEditCustomers: NSObject {
    
    static var addingCustomer : Bool!
    
    static var firstName : String!
    
    static var lastName : String!
    
    static var phoneNumber : String!
    
    static var address : String!
    
    static var theCustomer : CustomerData?
    
}

class AddNewScheduleObjects : NSObject {
    
    static var selectedCx : CustomerData?
    
    static var isOpening : Bool!
    
    static var scheduledObject : ScheduleObject?
}

class CustomerLookupObjects : NSObject {
    
    static var slectedCustomer : CustomerData?
    
    static var fromVC : String!
    
}

class ConfirmAppointData : NSObject {
    
    static var date : String!
    
}

class POCReportFilters : NSObject {
    
    static var filter = [String]()
    
    static var startDate : NSDate?
    
    static var endDate : NSDate?
    
}

class POCRunReport : NSObject {
    
    static var selectedCell : String!
    
    static var selectedDate : String!
    
}

class MessagesDataObjects : NSObject {
    
    static var selectedEmp : Employee!
    
}


class GlobalFunctions {
    
    func stringFromDateFullStyle(theDate : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        let dateString = formatter.stringFromDate(theDate)
        
        return dateString
    }
    
    func stringFromDateShortStyle(theDate : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        let dateString = formatter.stringFromDate(theDate)
        
        return dateString
    }
    
    func stringFromDateShortStyleNoTimezone(theDate : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let dateString = formatter.stringFromDate(theDate)
        
        return dateString
    }
    
    func dateFromShortDateString(dateString : String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let theReturn = formatter.dateFromString(dateString)
        
        return theReturn!
    }
    
    func dateFromMediumDateString(dateString : String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let theReturn = formatter.dateFromString(dateString)
        
        return theReturn!
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer : AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("NO AUDIO PLAYER")
        }
        
        return audioPlayer!
    }
    
    func updateWeeks() {
        var weeks = [WeekList]()
        let weekQuery = WeekList.query()
        let error = NSErrorPointer()
        let weekCount = weekQuery?.countObjects(error)
        weekQuery?.findObjectsInBackgroundWithBlock({ (results:[PFObject]?, error : NSError?) -> Void in
            if error == nil {
                for result in results! {
                    weeks.append(result as! WeekList)
                }
                if weekCount! - weeks.count == 0 {
                    let schQuery = ScheduleObject.query()
                    for theweek in weeks {
                        print(theweek)
                        schQuery?.whereKey("weekObj", equalTo: theweek)
                        var anotherError = NSErrorPointer()
                        let returned = schQuery?.countObjects(anotherError)
                        theweek.numApptsSch = returned!
                        var remain = (theweek.maxAppts - returned!)
                        if returned != 0 {
                            remain = remain - 1
                        }
                        theweek.apptsRemain = remain
                        theweek.saveInBackground()
                    }
                }
            }
        })
    }
    
    func isMorning(date: NSDate) -> Bool {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let startMorning = calendar.dateBySettingHour(6, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions(rawValue: 0))
        let endMorning =  calendar.dateBySettingHour(10, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions(rawValue: 0))
        if startMorning!.compare(date) == .OrderedAscending && endMorning!.compare(date) == .OrderedDescending {
            return true
        }
        return false
    }
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

//func setupNavigationbar()  {
//    self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
//    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//    self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//}