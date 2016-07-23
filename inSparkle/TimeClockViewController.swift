//
//  TimeClockViewController.swift
//  inSparkle
//
//  Created by Trever on 12/6/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import BRYXBanner

class TimeClockViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var timeClockTextField: UITextField!
    
    var audioPlayer : AVAudioPlayer = AVAudioPlayer()

    var lastPunch : TimeClockPunchObj? = nil
    var lunchResult: Bool?
    var pinString : String! = ""
    var timeTimer = NSTimer()
    var incorrectAttempts = 0
    var employees : [Employee]!
    
    @IBOutlet var currentTime: UILabel!
    @IBOutlet var currentDate: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var theTabBar: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRectMake(0, 44, self.view.frame.width , self.view.frame.height)
        
        audioPlayer = GlobalFunctions().setupAudioPlayerWithFile("TimeClockPunch", type: "wav")
        audioPlayer.prepareToPlay()
        
        currentTime.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
        currentDate.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .FullStyle, timeStyle: .NoStyle)
        
        self.timeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick", userInfo: nil, repeats: true)
        
        timeClockTextField.delegate = self
        
        timeClockTextField.attributedPlaceholder = NSAttributedString(string:"- - - -",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func closeTimeClock(sender : AnyObject) {
        
    self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    @IBAction func number1(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "1")
        checkField()
    }
    
    @IBAction func number2(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "2")
        checkField()
        
    }
    
    @IBAction func number3(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "3")
        checkField()
        
    }
    
    @IBAction func number4(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "4")
        checkField()
    }
    
    @IBAction func number5(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "5")
        checkField()
    }
    
    @IBAction func number6(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "6")
        checkField()
    }
    
    @IBAction func number7(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "7")
        checkField()
    }
    
    @IBAction func number8(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "8")
        checkField()
    }
    
    @IBAction func number9(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "9")
        checkField()
    }
    
    @IBAction func number0(sender: AnyObject) {
        timeClockTextField.text = (timeClockTextField.text! + "• ")
        pinString = (pinString + "0")
        checkField()
    }
    
    var timeOutTimer : NSTimer!
    
    func checkField() {
        if timeClockTextField.text?.characters.count == 8 {
            authenticateEmployee()
        }
        
        if timeOutTimer == nil {
            timeOutTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("deleteButton:"), userInfo: nil, repeats: false)
        }
        
    }
    
    @IBAction func deleteButton(sender: AnyObject) {
        timeClockTextField.text = ""
        pinString = ""
        
        if timeOutTimer != nil {
            timeOutTimer.invalidate()
            timeOutTimer = nil
        }
        
    }
    
    func authenticateEmployee() {
        if timeOutTimer != nil {
            timeOutTimer.invalidate()
            timeOutTimer = nil
        }
        var tcpo = TimeClockPunchObj()
        let empQuery = PFQuery(className: Employee.parseClassName())
        let pinToCheck = pinString
        empQuery.whereKey("pinNumber", equalTo: pinToCheck!)
        empQuery.findObjectsInBackgroundWithBlock { (employees :[PFObject]?, error : NSError?) -> Void in
            if employees?.count != 0 && employees != nil {
                let theEmployee = employees?.first
                print(theEmployee)
                tcpo.employee = theEmployee as! Employee
                tcpo.timePunched = NSDate()

                let midnightToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
                let inOutQuery = PFQuery(className: TimeClockPunchObj.parseClassName())
                inOutQuery.whereKey("timePunched", greaterThan: midnightToday)
                inOutQuery.whereKey("employee", equalTo: theEmployee!)
                inOutQuery.orderByAscending("timePunched")
                inOutQuery.findObjectsInBackgroundWithBlock({ (punches: [PFObject]?, error:NSError?) -> Void in
                    if punches != nil && punches?.count != 0 {
                        self.lastPunch = punches!.last! as! TimeClockPunchObj
                    }
                    if punches?.count == 0 || punches == nil || self.lastPunch?.valueForKey("punchOutIn") as! String == "out" {
                        tcpo.punchOutIn = "in"
                        tcpo.saveEventually({ (success : Bool, error:NSError?) -> Void in
                            if (success) {
                                self.SetTimeInClockData(theEmployee as! Employee, timePunch: tcpo)
                            } else {
                                self.errorBanner()
                            }
                        })
                    } else {
                        tcpo.punchOutIn = "out"
                        tcpo.relatedPunch = self.lastPunch!
                        self.lastPunch?.relatedPunch = tcpo
                        tcpo.saveEventually()
                        self.lastPunch?.saveEventually()
                        self.didTakeLunch(theEmployee as! Employee, tcpo: tcpo)
                    }
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    self.deleteButton(self)
                })
                
            } else {
                if employees?.count == 0 {
                    self.incorrectPIN()
                    self.deleteButton(self)
                    self.incorrectAttempts + 1
                    if self.incorrectAttempts == 3 {
                        // trdd
                    }
                }
                if error != nil {
                    switch error!.code {
                    case 100:
                        let alert = UIAlertController(title: "Error", message: "The Internet connection appears to be offline.\n" + "\n" +
                            "Please notify managment.", preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.deleteButton(self)
                    default:
                        break
                    }
                }
                
            }
        }
    }
    
    func calculateTime(theEmployee : Employee, thePunch : TimeClockPunchObj) {
        
        if thePunch.valueForKey("punchOutIn") as! String == "out" {
      
            let theLastPunchDate = self.lastPunch?.valueForKey("timePunched") as! NSDate
            var theMinutes = NSDate().minutesFrom(theLastPunchDate)
            if theMinutes > 240 {
                theMinutes = theMinutes - 20
            }
            print(theMinutes)
            let hours = String(format: "%.2f", (Double(theMinutes) / 60.00))
            print(hours)
            
            let timeCalc = TimePunchCalcObject()
            timeCalc.employee = theEmployee
            timeCalc.timePunchedIn = self.lastPunch?.valueForKey("timePunched") as! NSDate
            timeCalc.timePunchedOut = thePunch.valueForKey("timePunched") as! NSDate
            timeCalc.totalTime = Double(hours)!
            self.lastPunch?.relatedTimeCalc = timeCalc
            if Double(hours)! > 0.00 {
                timeCalc.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
                    if success == true {
                        self.setTimeOutClockData(theEmployee, timePunch: thePunch, hours: hours)
                        self.lastPunch?.saveInBackground()
                        print(timeCalc)
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            thePunch.relatedTimeCalc = timeCalc
                            thePunch.saveInBackground()
                        }
                    } else {
                        self.errorBanner()
                    }
                })
            } else {
                thePunch.deleteInBackground()
                let banner = Banner(title: "You were clocked in for less than 1 minute. The punch was recorded, but will not reflect any worked time.", subtitle: nil, image: nil, backgroundColor: UIColor.orangeColor(), didTapBlock: nil)
                banner.dismissesOnSwipe = false
                banner.dismissesOnTap = false
                banner.show(duration: 3.0)
            }
        }
    }
    
    func didTakeLunch(theEmployee : Employee, tcpo : TimeClockPunchObj) {
        var result : Bool = false
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.calculateTime(theEmployee as! Employee, thePunch: tcpo)
        }
        
    }
    
    func errorBanner() {
        let banner = Banner(title: "There was an error recording your punch.", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
        banner.dismissesOnTap = false
        banner.dismissesOnSwipe = false
        banner.show(duration: 5.0)
    }
    
    func incorrectPIN() {
        let banner = Banner(title: "Unable to authenticate with the entered pin, try again.", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
        banner.dismissesOnTap = false
        banner.dismissesOnSwipe = false
        banner.show(duration: 2.0)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func displayClockInConfirm(emp : Employee, timePunch: TimeClockPunchObj) {

        let x = self.view.center
        let timeStory = UIStoryboard(name: "TimeClock", bundle: nil)
        let confirmPopOver = timeStory.instantiateViewControllerWithIdentifier("ConfirmPunchIn")
        confirmPopOver.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = confirmPopOver.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRectMake(((x.x) - 25), x.y, 0, 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.presentViewController(confirmPopOver, animated: true, completion: nil)
        self.audioPlayer.play()
    }
    
    func displayClockOutConfirm(emp : Employee, timePunch : TimeClockPunchObj) {
        let x = self.view.center
        let timeStory = UIStoryboard(name: "TimeClock", bundle: nil)
        let confirmPopOver = timeStory.instantiateViewControllerWithIdentifier("ConfirmPunchOut")
        confirmPopOver.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = confirmPopOver.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRectMake(((x.x) - 25), x.y, 0, 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.presentViewController(confirmPopOver, animated: true, completion: nil)
        self.audioPlayer.play()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.audioPlayer.play()
        }
    }
    
    func setTimeOutClockData(emp : Employee, timePunch: TimeClockPunchObj, hours : String) {
        print(timePunch)
        let employeeName = emp.firstName + " " + emp.lastName
        let timeIn = lastPunch!.timePunched
        let timeOut = timePunch.timePunched
        let theHours = hours
        
        TimeClock.timeInObject = timeIn
        TimeClock.timeOutObject = timeOut
        TimeClock.employeeName = employeeName
        TimeClock.totalHours = theHours
        TimeClock.timeOfPunch = timePunch.timePunched
        
        self.displayClockOutConfirm(emp, timePunch: timePunch)
    }
    
    func SetTimeInClockData(emp : Employee, timePunch: TimeClockPunchObj) {
        let employeeName = emp.firstName + " " + emp.lastName
        let thePunch = timePunch.timePunched
        
        TimeClock.employeeName = employeeName
        TimeClock.timeOfPunch = thePunch
        
        self.displayClockInConfirm(emp, timePunch: timePunch)
        
    }
    
    func tick() {
        currentTime.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
        currentDate.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .FullStyle, timeStyle: .NoStyle)
    }
    

}
