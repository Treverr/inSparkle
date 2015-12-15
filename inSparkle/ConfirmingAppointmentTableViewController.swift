//
//  ConfirmingAppointmentTableViewController.swift
//  
//
//  Created by Trever on 12/14/15.
//
//

import UIKit
import Parse

class ConfirmingAppointmentTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var dateLbel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDateLabel:", name: "NotifyConfirmScreenUpdateLabel", object: nil)
        
        dateLbel.userInteractionEnabled = true
        let dateLabelTapGest = UITapGestureRecognizer(target: self, action: "displayPopover")
        dateLabelTapGest.numberOfTapsRequired = 1
        dateLbel.addGestureRecognizer(dateLabelTapGest)
        
    }
    
    func displayPopover() {
        let storyboard = UIStoryboard(name: "Schedule", bundle: nil)
        let x = self.view.center
        let vc = storyboard.instantiateViewControllerWithIdentifier("confimCalDatePicker")
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRectMake((x.x - 25), x.y, 0, 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func updateDateLabel(notification : NSNotification) {
        self.dateLbel.text = notification.object as! String
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnString : String = ""
        if section == 0 {
            
            let schObj = AddNewScheduleObjects.scheduledObject!
            returnString = "Confirming Appointment for \(schObj.customerName.capitalizedString). " + "\nWeek of \(GlobalFunctions().stringFromDateShortStyle(schObj.weekStart))" + " - \(GlobalFunctions().stringFromDateShortStyle(schObj.weekEnd))"
        }
        return returnString
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
       cell.selectionStyle = .None
    }
    
    @IBAction func confirmButton(sender: AnyObject) {
        let schObj = AddNewScheduleObjects.scheduledObject!
        schObj.confirmedDate = GlobalFunctions().dateFromMediumDateString(dateLbel.text!)
        schObj.confrimed = true
        schObj.confrimedBy = PFUser.currentUser()!.username!.capitalizedString
        schObj.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
            if (success) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        let vc = ConfirmCalViewController()
        if (vc.shouldDismiss) {
            return false
        } else {
            return true
        }
    }
}
