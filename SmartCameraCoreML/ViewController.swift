//
//  ViewController.swift
//  SmartCameraCoreML
//
//  Created by sun on 5/5/2562 BE.
//  Copyright © 2562 sun. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // here is where we start up the camera
        // for more details visits: https://www.letsbuildthatapp.com/course_video?id=1252
        let captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate( self  , queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
       // let request = VNCoreMLRequest(model: <#T##VNCoreMLModel#>, completionHandler: <#T##VNRequestCompletionHandler?##VNRequestCompletionHandler?##(VNRequest, Error?) -> Void#>)
        
    //    VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
        setupIdentifierConfidenceLabel()
    }
    
    
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       //  print("Camera was able to capture a frame", Date())
        
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedreq, err) in
            
            // perhaps check the err
            // print(finishedreq.results) // ความน่าจะเป็นทั้งหมด
            guard let results = finishedreq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else {return} // ความน่าจะเป็น No1.
            
            print("ID: \(firstObservation.identifier),Confidence : \(Int((firstObservation.confidence) * 100)) %")
            
            DispatchQueue.main.async {
                self.identifierLabel.text = "ID: \(firstObservation.identifier),Confidence : \(Int((firstObservation.confidence) * 100)) %"
            }
            
            
        }
        
        
        
       try? VNImageRequestHandler(cvPixelBuffer:  pixelBuffer , options: [:]).perform([request])
        
        
    }


}

