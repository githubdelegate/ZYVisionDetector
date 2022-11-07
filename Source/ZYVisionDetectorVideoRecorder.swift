//
//  VisionCameraProtocol.swift
//  ZYVisionDetector
//
//  Created by zy on 2021/7/26.
//

import Foundation
import AVFoundation
import UIKit

/// 视频录制协议
public protocol ZYVisionDetectorVideoRecorder: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, ZYVisionCameraCustomFocus {
    
    var zyvision_session: AVCaptureSession! { get set }
    
    var zyvision_inputDevice: AVCaptureDeviceInput! { get set }
    var zyvision_device: AVCaptureDevice! { get set }
    var zyvision_photoSetting: AVCapturePhotoSettings! { get set }
    
    var zyvision_photoOutput: AVCapturePhotoOutput! { get set }
    var zyvision_videoOutput: AVCaptureVideoDataOutput! { get set }
    
    /// 绘制矩形的layer
    var zyvision_rectangleShapeLayer: CAShapeLayer! { get set }
    
    /// 视频展示layer
    var zyvision_previewLayer: AVCaptureVideoPreviewLayer! { get set }
    
    
    /// 展示view, 基本等于全屏view
    var zyvision_previewView: UIView! { get }
    
    
    /// 可见view 意思是 有的界面不是全屏显示录像的，而是只显示一部分
    var  zyvision_visibleView: UIView! { get }
    
    
    /// 设置session
    func zyvision_setupSession()
    
    
    /// 开启session
    func zyvision_beginSession()
    
    
    /// 关闭session
    func zyvision_endSession()
    
    
    /// 设置session 完成
    func zyvision_setupSessionDone()
    
    /// 开始设置session
    func zyvision_setupSessionBegin()
}

public extension ZYVisionDetectorVideoRecorder {
    
    func zyvision_setupSessionDone() {
        
    }
    
    func zyvision_setupSessionBegin() {
        
    }
    
    func zyvision_setupSession() {
        
        self.zyvision_setupSessionBegin()
        
        if self.zyvision_session != nil {
            return
        }
        
        self.zyvision_session = AVCaptureSession()
        self.zyvision_device = AVCaptureDevice.default(for: .video)
        guard let input = try? AVCaptureDeviceInput(device: self.zyvision_device) else {
            print("device")
            return
        }
        self.zyvision_inputDevice = input
        
        self.zyvision_photoOutput = AVCapturePhotoOutput()
        self.zyvision_videoOutput = AVCaptureVideoDataOutput()
        self.zyvision_videoOutput.alwaysDiscardsLateVideoFrames = true
        let videoQueue = DispatchQueue(label: "com.xxxx.videoqueue")
        
        self.zyvision_videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
//        self.photoOutput.isHighResolutionCaptureEnabled = true
        
        self.zyvision_photoSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        self.zyvision_photoSetting.flashMode = .auto
        
        self.zyvision_photoOutput.photoSettingsForSceneMonitoring  = self.zyvision_photoSetting

        if(self.zyvision_session.canAddInput(self.zyvision_inputDevice!)) {
            self.zyvision_session.addInput(self.zyvision_inputDevice!)
        }
        
        if self.zyvision_session.canAddOutput(self.zyvision_photoOutput) {
            self.zyvision_session.addOutput(self.zyvision_photoOutput)
        }
        
        if self.zyvision_session.canAddOutput(self.zyvision_videoOutput) {
            self.zyvision_session.addOutput(self.zyvision_videoOutput)
        }
        self.zyvision_videoOutput.connection(with: .video)?.isEnabled = true
        self.zyvision_videoOutput.connections.first?.videoOrientation = .portrait
        
//        if((self.session.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080))) {
//            self.session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
//        }
        
        self.zyvision_previewLayer = AVCaptureVideoPreviewLayer(session: zyvision_session)
        self.zyvision_previewLayer.frame = self.zyvision_previewView.bounds
//        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.previewView.layer.insertSublayer(self.previewLayer)
        self.zyvision_previewView.layer.addSublayer(self.zyvision_previewLayer)
        
        
        self.zyvision_rectangleShapeLayer = CAShapeLayer()
        self.zyvision_rectangleShapeLayer.frame = self.zyvision_visibleView.frame
        self.zyvision_rectangleShapeLayer.isHidden = true
//        self.rectangleShapeLayer.backgroundColor = UIColor.red.cgColor
        self.zyvision_rectangleShapeLayer.strokeColor = UIColor.red.cgColor
        self.zyvision_rectangleShapeLayer.lineWidth = 5.0
        self.zyvision_rectangleShapeLayer.fillColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        self.zyvision_rectangleShapeLayer.name = "rectangle"
        self.zyvision_previewView.layer.addSublayer(self.zyvision_rectangleShapeLayer)
  
//        self.preViewimageView.isUserInteractionEnabled = true
        self.zyvision_setupFocusView()
        
        self.zyvision_setupSessionDone()
    }
    
    var minZoom: CGFloat {
        return self.zyvision_device.minAvailableVideoZoomFactor
    }
    
    var maxZoom: CGFloat {
        return self.zyvision_device.maxAvailableVideoZoomFactor
    }
    
    func zyvision_beginSession() {
        DispatchQueue.global().async {
            if self.zyvision_session == nil {
                return
            }
            if self.zyvision_session.isRunning == false {
                self.zyvision_session.startRunning()
            }
        }
    }
    
    func zyvision_endSession() {
        if self.zyvision_session == nil {
            return
        }
        if self.zyvision_session.isRunning {
            self.zyvision_session.stopRunning()
        }
    }
    
    func captureScan() {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        self.zyvision_photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

// MARK: Focus View
public extension ZYVisionDetectorVideoRecorder {
    var zyvision_focusPreviewView: UIView! {
        return self.zyvision_visibleView
    }
//    public var zyvision_focousView: ZYVisionCameraFocusView! 
    
    func cameraFocusOnTapPreviewView(tapGes: UITapGestureRecognizer) {
        try? self.zyvision_device.lockForConfiguration()
        let point = tapGes.location(in: self.zyvision_previewView)
        self.zyvision_device.focusPointOfInterest = point
        self.zyvision_device.focusMode = .autoFocus
        self.zyvision_device.unlockForConfiguration()
    }
    
    func cameraFocusOnPinchPreviewView(pinchGes: UIPinchGestureRecognizer) {
        if pinchGes.state == .began {
            self.tmpzoom = self.videozoom
        }else if pinchGes.state == .ended {
            var newzoom = self.tmpzoom * pinchGes.scale
            if newzoom < self.minZoom {
                newzoom = self.minZoom
            }
            
            if newzoom > self.maxZoom {
                newzoom = self.maxZoom
            }
            self.videozoom = newzoom
        } else if pinchGes.state == .changed {
            var newzoom = self.tmpzoom * pinchGes.scale
            print(" zoom = \(pinchGes.scale) =\(newzoom) ")
            if newzoom < self.minZoom {
                newzoom = self.minZoom
            }
            
            if newzoom > self.maxZoom {
                newzoom = self.maxZoom
            }
            
            print(" after zoom = \(pinchGes.scale) =\(newzoom) ")
            try? self.zyvision_device.lockForConfiguration()
            self.zyvision_device.videoZoomFactor = newzoom
            self.zyvision_device.unlockForConfiguration()
            
        }
    }
}
