//
//  QRScanningViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 10/8/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit
import AVFoundation



class QRScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var socket: SocketClient!
    
    var qrString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
        } catch {
            print(error)
            return;
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.frame
        
        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
        }
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }
    
    override func viewWillAppear(animated: Bool) {
        captureSession?.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if self.qrString == nil {
        // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects == nil || metadataObjects.count == 0 {
                qrCodeFrameView?.frame = CGRectZero
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                UIView.animateWithDuration(0.35, animations: { () -> Void in
                     self.qrCodeFrameView?.frame = barCodeObject.bounds;
                })
                if metadataObj.stringValue != nil {
                    self.qrString = metadataObj.stringValue
                    print(metadataObj.stringValue)
                    self.socket.connectedEvent = {
                        self.qrString = nil
                        self.socket.submitAttendance(metadataObj.stringValue)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.performSegueWithIdentifier("BeginClassSegue", sender: self)
                        })
                    }
                    self.socket.start()
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BeginClassSegue" {
            let navVc = segue.destinationViewController as! UINavigationController
            let classVC = navVc.viewControllers[0] as! ClassroomQuizTableViewController
            classVC.socketConnection = self.socket
        }
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.captureSession?.stopRunning()
        self.qrCodeFrameView?.frame = CGRectZero
        self.qrString = nil
    }
}
