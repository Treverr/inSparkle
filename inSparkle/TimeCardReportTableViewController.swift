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
        
        self.navigationController?.setupNavigationbar(self.navigationController!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summary" {
            let vc = segue.destination as! RunTimeReportTableViewController
            vc.detail = false
        }
    }

}
