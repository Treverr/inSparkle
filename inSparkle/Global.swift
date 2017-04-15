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
import NVActivityIndicatorView
import NetworkExtension
import UIKit

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
    
    static var timeInObject : Date!
    
    static var timeOutObject : Date!
    
    static var employeeName : String!
    
    static var timeOfPunch : Date!
    
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
    
    static var inTime : Date?
    
    static var outTime : Date?
    
    static var hours : Double?
    
    static var timeObj : PFObject!
}

class EditTimePunchesDatePicker: NSObject {
    
    static var dateToPass : Date!
    
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
    
    static var startDate : Date?
    
    static var endDate : Date?
    
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

class SelectedDatesTimeAway : NSObject {
    
    static var selectedDates : [Date]! = []
    
}

class PFConfigs : NSObject {
    
    static var config : PFConfig!
    
    static var globalMessage : String!
    
}

class QRLogInData : NSObject {
    
    static var username : String!
    
    static var password : String!
    
}

class StaticViews : NSObject {
    
    static var masterView : UIViewController!
    
    static var messageTableView : UITableViewController!
    
}

class StaticEmployees : NSObject {
    
    static var Tom : Employee!
    
}

class Barcode {
    
    class func fromString(_ string : String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
}

class SparkleTimeZone {
    
    static var timeZone : TimeZone!
    
}

class ManagerOverride {
    
    static var image : UIImage!
    
}


struct AppUtility {
    
    // This method will force you to use base on how you configure.
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    // This method done pretty well where we can use this for best user experience.
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}


class GlobalFunctions {
    
    class func expenseLog(expenseItem : ExpenseItem, logReason: String, completion: @escaping (_ saveComplete : Bool, _ error : Error?) -> Void) {
        let log = ExpenseLog()
        log.employee = EmployeeData.universalEmployee
        log.expenseObject = expenseItem
        log.logReason = logReason
        log.saveInBackground { (success, error) in
            if error == nil && success {
                completion(true, nil)
            } else if error != nil {
                completion(false, error)
            } else if success == false {
                completion(false, error)
            }
        }
    }
    
    func stringFromDateFullStyle(_ theDate : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.full
        formatter.timeStyle = DateFormatter.Style.none
        formatter.timeZone = SparkleTimeZone.timeZone
        let dateString = formatter.string(from: theDate)
        
        return dateString
    }
    
    func stringFromDateShortStyle(_ theDate : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.none
        formatter.timeZone = SparkleTimeZone.timeZone
        let dateString = formatter.string(from: theDate)
        
        return dateString
    }
    
    func stringFromDateShortStyleNoTimezone(_ theDate : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.none
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: theDate)
        
        return dateString
    }
    
    func stringFromDateShortTimeShortDate(_ theDate : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = SparkleTimeZone.timeZone
        let dateString = formatter.string(from: theDate)
        
        return dateString
    }
    
    func dateFromShortDateString(_ dateString : String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        formatter.timeZone = SparkleTimeZone.timeZone
        let theReturn = formatter.date(from: dateString)
        
        return theReturn!
    }
    
    func dateFromMediumDateString(_ dateString : String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.timeZone = SparkleTimeZone.timeZone
        let theReturn = formatter.date(from: dateString)
        
        return theReturn!
    }
    
    func dateFromShortDateShortTime(_ dateString : String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy, h:mm a"
        formatter.timeZone = SparkleTimeZone.timeZone
        let theReturn = formatter.date(from: dateString)
        
        return theReturn!
    }
    
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = URL(fileURLWithPath: path!)
        var audioPlayer : AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("NO AUDIO PLAYER")
        }
        
        return audioPlayer!
    }
    
    func updateWeeksAppts() {
        let now = Date()
        let sevenDaysAgo = now.addingTimeInterval(-7*24*60*60)
        
        let weekQuery = WeekList.query()
        weekQuery?.whereKey("weekEnd", greaterThanOrEqualTo: sevenDaysAgo)
        weekQuery?.findObjectsInBackground(block: { (allWeeks : [PFObject]?, error : Error?) in
            if error == nil {
                let listOfWeeks = allWeeks as! [WeekList]
                for week in listOfWeeks {
                    let scheduleQuery = ScheduleObject.query()
                    scheduleQuery!.whereKey("weekObj", equalTo: week)
                    scheduleQuery?.findObjectsInBackground(block: { (foundWeeks : [PFObject]?, error : Error?) in
                        if error == nil {
                            let numberSch = foundWeeks!.count
                            week.apptsRemain = (week.maxAppts - numberSch)
                            week.numApptsSch = numberSch
                            week.saveInBackground()
                        }
                    })
                }
            }
        })
        
    }
    
    func RandomInt(min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
    
    func isMorning(_ date: Date) -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let startMorning = (calendar as NSCalendar).date(bySettingHour: 6, minute: 0, second: 0, of: date, options: NSCalendar.Options(rawValue: 0))
        let endMorning =  (calendar as NSCalendar).date(bySettingHour: 10, minute: 0, second: 0, of: date, options: NSCalendar.Options(rawValue: 0))
        if startMorning!.compare(date) == .orderedAscending && endMorning!.compare(date) == .orderedDescending {
            return true
        }
        return false
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func callNumber(_ phoneNumber : String) {
        let stringArray = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let unformattedPhoneNumber = stringArray.joined(separator: "")
        if var phoneCallURL : URL = URL(string: "tel://\(unformattedPhoneNumber)") {
            let application : UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL)
            } else {
                phoneCallURL = URL(string: "facetime://\(unformattedPhoneNumber)")!
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL)
                }
            }
        }
    }
    
    func loadingAnimation(_ loadingUI : NVActivityIndicatorView?, loadingBG : UIView, view : UIView, navController : UINavigationController) -> (NVActivityIndicatorView, UIView) {
        var loadUI = loadingUI
        let loadBG = loadingBG
        let x = (navController.view.frame.size.width / 2)
        let y = (navController.view.frame.size.height / 2)
        
        loadUI = NVActivityIndicatorView(frame: CGRect(x: x, y: y, width: 100, height: 100))
        loadUI!.center = CGPoint(x: view.frame.size.width  / 2,
                                    y: view.frame.size.height / 2)
        
        loadBG.backgroundColor = UIColor.lightGray
        loadBG.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        loadBG.center = navController.view.center
        loadBG.layer.cornerRadius = 5
        loadBG.layer.opacity = 0.5
        navController.view.addSubview(loadBG)
        navController.view.addSubview(loadUI!)
        
        loadUI!.type = .ballRotateChase
        loadUI!.color = UIColor.white
        loadUI!.startAnimating()
        
        return (loadUI!, loadBG)
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func displayAlertOverMainWindow(alert : UIAlertController) {
        repeat {
            if UIApplication.shared.keyWindow?.rootViewController != nil {
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        } while UIApplication.shared.keyWindow?.rootViewController == nil
    }
    
    func printToPrinter(_ item : AnyObject, printInfo : UIPrintInfo, view : UIViewController) {
        
        func completePrint(_ printer : UIPrinter) {
            let printInteraction = UIPrintInteractionController.shared
            
            printInteraction.printingItem = item
            printInteraction.printInfo = printInfo
            
            printInteraction.print(to: printer, completionHandler: { (printerController, completed, error) in
                if completed {
                    let alert = UIAlertController(title: "Printed!", message: nil, preferredStyle: .alert)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    let delay = 1.0 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        alert.dismiss(animated: true, completion: {
                            view.dismiss(animated: false, completion: nil)
                        })
                    })
                }
            })
        }
        
        if UserDefaults.standard.url(forKey: "printer") != nil {
            var printer = UIPrinter(url: UserDefaults.standard.url(forKey: "printer")!)
            printer.contactPrinter { (available) in
                if available {
                    completePrint(printer)
                } else {
                    let alert = UIAlertController(title: "Printer Unavailable", message: "The printer is unavailable, would you like to print to the office printer via VPN? \nEnable VPN in settings before attemptng to print", preferredStyle: .alert)
                    let yesThisTimeOnly = UIAlertAction(title: "Yes, This Time Only", style: .default, handler: { (action) in
                        printer = UIPrinter(url: URL(string: "ipp://10.0.1.50:10631/printers/Work")!)
                        printer.contactPrinter({ (available) in
                            if available {
                                completePrint(printer)
                            }
                        })
                    })
                    let yesSetSelected = UIAlertAction(title: "Yes, Set as Selected", style: .default, handler: { (action) in
                        UserDefaults.standard.set(URL(string: "ipp://10.0.1.50:10631/printers/Work")!, forKey: "printer")
                        printer = UIPrinter(url: URL(string: "ipp://10.0.1.50:10631/printers/Work")!)
                        printer.contactPrinter({ (available) in
                            if available {
                                completePrint(printer)
                            }
                        })
                    })
                    let no = UIAlertAction(title: "No", style: .default, handler: nil)
                    alert.addAction(yesThisTimeOnly)
                    alert.addAction(yesSetSelected)
                    alert.addAction(no)
                    UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            view.dismiss(animated: false, completion: nil)
            let alert = UIAlertController(title: "Select Printer", message: "\nPlease select a printer in the More section and then try your print again", preferredStyle: .alert)
            let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okayButton)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkLogin() {
        PFSession.getCurrentSessionInBackground { (session : PFSession?, error : Error?) in
            if error != nil {
                PFUser.logOut()
                let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
                UIApplication.shared.keyWindow!.rootViewController!.present(viewController, animated: true, completion: nil)
            } else {
                let currentUser : PFUser?
                
                currentUser = PFUser.current()
                let currentSession = PFUser.current()?.sessionToken
                
                if (currentUser == nil) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
                        UIApplication.shared.keyWindow!.rootViewController!.present(viewController, animated: true, completion: nil)
                    })
                }
                
                if (currentUser?.sessionToken == nil) {
                    PFUser.logOut()
                    let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
                    UIApplication.shared.keyWindow!.rootViewController!.present(viewController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func requestOverride(overrideReason : String, notificationName : Notification.Name) {
        
        captureScreen { (image) in
            ManagerOverride.image = image
            
            let vc = UIStoryboard(name: "ManagerOverride", bundle: nil).instantiateViewController(withIdentifier: "overrideNav") as! UINavigationController
            let over = vc.viewControllers.first as! ManagerOverrideViewController
            let _ = over.view
            over.overrideReason.text = "inSparkle requires you to find a manager to override " + overrideReason
            over.notifyName = notificationName
            over.modalPresentationStyle = .overCurrentContext
            UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
        }
    }
    
}

func captureScreen(completion: @escaping (UIImage) -> ()) {
    let view = UIApplication.shared.keyWindow!.currentViewController()!.view!
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    completion(image!)
}

class UnderlinedLabel: UILabel {
    
    override var text: String! {
        
        didSet {
            let textRange = NSMakeRange(0, text.characters.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            
            
            self.attributedText = attributedText
        }
    }
}

extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
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

extension Date {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInDays) as NSDate
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.addingTimeInterval(secondsInHours) as NSDate
        
        //Return Result
        return dateWithHoursAdded
    }
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())
    }
}

extension UINavigationController {
    func setupNavigationbar(_ vc : UINavigationController)  {
        vc.navigationBar.barTintColor = Colors.sparkleBlue
        vc.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        vc.navigationBar.barStyle = UIBarStyle.black
    }
}

extension UIViewController {
    
    func displayError(_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

}

extension UIImage {
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
