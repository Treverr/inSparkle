//
//  AddEditCustomerTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import GooglePlacesAutocomplete

class AddEditCustomerTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var saveUpdateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedAddressLabel", name: "NotifyUpdateAddressLabelFromGoogleAutocompleteAPI", object: nil)

    }
    
    func googlePlacesAPI() {
        
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyCFBaUShWIatpRNiDtc8IcE8reNMs0kM7I",
            placeType: .Address
        )
        
        gpaViewController.placeDelegate = self
        gpaViewController.locationBias = LocationBias(latitude: 39.4931008, longitude: -87.3789913, radius: 120)
        gpaViewController.navigationBar.barStyle = UIBarStyle.Black
        gpaViewController.navigationBar.barTintColor = Colors.sparkleBlue
        gpaViewController.navigationBar.tintColor = UIColor.whiteColor()
        
        presentViewController(gpaViewController, animated: true, completion: nil)
        
    }
    
    func updatedAddressLabel() {
        addressLabel.text = GoogleAddress.address
        addressLabel.textColor = UIColor.blackColor()
    }
    
    @IBAction func saveUpdate(sender: AnyObject) {
        saveUpdateButton.setTitle("Saving...", forState: .Normal)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 3 {
            googlePlacesAPI()
        }
    }
    
}

extension AddEditCustomerTableViewController : GooglePlacesAutocompleteDelegate {
    
    func placeSelected(place: Place) {
        place.getDetails({ (thePlaceDetails) -> () in
            GoogleAddress.address = thePlaceDetails.fullAddress
        NSNotificationCenter.defaultCenter().postNotificationName("NotifyUpdateAddressLabelFromGoogleAutocompleteAPI", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}