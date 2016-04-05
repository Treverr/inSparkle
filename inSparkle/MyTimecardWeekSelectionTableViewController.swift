//
//  MyTimecardWeekSelectionTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/30/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class MyTimecardWeekSelectionTableViewController: UITableViewController {
    
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    
    @IBOutlet var mondayTotal: UILabel!
    @IBOutlet var tuesdayTotal: UILabel!
    @IBOutlet var wednesdayTotal: UILabel!
    @IBOutlet var thursdayTotal: UILabel!
    @IBOutlet var fridayTotal: UILabel!
    @IBOutlet var saturdayTotal: UILabel!
    @IBOutlet var sundayTotal: UILabel!
    
    @IBOutlet var totalHoursLabel: UILabel!
    
    var weekLabels : [UILabel] = []
    var listOfDates : [NSDate] = []
    
    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            let selectedDate = cell?.textLabel?.text!.componentsSeparatedByString(" ")[1]
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            
            let sb = UIStoryboard(name: "SparkleConnect", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("dateDetail") as! DateDetailTableViewController
            vc.selectedDate = dateFormatter.dateFromString(selectedDate!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setDayLabel() {
        
        for day in weekLabels {
            switch day.text! {
            case "Monday":
                mondayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 0)
            case "Tuesday":
                tuesdayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 1)
            case "Wednesday":
                wednesdayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 2)
            case "Thursday":
                thursdayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 3)
            case "Friday":
                fridayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 4)
            case "Saturday":
                saturdayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 5)
            case "Sunday":
                sundayLabel.text! = firstDayOfWeekFromDate(day.text!, daysToAdd: 6)
                print("Sunday")
            default:
                break
            }
        }
        
        for day in weekLabels {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let dateToLookFor = dateFormatter.dateFromString(day.text!.componentsSeparatedByString(" ")[1])
            calculateTotals(dateToLookFor!, day: day.text!.componentsSeparatedByString(" ")[0])
        }
    }
    
    func firstDayOfWeekFromDate(day : String, daysToAdd: Int) -> String {
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        let date = NSDate()
        let comps = calendar.components([.YearForWeekOfYear, .WeekOfYear], fromDate: date)
        let startOfWeek = calendar.dateFromComponents(comps)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        let currentCalendar = NSCalendar.currentCalendar()
        let dateToString = currentCalendar.dateByAddingUnit([.Day], value: daysToAdd, toDate: startOfWeek!, options: [])
        let stringDate = dateFormatter.stringFromDate(dateToString!)
        
        return day + " " + stringDate
    }
    
    var totalOverall : Double = 0.00
    
    func calculateTotals(date : NSDate, day : String) {
        
        let employee = EmployeeData.universalEmployee
        let query = TimePunchCalcObject.query()
        let cal = NSCalendar.currentCalendar()
        let endOfDay = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: date, options: [])
        
        query?.whereKey("employee", equalTo: employee)
        query?.whereKey("timePunchedIn", greaterThan: date)
        query?.whereKey("timePunchedOut", lessThan: endOfDay!)
        query?.findObjectsInBackgroundWithBlock({ (timeCalcs : [PFObject]?, error : NSError?) in
            if error == nil {
                var totalForDate : Double = 0.00
                for calc in timeCalcs! {
                    let theCalc = calc as! TimePunchCalcObject
                    totalForDate = totalForDate + theCalc.totalTime
                    self.totalOverall = self.totalOverall + totalForDate
                }
                let vacaQuery = VacationTimePunch.query()
                vacaQuery?.whereKey("employee", equalTo: employee)
                vacaQuery?.whereKey("vacationDate", greaterThanOrEqualTo: date)
                vacaQuery?.whereKey("vacationDate", lessThan: endOfDay!)
                do {
                    let vaca = try vacaQuery?.findObjects()
                    
                    if vaca?.count > 0 {
                        let vacationObj = vaca?.first as! VacationTimePunch
                        totalForDate = vacationObj.vacationHours
                        self.totalOverall = self.totalOverall + vacationObj.vacationHours
                        switch day {
                        case "Monday":
                            self.mondayTotal.text = String(totalForDate)
                        case "Tuesday":
                            self.tuesdayTotal.text = String(totalForDate)
                        case "Wednesday":
                            self.wednesdayTotal.text = String(totalForDate)
                        case "Thursday":
                            self.thursdayTotal.text = String(totalForDate)
                        case "Friday":
                            self.fridayTotal.text = String(totalForDate)
                        case "Saturday":
                            self.saturdayTotal.text = String(totalForDate)
                        case "Sunday":
                            self.sundayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        default:
                            break
                        }
                    } else {
                        switch day {
                        case "Monday":
                            self.mondayTotal.text = String(totalForDate)
                        case "Tuesday":
                            self.tuesdayTotal.text = String(totalForDate)
                        case "Wednesday":
                            self.wednesdayTotal.text = String(totalForDate)
                        case "Thursday":
                            self.thursdayTotal.text = String(totalForDate)
                        case "Friday":
                            self.fridayTotal.text = String(totalForDate)
                        case "Saturday":
                            self.saturdayTotal.text = String(totalForDate)
                        case "Sunday":
                            self.sundayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        default:
                            break
                        }
                    }
                } catch { }
                
            }
        })
    }
}
