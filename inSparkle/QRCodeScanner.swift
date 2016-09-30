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

class QRCodeScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .NotDetermined {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted : Bool) in
                if granted {
                    
                } else {
                    return
                }
            })
        }
        
        view.backgroundColor = UIColor.blackColor()
        captureSession = AVCaptureSession()
        
        var videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput : AVCaptureDeviceInput
        
        if videoCaptureDevice.position == .Back {
        let frontCamera = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceTypeBuiltInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .Front).devices.first!
            videoCaptureDevice = frontCamera
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        


        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        print(orientation)
        
        switch (orientation) {
        case .Portrait:
            previewLayer?.connection.videoOrientation = .Portrait
        case .LandscapeRight:
            previewLayer?.connection.videoOrientation = .LandscapeLeft
        case .LandscapeLeft:
            previewLayer?.connection.videoOrientation = .LandscapeRight
        default:
            previewLayer?.connection.videoOrientation = .Portrait
        }
        
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        ac.addAction(okayAction)
        self.presentViewController(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.running == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.running == true) {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(readableObject.stringValue)
        }
    }
    
    func found(code : String) {
        self.dismissViewControllerAnimated(true) { 
            let userPass = code.componentsSeparatedByString(" ")
            let user = userPass[0]
            let pass = userPass[1]
            QRLogInData.username = user
            QRLogInData.password = pass
        }
    }
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

