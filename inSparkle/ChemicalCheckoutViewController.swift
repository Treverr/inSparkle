//
//  ChemicalCheckoutViewController.swift
//  inSparkle
//
//  Created by Trever on 2/11/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import iCarousel
import MIBadgeButton_Swift
import FXImageView

class ChemicalCheckoutViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    @IBOutlet var carousel : iCarousel!
    @IBOutlet var cart: MIBadgeButton!
    @IBOutlet var itemListTableView: UITableView!
    @IBOutlet var flowListSegmentControl: UISegmentedControl!
    
    let chemNames = ChemicalsData.checmicalNames
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("clearCart"), name: "ClearChemCart", object: nil)
        
        switch flowListSegmentControl.selectedSegmentIndex {
        case 0:
            itemListTableView.hidden = true
        case 1:
            carousel.hidden = true
        default:
            break
        }
        
        carousel.type = .Rotary
        carousel.delegate = self
        carousel.dataSource = self
        
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
        
        cart.badgeString = nil
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return ChemicalsData.checmicalNames.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        var itemView : FXImageView!
        var label : UILabel!
        
        let itemNames = ChemicalsData.checmicalNames
        
        if (view == nil) {
            itemView = FXImageView(frame: CGRectMake(0, 0, 400, 400))
            itemView.asynchronous = true
            itemView.reflectionScale = 0.5
            itemView.reflectionAlpha = 0.25
            itemView.reflectionGap = 10.0
            itemView.shadowOffset = CGSizeMake(0.0, 2.0)
            itemView.shadowBlur = 5.0
            itemView.contentMode = .ScaleAspectFit
            itemView.cornerRadius = 10.0
            
            label = UILabel(frame: itemView.frame)
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.blackColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(50)
            label.adjustsFontSizeToFitWidth = true
            label.tag = 1
            itemView.addSubview(label)
        } else {
            itemView = view as! FXImageView
            label = itemView.viewWithTag(1) as! UILabel!
        }
        
        itemView.processedImage = UIImage(named: "Placeholder")
        itemView.image = UIImage(named: "White")
        
        label.text = itemNames[index]
        
        return itemView
    }
    
    var numberInCart : Int = 0
    var cartItems = [String]()
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        
        addToCart(index)
        
    }
    
    @IBAction func cangedFlowListSegment(sender: AnyObject) {
        
        switch flowListSegmentControl.selectedSegmentIndex {
        case 0:
            itemListTableView.hidden = true
            carousel.hidden = false
        case 1:
            carousel.hidden = true
            itemListTableView.hidden = false
        default:
            break
        }
        
    }
    
    func addToCart(index : Int) {
        cartItems.append(ChemicalsData.checmicalNames[index])
        print(cartItems)
        numberInCart = numberInCart + 1
        cart.badgeString = String(numberInCart)
        
        let alert = UIAlertController(title: "Added", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
        numberInCart = 0
        self.dismissViewControllerAnimated(true, completion: nil)
        cart.badgeString = nil
        let alert = UIAlertController(title: "Success", message: "The chemical(s) have been checked out to you", preferredStyle: .Alert)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true) {
                let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime2, dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCart" {
            let navVC = segue.destinationViewController as! UINavigationController
            let vc = navVC.viewControllers.first as! ChemCartTableViewController
            vc.cart = self.cartItems
            print(vc.cart)
        }
    }
}

extension ChemicalCheckoutViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chemNames.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell")
        
        cell!.textLabel?.text = ChemicalsData.checmicalNames[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let index = indexPath.row
        
        addToCart(index)
        
    }
    
    @IBAction func close(sender : AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
