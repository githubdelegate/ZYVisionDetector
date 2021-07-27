//
//  Size+Helper.swift
//  ZYVisionDetector
//
//  Created by zy on 2021/7/26.
//

import Foundation
import UIKit

extension CGSize {
    
    /// 计算imageview 里面image 显示的实际大小
    /// - Parameters:
    ///   - aspectRatio: 图片大小
    ///   - boundingSize: imageview 大小
    /// - Returns: image 展示大小
    static func zyvision_aspectFit(aspectRatio : CGSize, boundingSize: CGSize) -> (size: CGSize, xOffset: CGFloat, yOffset: CGFloat)  {
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        var fittedWidth = boundingSize.width
        var fittedHeight = boundingSize.height
        var xOffset = CGFloat(0.0)
        var yOffset = CGFloat(0.0)

        if( mH < mW ) {
            fittedWidth = boundingSize.height / aspectRatio.height * aspectRatio.width;
            xOffset = abs(boundingSize.width - fittedWidth)/2
        }
        else if( mW < mH ) {
            fittedHeight = boundingSize.width / aspectRatio.width * aspectRatio.height;
            yOffset = abs(boundingSize.height - fittedHeight)/2
        }
        let size = CGSize(width: fittedWidth, height: fittedHeight)
        return (size, xOffset, yOffset)
    }

    static func aspectFill(aspectRatio :CGSize, minimumSize: CGSize) -> CGSize {
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height;
        var minWidth = minimumSize.width
        var minHeight = minimumSize.height
        if( mH > mW ) {
            minWidth = minimumSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW > mH ) {
            minHeight = minimumSize.width / aspectRatio.width * aspectRatio.height;
        }

        return CGSize(width: minWidth, height: minHeight)
    }
}
