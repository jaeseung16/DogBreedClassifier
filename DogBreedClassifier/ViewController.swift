//
//  ViewController.swift
//  DogBreedClassifier
//
//  Created by Jae Seung Lee on 6/13/18.
//  Copyright © 2018 Jae Seung Lee. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    // MARK: Properties
    // IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateTitleLabel(with: "Human or Dog?")
    }
    
    // Convenience methods
    func updateTitleLabel(with titleText: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = titleText
        }
    }
    
    func presentAlert(_ title: String, error: NSError) {
        // Always present alert on main thread.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
                                            // Do nothing -- simply dismiss alert.
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.HandlerForFaceDetection)
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([faceDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func choosePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        let presentLibrary = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let prompt = UIAlertController(title: "Choose a Photo", message: "Please choose a photo", preferredStyle: .actionSheet)
        
        prompt.addAction(presentLibrary)
        prompt.addAction(cancel)
        
        present(prompt, animated: true, completion: nil)
    }
    
    @IBAction func runResnet50(_ sender: UIButton) {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("can't load Resnet50 model")
        }
        
        let resnet50Request = VNCoreMLRequest(model: model, completionHandler: self.HandlerForResnet50)
        
        guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([resnet50Request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
    }
    
    @IBAction func findBreed(_ sender: UIButton) {
        guard let model = try? VNCoreMLModel(for: DogAppModel().model) else {
            fatalError("can't load Resnet50 model")
        }
        
        let dogModelRequest = VNCoreMLRequest(model: model, completionHandler: self.HandlerForDogModel)
        
        guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([dogModelRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
    }
}

// MARK:- Completion Hanlders
extension ViewController {
    func HandlerForFaceDetection(request: VNRequest, error: Error?) {
        if let error = error as NSError? {
            self.presentAlert("Face Detection Error", error: error)
            return
        }
        
        guard let results = request.results as? [VNFaceObservation] else {
            return
        }
        
        if results.count > 0 {
            for result in results {
                print("\(result)")
                print("\(result.boundingBox)")
            }
            
            self.updateTitleLabel(with: "Human detected")
            
        } else {
            self.updateTitleLabel(with: "This is not human")
        }
    }
    
    func HandlerForResnet50(request: VNRequest, error: Error?) {
        if let error = error as NSError? {
            self.presentAlert("Face Detection Error", error: error)
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        var dogCategory = [String: Float]()
        
        if results.count > 0 {
            for result in results {
                if result.confidence > 0.1 {
                    let ids = imagenetIDs.filter {$0.value == result.identifier}
                    
                    for id in ids {
                        if (id.key >= 151) && (id.key <= 268) {
                            dogCategory[id.value] = result.confidence
                        }
                    }
                    
                    print("\(result.confidence) - \(result.identifier)")
                }
            }
            
            print("\(dogCategory)")
            
            if dogCategory.count > 0 {
                self.updateTitleLabel(with: "It looks like a dog.")
            } else {
                self.updateTitleLabel(with: "It might not be a dog.")
            }
            
        } else {
            self.updateTitleLabel(with: "It might not be a dog.")
            // Check whether this is a dog.
        }
    }
    
    func HandlerForDogModel(request: VNRequest, error: Error?) {
        if let error = error as NSError? {
            self.presentAlert("Face Detection Error", error: error)
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        var dogCategory = [String: Float]()
        
        if results.count > 0 {
            for result in results {
                if result.confidence > 0.1 {
                    print("\(result.confidence) - \(result.identifier)")
                    dogCategory[result.identifier] = result.confidence
                }
            }
            
            print("\(dogCategory)")
            
            if dogCategory.count > 0 {
                self.updateTitleLabel(with: "It looks like a(n) \(results[0].identifier).")
            } else {
                self.updateTitleLabel(with: "It might not be a dog.")
            }
            
        } else {
            self.updateTitleLabel(with: "It might not be a dog.")
        }
    }
}

// MARK:- UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        imageView.image = originalImage
        
        let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(originalImage.imageOrientation.rawValue))
        
        guard let cgImage = originalImage.cgImage else {
            return
        }
        
        performVisionRequest(image: cgImage, orientation: cgOrientation!)
        
        dismiss(animated: true, completion: nil)
    }
}
