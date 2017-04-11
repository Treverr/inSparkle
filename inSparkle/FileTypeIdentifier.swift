//
//  FileTypeIdentifier.swift
//  inSparkle
//
//  Created by Trever on 3/22/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import UIKit

internal let fileTypeIcons = [
    "pdf" : "ExpenseAttachmentType-PDF"
]

class FileType {
    
    class func iconFromType(type: String?) -> UIImage {
        if type != nil && fileTypeIcons.contains(where: { $0.0 == type!.lowercased() }) {
            return UIImage(named: fileTypeIcons[type!.lowercased()]!)!
        }
        return UIImage(named: "ExpenseAttachmentType-Default")!
    }
    
}
