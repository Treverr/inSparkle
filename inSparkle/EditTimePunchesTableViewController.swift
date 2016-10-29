//
//  EditTimePunchesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class EditTimePunchesTableViewController: UITableViewController {
    
    var punchArray = [PFObject]()
    var theEmployee : Employee!
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    
    var cellCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditTimePunchesTableViewController.refreshTable), name: NSNotification.Name(rawValue: "NotifyEditTableViewToRefresh"), object: nil)
        
        theEmployee = AddEditEmpTimeCard.employeeEditingObject
        
        getEmployeeExisitngPunches(theEmployee)
        
        self.navigationController?.navigationBar.barTintColor = Colors.groupGrey
        
    }
    
    func getEmployeeExisitngPunches(_ emp : Employee) {
        let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.tableView, navController: self.navigationController!)
        loadingUI = returnUI
        loadingUI.frame = CGRect(x: loadingBackground.frame.width, y: loadingBackground.frame.height, width: 100, height: 100)
        loadingUI.center = loadingBackground.center
        loadingBackground = returnBG
        
        let query = TimeClockPunchObj.query()
        query?.whereKey("employee", equalTo: emp)
        query?.order(byDescending: "timePunched")
        query?.findObjectsInBackground(block: { (thePunches : [PFObject]?, error : Error?) -> Void in
            if error == nil {
                print(thePunches?.count)
                for punch in thePunches! {
                    print(punch)
                    if punch.value(forKey: "relatedTimeCalc") == nil {
                        self.punchArray.append(punch as! TimeClockPunchObj)
                    } else {
                        let timeObj = punch.object(forKey: "relatedTimeCalc") as! TimePunchCalcObject
                        do {
                            try timeObj.fetchIfNeeded()
                        } catch {
                            
                        }
                        print(timeObj)
                        if self.punchArray.last?.objectId == timeObj.objectId {
                            
                        } else {
                            self.punchArray.append(timeObj)
                        }
                    }
                    self.tableView.reloadData()
                    self.loadingUI.stopAnimating()
                    self.loadingBackground.removeFromSuperview()
                    print(self.punchArray.count)
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "punchCell")
        var theText = ""
        let thePunchForCell = punchArray[(indexPath as NSIndexPath).row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        var punchIn = ""
        var punchOut = ""
        var hours = ""
        
        let description = thePunchForCell.description
        
        if !description.contains("TimePunchTimeCalculations")  {
            let punchObj = thePunchForCell as! TimeClockPunchObj
            punchObj.fetchIfNeededInBackground(block: { (obj : PFObject?, error : Error?) -> Void in
                if error == nil && obj != nil {
                    if punchObj.punchOutIn == "in" {
                        let punchIn = formatter.string(from: punchObj.timePunched)
                        theText = "In: \(punchIn) Out : N/A"
                    }
                    if punchObj.punchOutIn == "out" {
                        let punchOut = formatter.string(from: punchObj.timePunched)
                        theText = "In: N/A Out: \(punchOut)"
                    }
                }
            })
        } else {
            let calcObj = thePunchForCell as! TimePunchCalcObject
            calcObj.fetchIfNeededInBackground(block: { (obj : PFObject?, error : Error?) -> Void in
                if error == nil && obj != nil {
                    punchIn = formatter.string(from: calcObj.timePunchedIn)
                    punchOut = formatter.string(from: calcObj.timePunchedOut)
                    theText = "In: \(punchIn) Out: \(punchOut)"
                }
            })
            
        }
        
        cell?.textLabel?.text = theText
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(punchArray.count)
        return punchArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thePunchObj = self.punchArray[(indexPath as NSIndexPath).row]
        
        let description = thePunchObj.description
        
        if !description.contains("TimePunchTimeCalculations") {
            let punchPunch = thePunchObj as! TimeClockPunchObj
            if punchPunch.punchOutIn == "in" {
                EditPunch.inTime = punchPunch.timePunched
            }
            if punchPunch.punchOutIn == "out" {
                EditPunch.outTime = punchPunch.timePunched
            }
        } else {
            let punchPunch = thePunchObj as! TimePunchCalcObject
            EditPunch.inTime = punchPunch.timePunchedIn
            EditPunch.outTime = punchPunch.timePunchedOut
            EditPunch.hours = punchPunch.totalTime
        }
        
        EditPunch.timeObj = thePunchObj
        
    }
    
    func refreshTable() {
        
        let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.punchArray.removeAll()
            self.getEmployeeExisitngPunches(self.theEmployee)
            self.tableView.reloadData()
        }
    }
}
