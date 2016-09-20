//
//  WorkOrdersTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class WorkOrdersTableViewController: UITableViewController, NVActivityIndicatorViewable {
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    var theWorkOrders = [WorkOrders]()
    var filtered = [WorkOrders]()
    var searchActive = false
    let loadSize = CGSize(width: 50, height: 50)
    
    @IBOutlet var searchBar : UISearchBar!
    
    override func viewDidLoad() {
        self.tableView.setContentOffset(CGPointMake(0, searchBar.frame.size.height), animated: false)
        
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {

        if searchActive {
            searchForFilter(searchBar.text!)
        } else {
            
            let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.view, navController: self.navigationController!)
            loadingUI = returnUI
            loadingBackground = returnBG

            getWorkOrders()
            
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return theWorkOrders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("workOrder") as! WorkOrdersMainTableViewCell
        
        let customerName = theWorkOrders[indexPath.row].customerName
        let dateCreated = theWorkOrders[indexPath.row].date
        let theStatus = theWorkOrders[indexPath.row].status
        
        cell.customerNameLabel.text = customerName
        cell.dateCreatedLabel.text = GlobalFunctions().stringFromDateShortStyle(dateCreated)
        cell.statusLabel.text = theStatus!
        cell.statusLabel.sizeToFit()
        switch theStatus! {
        case "New":
            cell.iconImageView?.image = UIImage(named: "WO New")
        case "In Progress":
            cell.iconImageView?.image = UIImage(named: "WO In Progress")
        case "On Hold":
            cell.iconImageView?.image = UIImage(named: "WO On Hold")
        case "Assigned":
            cell.iconImageView?.image = UIImage(named: "WO Assinged")
        case "Completed":
            cell.iconImageView?.image = UIImage(named: "WO Completed")
        case "Billed":
            cell.iconImageView?.image = UIImage(named: "WO Billed")
        case "Ready To Bill":
            cell.iconImageView.image = UIImage(named: "WO Ready to Bill")
        case "Do not Bill":
            cell.iconImageView.image = UIImage(named: "WO Do not Bill")
        default:
            cell.iconImageView?.image = nil
        }
        
        return cell
    }
    
    func getWorkOrders() {
        let query = WorkOrders.query()
        query?.orderByDescending("date")
        query?.limit = 1000
        query?.findObjectsInBackgroundWithBlock({ (workOrders : [PFObject]?, error :NSError?) in
            if error == nil {
                self.theWorkOrders = workOrders as! [WorkOrders]
                self.tableView.reloadData()
                self.loadingUI.stopAnimation()
                self.loadingBackground.removeFromSuperview()
            }
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "existing" {
            let selected = theWorkOrders[tableView.indexPathForSelectedRow!.row]
            let dest = segue.destinationViewController as! AddEditWorkOrderTableViewController
            dest.workOrderObject = selected
        }
    }
    
    @IBAction func unwindToWOMain(segue : UIStoryboardSegue) {
        
    }
    
}

extension WorkOrdersTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
        if !(searchBar.text?.isEmpty)! {
            searchForFilter(searchBar.text!)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        searchActive = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        getWorkOrders()
    }
    
    func searchForFilter(searchText : String) {
        let searchCustomerName = WorkOrders.query()
        searchCustomerName?.whereKey("customerName", containsString: searchText.capitalizedString)
        
        let searchCustomerAddy = WorkOrders.query()
        searchCustomerAddy?.whereKey("customerAddress", containsString: searchText.capitalizedString)
        
        let searchQuery = PFQuery.orQueryWithSubqueries([searchCustomerName!, searchCustomerAddy!])
        searchQuery.findObjectsInBackgroundWithBlock { (foundForSearch : [PFObject]?, error : NSError?) in
            if error == nil {
                self.theWorkOrders = foundForSearch as! [WorkOrders]
            }
            self.tableView.reloadData()
        }
    }
    
}
