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

        NotificationCenter.default.addObserver(self, selector: #selector(ConfirmingAppointmentTableViewController.updateDateLabel(_:)), name: NSNotification.Name(rawValue: "NotifyConfirmScreenUpdateLabel"), object: nil)
        
        dateLbel.isUserInteractionEnabled = true
        let dateLabelTapGest = UITapGestureRecognizer(target: self, action: #selector(ConfirmingAppointmentTableViewController.displayPopover))
        dateLabelTapGest.numberOfTapsRequired = 1
        dateLbel.addGestureRecognizer(dateLabelTapGest)
        
    }
    
    func displayPopover() {
        let storyboard = UIStoryboard(name: "Schedule", bundle: nil)
        let x = self.view.center
        let vc = storyboard.instantiateViewController(withIdentifier: "confimCalDatePicker")
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: (x.x - 25), y: x.y, width: 0, height: 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.present(vc, animated: true, completion: nil)
    }
    
    func updateDateLabel(_ notification : Notification) {
        self.dateLbel.text = notification.object as! String
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnString : String = ""
        if section == 0 {
            
            let schObj = AddNewScheduleObjects.scheduledObject!
            returnString = "Confirming Appointment for \(schObj.customerName.capitalized). " + "\nWeek of \(GlobalFunctions().stringFromDateShortStyle(schObj.weekStart))" + " - \(GlobalFunctions().stringFromDateShortStyle(schObj.weekEnd))"
        }
        return returnString
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       cell.selectionStyle = .none
    }
    
    @IBAction func confirmButton(_ sender: AnyObject) {
        let schObj = AddNewScheduleObjects.scheduledObject!
        schObj.confirmedDate = GlobalFunctions().dateFromMediumDateString(dateLbel.text!)
        schObj.confrimed = true
        schObj.confrimedBy = PFUser.current()!.username!.capitalized
        schObj.saveInBackground { (success : Bool, error : Error?) -> Void in
            if (success) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        let vc = ConfirmCalViewController()
        if (vc.shouldDismiss) {
            return false
        } else {
            return true
        }
    }
}
