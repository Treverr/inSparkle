//
//  WorkOrderPDFTemplateViewController.swift
//  inSparkle
//
//  Created by Trever on 2/16/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class WorkOrderPDFTemplateViewController: UIViewController {
    
    @IBOutlet var customerNameLabel: UILabel!
    @IBOutlet var customerAddressLabel: UILabel!
    @IBOutlet var customerAddressCityLabel: UILabel!
    @IBOutlet var customerPhoneLabel: UILabel!
    @IBOutlet var customerAltPhoneLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var schedTimeLabel: UILabel!
    @IBOutlet var techLabel: UILabel!
    @IBOutlet var wtbpTextView: UITextView!
    @IBOutlet var dowTextView: UITextView!
    @IBOutlet var recTextView: UITextView!
    @IBOutlet var tripOneDateLabel: UILabel!
    @IBOutlet var tripOneTimeArriveLabel: UILabel!
    @IBOutlet var tripOneTimeDepartLabel: UILabel!
    @IBOutlet var tripTwoDateLabel: UILabel!
    @IBOutlet var tripTwoTimeArriveLabel: UILabel!
    @IBOutlet var tripTwoDepartLabel: UILabel!
    @IBOutlet var unitMakeLabel: UILabel!
    @IBOutlet var unitModelLabel: UILabel!
    @IBOutlet var unitSerialLabel: UILabel!
    @IBOutlet var partsTableView: UITableView!
    @IBOutlet var laborTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
