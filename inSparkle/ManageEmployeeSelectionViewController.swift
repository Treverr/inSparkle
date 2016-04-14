//
//  ManageEmployeeSelectionViewController.swift
//  inSparkle
//
//  Created by Trever on 2/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class ManageEmployeeSelectionViewController: UIViewController {

    @IBAction func dismissAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Manage Employees"
        self.navigationController?.setupNavigationbar(self.navigationController!)
    }
    
    @IBAction func returnToManageEmpSelection(segue : UIStoryboardSegue) {
        
    }
}
