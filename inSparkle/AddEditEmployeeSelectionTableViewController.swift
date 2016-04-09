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
        
        setupNavigationbar()
        
        self.navigationItem.title = "Edit Punches for: " + AddEditEmpTimeCard.employeeEditing

    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
}
