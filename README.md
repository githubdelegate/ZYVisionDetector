# ZYVisionDetector

`ZYVisionDetector` can help you to record video and detect retangles in your video. 
能帮助你实现自动识别视频中矩形区域并高亮

![sample](https://github.com/githubdelegate/ZYVisionDetector/blob/master/sample.gif)


## Install 

* Cocoapods
`pod ZYVisionDetector`

* SPM

` `


## Usage

* detect retangle
```
ZYVisionRetangleDetector.visionImage(clipImage: previewimg, boxSize: self.zyvision_previewLayer.bounds.size) { result, points  in
    let path = CGMutablePath()
    if points != nil {
        path.addLines(between: [points!.0, points!.1, points!.2, points!.3, points!.0])
        self.zyvision_rectangleShapeLayer.path = path
        self.zyvision_rectangleShapeLayer.isHidden = false
    }
}
```

* video recoder

```
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
    
}
```



