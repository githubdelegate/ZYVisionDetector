//
//  PigeonCameraFocusView.swift
//  PigeonScan
//
//  Created by zy on 2021/7/29.
//

import Foundation
import UIKit

public protocol ZYVisionCameraCustomFocus : NSObjectProtocol {
    
    /// focus view
    var zyvision_focousView: ZYVisionCameraFocusView! { get set }
    
    /// 对焦view
    var zyvision_focusPreviewView: UIView! { get }
    
    /// 配置
    func zyvision_setupFocusView()
    
    /// 用户点击了屏幕,  要对焦 聚焦
    func cameraFocusOnTapPreviewView(tapGes: UITapGestureRecognizer)
    
    /// 用户在放大缩小 要调焦
    func cameraFocusOnPinchPreviewView(pinchGes: UIPinchGestureRecognizer)
    
    var tmpzoom: CGFloat { get set }
    var videozoom: CGFloat { get set }
}

public extension ZYVisionCameraCustomFocus {
    
    func zyvision_setupFocusView() {
        self.zyvision_focousView = ZYVisionCameraFocusView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        let tapGes =  UITapGestureRecognizer(taps: 1, touches: 1) { tapges in
                    if tapges.state == .ended {
                        let point = tapges.location(in: self.zyvision_focusPreviewView)
            
                        self.zyvision_focusPreviewView.addSubview(self.zyvision_focousView)
                        self.zyvision_focousView.showInCenter(point: point)
                        
                        self.cameraFocusOnTapPreviewView(tapGes: tapges)
                    }
        }
        self.zyvision_focusPreviewView.addGestureRecognizer(tapGes)
        
        let zoomGes = UIPinchGestureRecognizer { pinges in
            self.cameraFocusOnPinchPreviewView(pinchGes: pinges)
        }
        self.zyvision_focusPreviewView.addGestureRecognizer(zoomGes)
        
        self.tmpzoom = 0
        self.videozoom = 0
    }
}

public class ZYVisionCameraFocusView: UIView {
    var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(self.shapeLayer)
        self.shapeLayer.strokeColor =  UIColor(zyvision_hexString: "#FFBD27").cgColor
        self.shapeLayer.lineWidth = 1.0
        self.shapeLayer.fillColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shapeLayer.frame = self.bounds
        self.shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        let cenx = self.bounds.size.width / 2
        let ceny = self.bounds.size.height / 2
        _ = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: cenx/2, y: ceny))
        path.addLine(to: CGPoint(x: 3 * cenx / 2, y: ceny))
        
        path.move(to: CGPoint(x: cenx, y: ceny/2))
        path.addLine(to: CGPoint(x: cenx, y: 3 * ceny / 2))
        
        path.append(UIBezierPath(rect: self.bounds))
        
        self.shapeLayer.path = path.cgPath
        
    }
    
    func showInCenter(point: CGPoint) {
        self.center = point
        self.alpha = 0
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { s in
            UIView.animate(withDuration: 0.25) {
                self.transform = .identity
                self.alpha = 1
            } completion: { s in
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 0
                }
            }
        }
    }
}
