//
//  ObjectDetectionViewController.swift
//  K24D
//
//  Created by Jihan Alfiyyah Munajat on 23/05/23.
//

import UIKit
import AVFoundation
import Vision

class ObjectDetectionViewController: UIViewController {
    
    // Vision parts
//    private var requests = [VNRequest]()
    
    @discardableResult
    func setupVision() -> NSError? {
        let error: NSError! = nil
        
        guard let model = try? VNCoreMLModel(for: CardDetectorModel().model) else { fatalError("Failed to load CoreML Model") }
        
        return error
        

    }
    
    func RecognizingObjectObservation() {
        // config CoreML to use Neural Engine
        let config = MLModelConfiguration()
        config.computeUnits = .all
        
//        // Load CoreML model
//        let coreMLModel = try CardDetectorModel(configuration:  config)
//        
//        // create a Vision wrapper for CoreML model
//        let visionModel = try VNCoreMLModel(for: coreMLModel.model)
//        visionModel.inputImageFeatureName = "image"
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
