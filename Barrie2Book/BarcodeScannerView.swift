//
//  BarcodeScannerView.swift
//  UPC
//
//  Created by Richard Allen on 7/10/14.
//  Copyright (c) 2014 Lapdog. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeScannerViewDelegate {
    func didRecognizeBarcode(barcode: String)
}

@IBDesignable
class BarcodeScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate: BarcodeScannerViewDelegate?
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 0.1) {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 5.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var unhighlightedBorderColor: UIColor?
    var camPreviewLayer: AVCaptureVideoPreviewLayer?
    let captureSession = AVCaptureSession()
    let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.masksToBounds = true
        unhighlightedBorderColor = borderColor
        startCamera()
    }
    
    override init(frame: CGRect)  {
        super.init(frame: frame)
    }
    
    func startCamera() {
        var error: NSError? = nil
        let videoInput = AVCaptureDeviceInput(device: videoCaptureDevice, error: &error)
        captureSession.addInput(videoInput)
        
        let metaOutput = AVCaptureMetadataOutput()
        metaOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureSession.addOutput(metaOutput)
        
        camPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        camPreviewLayer!.frame = bounds
        camPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        metaOutput.metadataObjectTypes = [AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeAztecCode
        ]
        
        layer.addSublayer(camPreviewLayer!)
        captureSession.startRunning()
    }

    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        for object in metadataObjects {
            borderColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
            didRecognizeBarcode(object.stringValue)
            captureSession.stopRunning()
            break
        }
    }
    
    func didRecognizeBarcode(barcode: String) {
        delegate?.didRecognizeBarcode(barcode)
    }
    
}