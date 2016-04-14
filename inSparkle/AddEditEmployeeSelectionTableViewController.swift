//
//  AddEditEmployeeSelectionTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class AddEditEmployeeSelectionTableViewController: UITableViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Punches for: " + AddEditEmpTimeCard.employeeEditing
        
        self.navigationController?.setupNavigationbar(self.navigationController!)

    }

}
