//
//  POCRunReportFinalTableViewController.swift
//  
//
//  Created by Trever on 12/15/15.
//
//

import UIKit

class POCRunReportFinalTableViewController: UITableViewController {
    
    var theFilter = POCReportFilters.filter
    
    var customerFilter = "String"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(theFilter)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
