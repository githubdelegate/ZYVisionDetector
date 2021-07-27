//
//  CameraViewController.swift
//  ZYVisionDetector
//
//  Created by zy on 2021/7/27.
//

import UIKit
import AVFoundation
import ZYVisionDetector

class CameraViewController: UIViewController, ZYVisionDetectorVideoRecorder {
    var zyvision_inputDevice: AVCaptureDeviceInput!
    
    var zyvision_device: AVCaptureDevice!
    
    var zyvision_photoSetting: AVCapturePhotoSettings!
    
    var zyvision_photoOutput: AVCapturePhotoOutput!
    
    var zyvision_videoOutput: AVCaptureVideoDataOutput!
    
    var zyvision_rectangleShapeLayer: CAShapeLayer!
    
    var zyvision_previewLayer: AVCaptureVideoPreviewLayer!
    
    var zyvision_previewView: UIView! {
        return self.view
    }
    
    var zyvision_session: AVCaptureSession!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zyvision_setupSession()
        
        self.zyvision_beginSession()
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let sampleImage = sampleBuffer.zyvision_image() else {
            return
        }
        
        guard let ciImage = sampleImage.ciImage else {
            return
        }
        
        if let cgim =  ciImage.zyvision_toCGImage() {
            let previewimg = UIImage(cgImage: cgim)
            DispatchQueue.main.async {
                ZYVisionRetangleDetector.visionImage(clipImage: previewimg, boxSize: self.zyvision_previewLayer.bounds.size) { result, points  in
                    let path = CGMutablePath()
                    if points != nil {
                        path.addLines(between: [points!.0, points!.1, points!.2, points!.3, points!.0])
                        self.zyvision_rectangleShapeLayer.path = path
                        self.zyvision_rectangleShapeLayer.isHidden = false
                    }
                }
            }
        }
    }
    
}
