//
//  ExpenseSpliNavViewController.swift
//  inSparkle
//
//  Created by Trever on 3/1/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit

class ExpenseSplitNavViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        GlobalFunctions().requestOverride(overrideReason: "test", notificationName: Notification.string(name: "Test"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
