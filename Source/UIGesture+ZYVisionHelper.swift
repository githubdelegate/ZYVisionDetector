//
//  UIGesture+ZYVisionHelper.swift
//  Pods-ZYVisionDetector
//
//  Created by zy on 2021/8/11.
//

import Foundation
import UIKit

let ClosureHandlerSelector = Selector(("handle"))

class ClosureHandler<T: AnyObject>: NSObject {

    internal var handler: ((T) -> Void)?
    internal weak var control: T?

    internal init(handler: @escaping (T) -> Void, control: T? = nil) {
        self.handler = handler
        self.control = control
    }

    @objc func handle() {
        if let control = self.control {
            handler?(control)
        }
    }
}

private var HandlerKey: UInt8 = 0

extension UIGestureRecognizer {

    func setHandler<T: UIGestureRecognizer>(_ instance: T, handler: ClosureHandler<T>) {
        objc_setAssociatedObject(self, &HandlerKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        handler.control = instance
    }

    func handler<T>() -> ClosureHandler<T> {
        return objc_getAssociatedObject(self, &HandlerKey) as! ClosureHandler
    }
}

public extension UITapGestureRecognizer {

    convenience init(taps: Int = 1, touches: Int = 1, handler: @escaping (UITapGestureRecognizer) -> Void) {
        let handler = ClosureHandler<UITapGestureRecognizer>(handler: handler)
        self.init(target: handler, action: ClosureHandlerSelector)
        setHandler(self, handler: handler)
        numberOfTapsRequired = taps
        numberOfTouchesRequired = touches
    }
}


public extension UIPinchGestureRecognizer {
    convenience init(handler: @escaping (UIPinchGestureRecognizer) -> Void) {
        let handler = ClosureHandler<UIPinchGestureRecognizer>(handler: handler)
        self.init(target: handler, action: ClosureHandlerSelector)
        setHandler(self, handler: handler)
    }
}
