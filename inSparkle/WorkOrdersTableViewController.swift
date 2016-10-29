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
        self.tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.size.height), animated: false)
        
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if searchActive {
            searchForFilter(searchBar.text!)
        } else {
            
            let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.view, navController: self.navigationController!)
            loadingUI = returnUI
            loadingBackground = returnBG

            getWorkOrders()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return theWorkOrders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workOrder") as! WorkOrdersMainTableViewCell
        
        let customerName = theWorkOrders[(indexPath as NSIndexPath).row].customerName
        let dateCreated = theWorkOrders[(indexPath as NSIndexPath).row].date
        let theStatus = theWorkOrders[(indexPath as NSIndexPath).row].status
        
        cell.customerNameLabel.text = customerName
        cell.dateCreatedLabel.text = GlobalFunctions().stringFromDateShortStyle(dateCreated!)
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
        query?.order(byDescending: "date")
        query?.limit = 1000
        query?.findObjectsInBackground(block: { (workOrders : [PFObject]?, error :Error?) in
            if error == nil {
                self.theWorkOrders = workOrders as! [WorkOrders]
                self.tableView.reloadData()
                self.loadingUI.stopAnimating()
                self.loadingBackground.removeFromSuperview()
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "existing" {
            let selected = theWorkOrders[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
            let dest = segue.destination as! AddEditWorkOrderTableViewController
            dest.workOrderObject = selected
        }
    }
    
    @IBAction func unwindToWOMain(_ segue : UIStoryboardSegue) {
        
    }
    
}

extension WorkOrdersTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        if !(searchBar.text?.isEmpty)! {
            searchForFilter(searchBar.text!)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        searchActive = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        getWorkOrders()
    }
    
    func searchForFilter(_ searchText : String) {
        let searchCustomerName = WorkOrders.query()
        searchCustomerName?.whereKey("customerName", contains: searchText.capitalized)
        
        let searchCustomerAddy = WorkOrders.query()
        searchCustomerAddy?.whereKey("customerAddress", contains: searchText.capitalized)
        
        let searchQuery = PFQuery.orQuery(withSubqueries: [searchCustomerName!, searchCustomerAddy!])
        searchQuery.findObjectsInBackground { (foundForSearch : [PFObject]?, error : Error?) in
            if error == nil {
                self.theWorkOrders = foundForSearch as! [WorkOrders]
            }
            self.tableView.reloadData()
        }
    }
    
}
