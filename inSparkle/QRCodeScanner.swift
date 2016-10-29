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
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted : Bool) in
                if granted {
                    
                } else {
                    return
                }
            })
        }
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        var videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput : AVCaptureDeviceInput
        
        if videoCaptureDevice?.position == .back {
        let frontCamera = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front).devices.first!
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
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        


        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        print(orientation)
        
        switch (orientation) {
        case .portrait:
            previewLayer?.connection.videoOrientation = .portrait
        case .landscapeRight:
            previewLayer?.connection.videoOrientation = .landscapeLeft
        case .landscapeLeft:
            previewLayer?.connection.videoOrientation = .landscapeRight
        default:
            previewLayer?.connection.videoOrientation = .portrait
        }
        
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        ac.addAction(okayAction)
        self.present(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(readableObject.stringValue)
        }
    }
    
    func found(_ code : String) {
        self.dismiss(animated: true) { 
            let userPass = code.components(separatedBy: " ")
            let user = userPass[0]
            let pass = userPass[1]
            QRLogInData.username = user
            QRLogInData.password = pass
        }
    }
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

