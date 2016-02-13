//
//  ChemicalCheckoutViewController.swift
//  inSparkle
//
//  Created by Trever on 2/11/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import iCarousel

class ChemicalCheckoutViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet var carousel : iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carousel.type = .CoverFlow2
        carousel.delegate = self
        carousel.dataSource = self
        
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
        
        var itemView : UIImageView!
        var label : UILabel!
        
        let itemNames = ChemicalsData.checmicalNames
        
        if (view == nil) {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            itemView.backgroundColor = UIColor.whiteColor()
            itemView.layer.cornerRadius = 8.0
            itemView.clipsToBounds = true
            itemView.contentMode = .ScaleAspectFit
            
            label = UILabel(frame: itemView.frame)
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.blackColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(50)
            label.adjustsFontSizeToFitWidth = true
            label.tag = 1
            itemView.addSubview(label)
        } else {
            itemView = view as! UIImageView
            label = itemView.viewWithTag(1) as! UILabel!
        }
        
        label.text = itemNames[index]
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        
        let alert = UIAlertController(title: "Added", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        
    }


}
