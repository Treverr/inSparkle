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
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        self.focusMarkLayer.strokeColor = UIColor.red.cgColor
        self.cornersLayer.strokeColor = UIColor.yellow.cgColor
        
        self.tapHandler = { point in
            
            print(point)
            
        }
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
                
                let barcodeToPass = barcode.stringValue
                self.playAlert()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "barcodeNotification"), object: barcodeToPass)
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleFlash() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    try device?.setTorchModeOnWithLevel(1.0)
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        } else {
            let alert = UIAlertView()
            alert.title = "No Flash"
            alert.message = "It doesn't look like your device has an LED flash"
            alert.addButton(withTitle: "Okay")
            alert.show()
        }
    }
    
    func checkForTorch() {
        let theDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (theDevice?.hasTorch)! {
            
        } else {
            
        }
    }
    
    var audioPlayer : AVAudioPlayer = AVAudioPlayer()
    
    func playAlert() {
        
        audioPlayer.play()
        
    }
    
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = URL(fileURLWithPath: path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("NO AUDIO PLAYER")
        }
        
        return audioPlayer!
    }
    
}

