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
        
        self.preferredContentSize.height = CGFloat( SelectedDatesTimeAway.selectedDates.count * 44 )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(SelectedDatesTimeAway.selectedDates.count)
        return SelectedDatesTimeAway.selectedDates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("dateCell")! as UITableViewCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        cell.textLabel?.text! = dateFormatter.stringFromDate(SelectedDatesTimeAway.selectedDates[indexPath.row])
        
        return cell
    }
    
    func reloadTable() {
        self.preferredContentSize.height = CGFloat( SelectedDatesTimeAway.selectedDates.count * 44 )
        self.tableView.reloadData()
    }
    
}
