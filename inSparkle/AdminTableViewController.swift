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
        
        setupNavigationbar()

    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
