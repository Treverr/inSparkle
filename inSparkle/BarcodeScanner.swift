//
//  BarcodeScanner.swift
//  inSparkle
//
//  Created by Trever on 11/13/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import AVFoundation

class BarcodeScanner: RSCodeReaderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = setupAudioPlayerWithFile("ScannerBeep", type: "wav")
        audioPlayer.prepareToPlay()
        
        setupNavigationbar()
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        
        self.tapHandler = { point in
            
            print(point)
            
        }
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
                
                let barcodeToPass = barcode.stringValue
                self.playAlert()
                NSNotificationCenter.defaultCenter().postNotificationName("barcodeNotification", object: barcodeToPass)
                
                dispatch_async(dispatch_get_main_queue(),{ () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
        
        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
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

