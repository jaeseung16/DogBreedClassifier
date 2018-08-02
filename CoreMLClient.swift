//
//  CoreMLClient.swift
//  DogBreedClassifier
//
//  Created by Jae Seung Lee on 7/4/18.
//  Copyright © 2018 Jae Seung Lee. All rights reserved.
//

import Foundation
import Vision
import CoreML
import UIKit

class CoreMLClient {
    // Properties
    var resnet50: VNCoreMLModel
    var dogAppModel: VNCoreMLModel
    
    // MARK:- Methods
    init() {
        guard let resnet50 = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("can't load Resnet50 model")
        }
        
        self.resnet50 = resnet50
        
        guard let dogAppModel = try? VNCoreMLModel(for: DogAppModel().model) else {
            fatalError("can't load Dog App model")
        }
        
        self.dogAppModel = dogAppModel
    }
    
    func performCoreMLRequest(model: String, image: CIImage, completionHandler: @escaping VNRequestCompletionHandler) -> NSError? {
        
        var request: VNCoreMLRequest
        
        switch model {
        case "resnet50":
            request = VNCoreMLRequest(model: resnet50, completionHandler: completionHandler)
        case "dogApp":
            request = VNCoreMLRequest(model: dogAppModel, completionHandler: completionHandler)
        default:
            request = VNCoreMLRequest(model: resnet50, completionHandler: completionHandler)
        }
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: image)
        var errorToReturn: NSError?
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                errorToReturn = error
            }
        }
        
        return errorToReturn
    }
    
    
    func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation, completionHandler: @escaping VNRequestCompletionHandler) -> NSError? {
        let request = VNDetectFaceRectanglesRequest(completionHandler: completionHandler)
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        
        var errorToReturn: NSError?
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                errorToReturn = error
            }
        }
        
        return errorToReturn
    }
}
