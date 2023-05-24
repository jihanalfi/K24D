//
//  CameraViewController.swift
//  K24D
//
//  Created by Jihan Alfiyyah Munajat on 23/05/23.
//

import UIKit
import AVKit
import Vision
import CoreML

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private var requests = [VNRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Start Scanning"
        
        // ``
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        session.addInput(input)
        session.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(dataOutput)

    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //
        guard let model = try? VNCoreMLModel(for: CardDetectorModel().model) else {
            fatalError("Failed to load CoreML Model") }
        
        do {
            let request = VNCoreMLRequest(model: model){
                (finishedReq, err) in
                //            guard let results = finishedReq.results as? [VNDetectedObjectObservation] else {
                //                fatalError("cannot get result from VNCoreMLRequest")
                DispatchQueue.main.async ( execute:{
                    if let results = finishedReq.results {
                        if results.count != 4{
                            print("number of cards detected: \(results.count)")
                        }
//                        self.findOperationResult(results: results)
                    }
                })
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

        } catch let error as NSError {
            print("Output model went wrong: \(error)")
        }

    }
    
    func findOperationResult(results: [Any]) {
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            let labelObservation = objectObservation.labels[0]
            // switch case Ace as 1/11, J Q K as 10
            // possibilities to find 24
        }
    }
    
    

//            guard let firstObservation = results.first else { return }
//            print("identifier: " + firstObservation.identifier)
//            print("confidence: ")
//            print(firstObservation)
//            print("end")
//        }

//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    
    
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
