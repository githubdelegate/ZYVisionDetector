//
//  VisionRetangleDetector.swift
//  ZYVisionDetector
//
//  Created by zy on 2021/7/26.
//

import Foundation
import Vision
import UIKit


/// 矩形识别
open class ZYVisionRetangleDetector {
    
    public typealias VisionRetangleDetectorResult = ((CGPoint, CGPoint, CGPoint, CGPoint)?, (CGPoint, CGPoint, CGPoint, CGPoint)?) -> Void

    var vsionResult: VisionRetangleDetectorResult?
    var imgSize: CGSize = .zero
    var boxSize: CGSize = .zero
    var insets: UIEdgeInsets = .zero
    
    
    /// 识别image里面矩形区域
    /// - Parameters:
    ///   - clipImage: 图片
    ///   - boxSize: imageview 大小
    ///   - insets: 识别区域的内边距
    ///   - result: 识别结果 在imageview里面的  有8个点， 前4个是 比例值， 后4个是确切值
    public static func visionImage(clipImage: UIImage,boxSize: CGSize, insets: UIEdgeInsets = .zero, result: @escaping VisionRetangleDetectorResult) {
        
        let vision = ZYVisionRetangleDetector()
        vision.vsionResult = result
        vision.boxSize = boxSize
        vision.insets = insets
        
        guard clipImage.cgImage != nil else {  vision.vsionResult?(nil, nil); vision.vsionResult = nil; return }
        vision.imgSize = clipImage.size
        let imageRequestHandler = VNImageRequestHandler(cgImage: clipImage.cgImage!, options: [:])
        do {
            try imageRequestHandler.perform([vision.createDetectRecReq()])
        } catch {
            print(error)
            vision.vsionResult?(nil, nil)
            vision.vsionResult = nil
        }
    }
    
    
    func createDetectRecReq() -> VNDetectRectanglesRequest {
        let req = VNDetectRectanglesRequest { request, err in
            // 识别结果
            if err != nil {
                print("xxx-识别错误为===")
            }
            
            if let rectans = request.results as? [VNRectangleObservation] {
                DispatchQueue.main.async {
                    if let obser = rectans.first {
                        self.dectVisionRetangleResult(obser: obser)
                    }else {
                        self.dectVisionRetangleResult(obser: nil)
                    }
                }
            }
        }
        
        req.minimumSize = 0.3
        req.minimumAspectRatio = 0.1
        req.maximumAspectRatio = 3
        req.quadratureTolerance = 45
        req.minimumConfidence = 0.1
        req.maximumObservations = 1
        return req
    }
    
    func dectVisionRetangleResult(obser: VNRectangleObservation?) {
        if obser == nil {
            vsionResult?(nil, nil)
            vsionResult = nil
        } else {
            let result = CGSize.zyvision_aspectFit(aspectRatio: self.imgSize, boundingSize: self.boxSize)
            let points =  self.vnretanglePoints2ZYQuadranglePoints(rectangle: obser!, boxSize: result.size)
            vsionResult?(points.0, points.1)
            vsionResult = nil
        }
    }
    
    func vnretanglePoints2ZYQuadranglePoints(rectangle: VNRectangleObservation, boxSize: CGSize) -> ((CGPoint, CGPoint, CGPoint, CGPoint), (CGPoint, CGPoint, CGPoint, CGPoint)) {
        let translateTransform = CGAffineTransform.identity.scaledBy(x: boxSize.width, y: boxSize.height)
        print("vsion -> \(rectangle.topLeft)--\(rectangle.topRight)--\(rectangle.bottomLeft)--\(rectangle.bottomRight)")
//        let convertedTopLeft = CGPoint(x: rectangle.topLeft.x + self.insets.left, y: rectangle.topLeft.y + self.insets.top) .applying(translateTransform)
//        let convertedTopRight = CGPoint(x: rectangle.topRight.x - self.insets.right, y: rectangle.topRight.y + self.insets.top).applying(translateTransform)
//        let convertedBottomLeft = CGPoint(x: rectangle.bottomLeft.x + self.insets.left, y: rectangle.bottomLeft.y - self.insets.bottom).applying(translateTransform)
//        let convertedBottomRight = CGPoint(x: rectangle.bottomRight.x - self.insets.right, y: rectangle.bottomRight.y - self.insets.bottom).applying(translateTransform)


        var convertedTopLeft = rectangle.topLeft.applying(translateTransform)
        var convertedTopRight = rectangle.topRight.applying(translateTransform)
        var convertedBottomLeft = rectangle.bottomLeft.applying(translateTransform)
        var convertedBottomRight = rectangle.bottomRight.applying(translateTransform)

        print("before inset = \(convertedTopLeft)--\(convertedTopRight)--\(convertedBottomLeft)--\(convertedBottomRight)")
        convertedTopLeft = CGPoint(x: convertedTopLeft.x + self.insets.left, y: convertedTopLeft.y + self.insets.top)
        convertedTopRight = CGPoint(x: convertedTopRight.x - self.insets.right, y: convertedTopRight.y + self.insets.top)
        convertedBottomLeft = CGPoint(x: convertedBottomLeft.x + self.insets.left, y: convertedBottomLeft.y - self.insets.bottom)
        convertedBottomRight = CGPoint(x: convertedBottomRight.x - self.insets.right, y: convertedBottomRight.y - self.insets.bottom)

        print("aftet inset= \(convertedTopLeft)--\(convertedTopRight)--\(convertedBottomLeft)--\(convertedBottomRight)")
   
        let fliptrans = CGAffineTransform.identity.scaledBy(x: 1, y: -1)
        fliptrans.translatedBy(x: 0, y: boxSize.height)
        
        let cliptl = convertedTopLeft.applying(fliptrans)
        let cliptr = convertedTopRight.applying(fliptrans)
        let clipbl = convertedBottomLeft.applying(fliptrans)
        let clipbr = convertedBottomRight.applying(fliptrans)
        
        let translatr = CGAffineTransform.identity.translatedBy(x: 0, y: boxSize.height)
        let lasttl = cliptl.applying(translatr)
        let lasttr = cliptr.applying(translatr)
        let lastbl = clipbl.applying(translatr)
        let lastbr = clipbr.applying(translatr)
        
        let clippointtl = lasttl.applying(CGAffineTransform(scaleX: 1 / boxSize.width, y: 1 / boxSize.height))
        let clippointtr = lasttr.applying(CGAffineTransform(scaleX: 1 / boxSize.width, y: 1 / boxSize.height))
        let clippointbl = lastbl.applying(CGAffineTransform(scaleX: 1 / boxSize.width, y: 1 / boxSize.height))
        let clippointbr = lastbr.applying(CGAffineTransform(scaleX: 1 / boxSize.width, y: 1 / boxSize.height))
        
        let clips = (clippointtl, clippointtr, clippointbr, clippointbl)
        let lasts = (lasttl, lasttr, lastbr, lastbl)
        
        return (clips, lasts)
    }
    
}
