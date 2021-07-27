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
public protocol ZYVisionDetectorVideoRecorder:  AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
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
    
    
    /// 展示view
    var zyvision_previewView: UIView! { get }
    
    
    /// 设置session
    func zyvision_setupSession()
    
    
    /// 开启session
    func zyvision_beginSession()
    
    
    /// 关闭session
    func zyvision_endSession()
}

public extension ZYVisionDetectorVideoRecorder {
    
    func zyvision_setupSession() {
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
        self.zyvision_rectangleShapeLayer.frame = self.zyvision_previewLayer.bounds
        self.zyvision_rectangleShapeLayer.isHidden = true
//        self.rectangleShapeLayer.backgroundColor = UIColor.red.cgColor
        self.zyvision_rectangleShapeLayer.strokeColor = UIColor.red.cgColor
        self.zyvision_rectangleShapeLayer.lineWidth = 5.0
        self.zyvision_rectangleShapeLayer.fillColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        self.zyvision_rectangleShapeLayer.name = "rectangle"
        self.zyvision_previewView.layer.addSublayer(self.zyvision_rectangleShapeLayer)
    }
    
    func zyvision_beginSession() {
        if Thread.current.isMainThread {
            if self.zyvision_session == nil {
                return
            }
            if self.zyvision_session.isRunning == false {
                self.zyvision_session.startRunning()
            }
        } else {
            DispatchQueue.main.async {
                if self.zyvision_session == nil {
                    return
                }
                if self.zyvision_session.isRunning == false {
                    self.zyvision_session.startRunning()
                }
            }
        }
    }
    
    func zyvision_endSession() {
        if Thread.current.isMainThread {
            if self.zyvision_session == nil {
                return
            }
            if self.zyvision_session.isRunning {
                self.zyvision_session.stopRunning()
            }
        } else {
            DispatchQueue.main.async {
                if self.zyvision_session == nil {
                    return
                }
                if self.zyvision_session.isRunning {
                    self.zyvision_session.stopRunning()
                }
            }
        }
    }
    
    func captureScan() {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        self.zyvision_photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}
