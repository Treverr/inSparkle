//
//  SelectedDatesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/1/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import SwiftMoment

class SelectedDatesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize.height = CGFloat( (SelectedDatesTimeAway.selectedDates.count * 44) + 26 )
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(SelectedDatesTimeAway.selectedDates.count)
        return SelectedDatesTimeAway.selectedDates.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "headerCell")

            return cell!
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "dateCell")! as! SelectedDatesTableViewCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            cell.dateLabel.text = dateFormatter.string(from: SelectedDatesTimeAway.selectedDates[((indexPath as NSIndexPath).row - 1)] as Date)
            cell.fullDaySwitch.setOn(true, animated: false)
            cell.fullDaySwitch.tag = ((indexPath as NSIndexPath).row - 1)
            cell.fullDaySwitch.addTarget(self, action: #selector(SelectedDatesTableViewController.notFullDay(_:)), for: .valueChanged)
            cell.hoursTextField.text = String(8)
            cell.hoursTextField.tag = ((indexPath as NSIndexPath).row - 1)
            cell.hoursTextField.isUserInteractionEnabled = false
            cell.hoursTextField.delegate = self
            
            return cell
        }
    }
    
    func notFullDay(_ sender : UISwitch) {
        _ = sender.tag
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag + 1, section: 0)) as! SelectedDatesTableViewCell
        
        if sender.isOn {
            cell.hoursTextField.isUserInteractionEnabled = false
            cell.hoursTextField.text = String(8)
            cell.hoursTextField.resignFirstResponder()
        } else {
            cell.hoursTextField.isUserInteractionEnabled = true
            cell.hoursTextField.text = nil
            cell.hoursTextField.becomeFirstResponder()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return 26
        } else {
            return 44
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        SelectedDatesTimeAway.selectedDates = []
    }
    
}

extension SelectedDatesTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var total : Double = 0
        if !textField.text!.isEmpty {
            let rounded = round(Double(textField.text!)! * 2) / 2
            textField.text = String(rounded)
            
            var cells = self.tableView.visibleCells
            cells.removeFirst()
            
            for cell in cells {
                let theCell = cell as! SelectedDatesTableViewCell
                total = total + Double(theCell.hoursTextField.text!)!
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateTotalNumberOfHours"), object: total)
        } else {
            textField.text = String(8)
        }
    }
    
}
