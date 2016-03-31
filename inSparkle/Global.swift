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
import CoreImage
import SVProgressHUD

class DataManager: NSObject {
    
    static var passingObject : PFObject!
    
    static var isEditingSOIbject : Bool!
    
    static var lastUsedTypeSegment : Int!
      
}

class JokeDictionary : NSObject {
    
    static var jokesDict : [String : String] = [
        
        "What detergent do swimmers use to wash their wet suit?" : "Tide!",
        
        "What kind of stroke can you use on toast?" : "BUTTER-fly!",
        
        "What kind of exercises are best for a swimmer?" : "Pool-Ups!",
        
        "How do people swimming in the ocean say 'HI' to each other?" : "They Wave!",
        
        "What stroke do sheep enjoy doing?" : "The baaaackstroke!",
        
        "Why won't they allow elephants in public swimming pools?" : "Because they might let down their trunks.",
        
        "How do you know if your swimming pool needs cleaning?" : "Kids still pee in your pool, but they refuse to get in it first.",
        
        "Did you know: Titanic was the first ocean liner to have a swimming pool and a gym." : "All done!",
        
        "Did you know: Elephants are capable of swimming twenty miles a day. They use their trunks as natural snorkles." : "Sorry about that wait!",
        
        "Did you know: Niagara Falls has enough water to fill up all the swimming pools in the United States in less than three days!" : "That's alota waaata.",
        
        "65% of people in the U.S. don’t know how to swim" : "Those poor people. 😞",
        
        "Did you know: Florida is the only state with legislation on who can teach swimming. Life guards and swimming instructors must, by law, be certified." : "Yikes"
        
    ]
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
    
    static var universalEmployee : Employee!
    
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

class POCReportData : NSObject {
    
    static var POCData : [ScheduleObject]!
    
}

class ChecmicalCheckoutData : NSObject {
    
    static var cart : [String]!
    
}

class Barcode {
    
    class func fromString(string : String) -> UIImage? {
        
        let data = string.dataUsingEncoding(NSASCIIStringEncoding)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransformMakeScale(3, 3)
            
            if let output = filter.outputImage?.imageByApplyingTransform(transform) {
                return UIImage(CIImage: output)
            }
        }
        return nil
    }
    
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
    
    func stringFromDateShortTimeShortDate(theDate : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
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
    
    func dateFromShortDateShortTime(dateString : String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy, h:mm a"
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
    
    func updateWeekData(currentSelectedWeek : WeekList, openingWeek : Bool, joke : String) {
        
        var weeks = [WeekList]()
        let weekQuery = WeekList.query()
        var weekCount = 0
        let now = NSDate()
        let sevenDaysAgo = now.dateByAddingTimeInterval(-7*24*60*60)
        weekQuery?.whereKey("isOpenWeek", equalTo: openingWeek)
        weekQuery?.whereKey("weekStart", greaterThan: sevenDaysAgo)
        weekQuery?.countObjectsInBackgroundWithBlock({ (counted : Int32, error : NSError?) in
            if error == nil {
                weekQuery?.findObjectsInBackgroundWithBlock({ (results : [PFObject]?, error : NSError?) in
                    if error == nil {
                        weeks = results as! [WeekList]
                        weekCount = Int(counted)
                        if weekCount - weeks.count == 0 {
                            let schQuery = ScheduleObject.query()
                            print(weeks)
                            var onNumber = 0
                            for theWeek in weeks {
                                onNumber = onNumber + 1
                                print(theWeek)
                                schQuery?.whereKey("weekObj", equalTo: theWeek)
                                var error = NSErrorPointer()
                                var numberSch = schQuery?.countObjects(error)
                                theWeek.numApptsSch = Int(numberSch!)
                                var remain : Int = (theWeek.maxAppts - Int(numberSch!))
                                if theWeek == currentSelectedWeek {
                                    remain = remain - 1
                                }
                                theWeek.apptsRemain = remain
                                theWeek.saveInBackground()
                            }
                            SVProgressHUD.dismiss()
                            SVProgressHUD.showSuccessWithStatus(JokeDictionary.jokesDict[joke], maskType: .Black)
                        }
                    }
                })
            }
        })
    }
    
    func RandomInt(min min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
    
    func qsort(input: [String]) -> [String] {
        if let (pivot, rest) = input.decompose {
            let lesser = rest.filter { $0 < pivot }
            let greater = rest.filter { $0 >= pivot }
            return qsort(lesser) + [pivot] + qsort(greater)
        } else {
            return []
        }
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
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
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

extension NSDate {
    var startOfDay: NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(self)
    }
    
    var endOfDay: NSDate? {
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions())
    }
}

//func setupNavigationbar()  {
//    self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
//    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//    self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//}