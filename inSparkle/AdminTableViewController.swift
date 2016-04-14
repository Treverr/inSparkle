//
//  AdminTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/8/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class AdminTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)

    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
