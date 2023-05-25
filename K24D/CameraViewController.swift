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
    private var isAnalyzing: Bool = false
    private var frozenImageView: UIImageView?

    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var ResultTitle: UILabel!
    @IBOutlet weak var ResultDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Start Scanning"
        self.Status.text = "Scan scan"
        self.ResultTitle.text = ""
        self.ResultDetail.text = ""
        
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
        
        frozenImageView = UIImageView(frame: view.bounds)
        frozenImageView?.contentMode = .scaleAspectFit
        frozenImageView?.isHidden = true
        view.addSubview(frozenImageView!)


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
                            self.isAnalyzing = false
                            self.Status.text = "Card is not 4!"
                            self.ResultTitle.text = ""
                            self.ResultDetail.text = ""

                            
                        } else {
                            let cardObservationResult: [Int] = self.findOperationResult(results: results)
                            if !self.isAnalyzing {
                                self.isAnalyzing = true
                                let combinationObservationResult = self.findNumber24(cardObservationResult)
                                self.Status.text = "Analyzing ..."
                                print("analyzing from \(cardObservationResult) results \(combinationObservationResult)")
                                if combinationObservationResult.count == 0 {
                                    self.Status.text = "Found the operation to 24!"
                                    print("24 combination not found")
                                    self.ResultTitle.text = ""
                                    self.ResultDetail.text = ""
                                } else {
                                    print("found brooo")
                                    self.ResultTitle.text = ""
                                    self.ResultDetail.text = "Result found: \(combinationObservationResult[0])"

                                }
                            }
                        }
                    }
                })
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

        } catch let error as NSError {
            print("Output model went wrong: \(error)")
        }

    }
    
    func freezeFrame(_ pixelBuffer: CVPixelBuffer) {
        print("masuk freeze frame")
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let frozenImage = UIImage(cgImage: cgImage)
            frozenImageView?.image = frozenImage
            frozenImageView?.isHidden = false
            
            DispatchQueue.main.async {
                self.frozenImageView?.image = frozenImage
                self.frozenImageView?.isHidden = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.isAnalyzing = false
                
                DispatchQueue.main.async {
                    self.frozenImageView?.isHidden = true
                }
            }
        }
    }

    func findOperationResult(results: [Any]) -> [Int] {
        var observedResults: [Int] = []
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            var value = objectObservation.labels[0].identifier
            var convertedValue: Int
            switch value {
            case "Ace":
                convertedValue = 1
            case "2":
                convertedValue = 2
            case "3":
                convertedValue = 3
            case "4":
                convertedValue = 4
            case "5":
                convertedValue = 5
            case "6":
                convertedValue = 6
            case "7":
                convertedValue = 7
            case "8":
                convertedValue = 8
            case "9":
                convertedValue = 9
            case "10":
                convertedValue = 10
            case "J":
                convertedValue = 10
            case "Q":
                convertedValue = 10
            case "K":
                convertedValue = 10
                
            default:
                convertedValue = 999
            }
            observedResults.append(convertedValue)
        }
        return observedResults
    }
    
    
    func findNumber24(_ array: [Int]) -> [String] {
        let nums = array
        let operators: [String] = ["+", "-", "*", "/"]
        
        var perms: [String] = []
        for i in 0..<4 {
            for j in 0..<4 {
                for k in 0..<4 {
                    // Build the expression
                    let expression = "(\(nums[0]) \(operators[i]) \(nums[1])) \(operators[j]) (\(nums[2]) \(operators[k]) \(nums[3]))"
                    
                    // Solve expression and check if it equals 24
                    if let result = NSExpression(format: expression).expressionValue(with: nil, context: nil) as? Double,
                        result == 24 {
                        perms.append(expression)
                    }
                }
            }
        }
        return perms
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
