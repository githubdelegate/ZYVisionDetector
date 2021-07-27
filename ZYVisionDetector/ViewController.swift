//
//  ViewController.swift
//  ZYVisionDetector
//
//  Created by zy on 2021/7/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func scan(_ sender: Any) {
        let vc = CameraViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

