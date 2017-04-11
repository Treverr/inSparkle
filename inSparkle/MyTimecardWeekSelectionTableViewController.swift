//
//  MyTimecardWeekSelectionTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/30/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    var listOfDates : [Date] = []
    
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = self.tableView.cellForRow(at: indexPath)
            let selectedDate = cell?.textLabel?.text!.components(separatedBy: " ")[1]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            dateFormatter.timeZone = SparkleTimeZone.timeZone
            
            let sb = UIStoryboard(name: "SparkleConnect", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "dateDetail") as! DateDetailTableViewController
            vc.selectedDate = dateFormatter.date(from: selectedDate!)
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            dateFormatter.timeZone = SparkleTimeZone.timeZone
            let dateToLookFor = dateFormatter.date(from: day.text!.components(separatedBy: " ")[1])
            calculateTotals(dateToLookFor!, day: day.text!.components(separatedBy: " ")[0])
        }
    }
    
    func firstDayOfWeekFromDate(_ day : String, daysToAdd: Int) -> String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let date = Date()
        let comps = (calendar as NSCalendar).components([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = calendar.date(from: comps)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = SparkleTimeZone.timeZone
        
        let currentCalendar = Calendar.current
        let dateToString = (currentCalendar as NSCalendar).date(byAdding: [.day], value: daysToAdd, to: startOfWeek!, options: [])
        let stringDate = dateFormatter.string(from: dateToString!)
        
        return day + " " + stringDate
    }
    
    var totalOverall : Double = 0.00
    
    func calculateTotals(_ date : Date, day : String) {
        
        let employee = EmployeeData.universalEmployee
        let query = TimePunchCalcObject.query()
        let cal = Calendar.current
        let endOfDay = (cal as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: date, options: [])
        
        query?.whereKey("employee", equalTo: employee)
        query?.whereKey("timePunchedIn", greaterThan: date)
        query?.whereKey("timePunchedOut", lessThan: endOfDay!)
        query?.findObjectsInBackground(block: { (timeCalcs : [PFObject]?, error : Error?) in
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
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Tuesday":
                            self.tuesdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Wednesday":
                            self.wednesdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Thursday":
                            self.thursdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Friday":
                            self.fridayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Saturday":
                            self.saturdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
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
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Tuesday":
                            self.tuesdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Wednesday":
                            self.wednesdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Thursday":
                            self.thursdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Friday":
                            self.fridayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
                        case "Saturday":
                            self.saturdayTotal.text = String(totalForDate)
                            self.totalHoursLabel.text = "Total Hours: " + String(self.totalOverall)
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
