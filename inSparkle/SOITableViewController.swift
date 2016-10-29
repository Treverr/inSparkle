//
//  SOITableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

protocol sendObjectDelegate
{
    func sendObject(_ sendingObject : PFObject)
}

class SOITableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    var objects : NSMutableArray = []
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.size.height), animated: false)
        
        searchBar.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = Colors.sparkleGreen
        self.refreshControl!.tintColor = UIColor.white
        self.refreshControl!.addTarget(self, action: #selector(SOITableViewController.refreshInvoked), for: .valueChanged)
        
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SOITableViewController.RefreshSOI(_:)), name: NSNotification.Name(rawValue: "RefreshSOINotification"), object: nil)
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        getParseItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func capCustomerName() {
        
        let query = SOIObject.query()
        query?.findObjectsInBackground(block: { (objects : [PFObject]?, error : Error?) in
            for obj in objects! {
                let soi = obj as! SOIObject
                soi.customerName = soi.customerName.capitalized
            }
            PFObject.saveAll(inBackground: objects)
        })
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (editing) {
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(SOITableViewController.deleteParseObject))
            self.navigationItem.leftBarButtonItem = deleteButton
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SOITableViewController.segToAdd))
            self.navigationItem.leftBarButtonItem = addButton
        }
    }
    
    func segToAdd() {
        let sb = UIStoryboard(name: "SOI", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "addToSOINav")
        self.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "soiCell") as! SOITableViewCell
        
        let object = objects.object(at: (indexPath as NSIndexPath).row)
        
        let customerName = (object as AnyObject).value(forKey: "customerName") as! String
        let date = (object as AnyObject).value(forKey: "date") as? Date
        let location = (object as AnyObject).value(forKey: "location") as! String
        let item = (object as AnyObject).value(forKey: "category") as! String
        
        cell.soiCell(customerName, date: date, location: location, item: item)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var objectsToDelete = [IndexPath]()
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if tableView.indexPathsForSelectedRows != nil {
                objectsToDelete = tableView.indexPathsForSelectedRows!
                self.objects.removeObject(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: objectsToDelete, with: UITableViewRowAnimation.automatic)
                deleteParseObject()
            } else {
                objectsToDelete.append(indexPath)
                objsToDelete.append(self.objects[(indexPath as NSIndexPath).row] as! PFObject)
                self.objects.removeObject(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: objectsToDelete, with: UITableViewRowAnimation.automatic)
                deleteParseObject()
            }
        }
    }
    
    func getParseItems() {
        
        let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.view, navController: self.navigationController!)
        loadingUI = returnUI
        loadingBackground = returnBG
        
        let query = PFQuery(className: "SOI")
        query.whereKey("isActive", equalTo: true)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (foundObjects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let foundObjectsCount = foundObjects!.count
                for object in foundObjects! {
                    self.objects.add(object)
                    UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
                        self.tableView.reloadData()
                        }, completion: nil)
                }
                self.loadingBackground.removeFromSuperview()
                self.loadingUI.stopAnimating()
                if (foundObjectsCount - self.objects.count) == 0 {
                    if (self.refreshControl!.isRefreshing) {
                        self.refreshControl?.endRefreshing()
                        self.loadingBackground.removeFromSuperview()
                        self.loadingUI.stopAnimating()
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func deleteParseObject() {
        
        for obj in objsToDelete {
            obj["isActive"] = false
            do {
                try obj.save()
            } catch { }
        }
        self.objects.removeAllObjects()
        getParseItems()
        self.tableView.reloadData()
        
    }
    
    func RefreshSOI(_ notification : Notification) {
        self.objects.removeAllObjects()
        getParseItems()
        self.tableView.reloadData()
        
        
    }
    
    func checkSessionToken() -> Bool {
        return true
    }
    
    func refreshInvoked() {
        refresh()
    }
    
    func refresh() {
        self.objects.removeAllObjects()
        UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
            }, completion: nil)
        getParseItems()
    }
    
    var objsToDelete = [PFObject]()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == false {
            let cell = tableView.cellForRow(at: indexPath)
            let object = objects[(indexPath as NSIndexPath).row] as! PFObject
            displayInformation(cell!, object: object)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if tableView.isEditing == true {
            let theObject = objects[(indexPath as NSIndexPath).row] as! PFObject
            objsToDelete.append(theObject)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            let theObject = objects[(indexPath as NSIndexPath).row] as! PFObject
            let objIndex = self.objsToDelete.index(of: theObject)
            self.objsToDelete.remove(at: objIndex!)
        }
    }
    
    
    func displayInformation(_ sender : UITableViewCell, object : PFObject) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailPopover = storyBoard.instantiateViewController(withIdentifier: "DetailPopViewControllerNav") as! UINavigationController
        detailPopover.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover : UIPopoverPresentationController = detailPopover.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        let theSendingObject = object
        DataManager.passingObject = theSendingObject
        present(detailPopover, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
}

extension SOITableViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.objects.removeAllObjects()
        self.getParseItems()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            self.objects.removeAllObjects()
            let query = PFQuery(className: "SOI")
            query.whereKey("isActive", equalTo: true)
            query.whereKey("customerName", contains: searchBar.text!.capitalized)
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { (foundObjects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    let foundObjectsCount = foundObjects!.count
                    for object in foundObjects! {
                        self.objects.add(object)
                        UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
                            self.tableView.reloadData()
                            }, completion: nil)
                    }
                    if (foundObjectsCount - self.objects.count) == 0 {
                        if (self.refreshControl!.isRefreshing) {
                            self.refreshControl?.endRefreshing()
                        }
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            self.objects.removeAllObjects()
            self.getParseItems()
        }
    }

    
}
