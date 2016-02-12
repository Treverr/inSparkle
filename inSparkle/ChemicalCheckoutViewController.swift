//
//  ChemicalCheckoutViewController.swift
//  inSparkle
//
//  Created by Trever on 2/11/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import iCarousel

class ChemicalCheckoutViewController: UIViewController {

    @IBOutlet var carouselOutlet: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}

extension ChemicalCheckoutViewController : iCarouselDelegate, iCarouselDataSource {
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return 1
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        var itemView : UIImageView!
        
        if (view == nil) {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            itemView.contentMode = .ScaleAspectFit
        } else {
            itemView = view as! UIImageView
        }
        
        itemView.image = UIImage(named: "ITEM AT INDEX")
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        let selectedIndex = index
        
    }
    
    
}
