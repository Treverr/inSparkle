//
//  ComposeMessageNavigationController.swift
//  inSparkle
//
//  Created by Trever on 9/18/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class ComposeMessageNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationbar(self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
