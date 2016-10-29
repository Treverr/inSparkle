//
//  ManageEmployeeSelectionViewController.swift
//  inSparkle
//
//  Created by Trever on 2/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class ManageEmployeeSelectionViewController: UIViewController {

    @IBAction func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Manage Employees"
        self.navigationController?.setupNavigationbar(self.navigationController!)
    }
    
    @IBAction func returnToManageEmpSelection(_ segue : UIStoryboardSegue) {
        
    }
}
