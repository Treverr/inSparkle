//
//  QRCodeScanner.swift
//  inSparkle
//
//  Created by Trever on 8/13/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import AVFoundation

class QRCodeScanner: RSCodeReaderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = setupAudioPlayerWithFile("ScannerBeep", type: "wav")
        audioPlayer.prepareToPlay()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        
        self.tapHandler = { point in
            
            print(point)
            
        }
        
        
        self.barcodesHandler = { barcodes in
            let barcode = barcodes[0]
            print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
            
            let barcodeToPass = barcode.stringValue
            self.playAlert()
            
            var run = true
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.dismissViewControllerAnimated(true, completion: {
                    if run {
                        run = false
                        let userPass = barcodeToPass.componentsSeparatedByString(" ")
                        let user = userPass[0]
                        let pass = userPass[1]
                        QRLogInData.username = user
                        QRLogInData.password = pass
                    }
                })
            }
        }
        
        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toggleFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    try device.setTorchModeOnWithLevel(1.0)
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        } else {
            let alert = UIAlertView()
            alert.title = "No Flash"
            alert.message = "It doesn't look like your device has an LED flash"
            alert.addButtonWithTitle("Okay")
            alert.show()
        }
    }
    
    func checkForTorch() {
        let theDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (theDevice.hasTorch) {
            
        } else {
            
        }
    }
    
    var audioPlayer : AVAudioPlayer = AVAudioPlayer()
    
    func playAlert() {
        
        audioPlayer.play()
        
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("NO AUDIO PLAYER")
        }
        
        return audioPlayer!
    }
    
}

