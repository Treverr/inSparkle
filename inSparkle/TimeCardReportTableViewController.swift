//
//  TimeCardReportTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/8/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class TimeCardReportTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "summary" {
            let vc = segue.destinationViewController as! RunTimeReportTableViewController
            vc.detail = false
        }
    }

}
