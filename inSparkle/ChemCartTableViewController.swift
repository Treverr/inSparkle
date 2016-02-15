//
//  ChemCartTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/13/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class ChemCartTableViewController: UITableViewController {
    
    var cart : [String]?
    var counts : [String:Int] = [:]
    @IBOutlet var checkoutButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Cart"
        
        if cart?.count == 0 {
            checkoutButton.tintColor = UIColor.grayColor()
            checkoutButton.enabled = false
        }
        
        print(cart)
        
        for item in cart! {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return counts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell")
        
        let item = cart![indexPath.row]
    
        cell!.textLabel?.text = item
        cell!.detailTextLabel?.text =  String(counts[item]!)
        cell?.detailTextLabel?.font = UIFont.boldSystemFontOfSize(16)
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "authenticateUser" {
            ChecmicalCheckoutData.cart = self.cart
        }
    }

    func checkoutChemicals(employee : Employee) {
        print(employee)
        let chemCheck = CheckoutModel()
        self.cart = ChecmicalCheckoutData.cart
        chemCheck.timeCheckedOut = NSDate()
        chemCheck.chemicalsCheckedOut = cart!
        chemCheck.employee = employee
        chemCheck.saveInBackgroundWithBlock { (success : Bool, error : NSError?) in
            if (success) {
                NSNotificationCenter.defaultCenter().postNotificationName("ClearChemCart", object: nil)
                ChecmicalCheckoutData.cart = nil
            }
        }
    }
}
