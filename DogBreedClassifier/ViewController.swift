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
    @IBOutlet weak var dogCheckButton: UIButton!
    @IBOutlet weak var breedCheckButton: UIButton!
    
    let coreMLClient = CoreMLClient()
    
    var isHuman = true
    var isDog = false
    
    var buttonState = ButtonState.chooseAPhoto
    var result = Result.other
    
    enum ButtonState {
        case chooseAPhoto
        case dogCheck
        case breedCheck
    }
    
    enum Result {
        case dog
        case human
        case other
    }
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateTitleLabel(with: "Human or Dog?")
        buttonState(state: buttonState)
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
        if let error = coreMLClient.performVisionRequest(image: image, orientation: orientation, completionHandler: self.HandlerForFaceDetection) {
            self.presentAlert("Image Request Failed", error: error)
        }
    }
    
    func buttonState(state: ButtonState) {
        switch state {
        case .chooseAPhoto:
            dogCheckButton.isEnabled = false
            breedCheckButton.isEnabled = false
        case .dogCheck:
            dogCheckButton.isEnabled = true
            breedCheckButton.isEnabled = false
        case .breedCheck:
            dogCheckButton.isEnabled = true
            breedCheckButton.isEnabled = true
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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let presentCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            }
            
            prompt.addAction(presentCamera)
        }
        
        prompt.addAction(presentLibrary)
        prompt.addAction(cancel)
        
        present(prompt, animated: true, completion: nil)
    }
    
    @IBAction func runResnet50(_ sender: UIButton) {
        guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        if let error = coreMLClient.performCoreMLRequest(model: "resnet50", image: ciImage, completionHandler: self.HandlerForResnet50) {
            self.presentAlert("Image Request Failed", error: error)
        }
    }
    
    @IBAction func findBreed(_ sender: UIButton) {
        guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        if let error = coreMLClient.performCoreMLRequest(model: "dogApp", image: ciImage, completionHandler: self.HandlerForDogModel) {
            self.presentAlert("Image Request Failed", error: error)
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
            self.isHuman = true
            self.isDog = false
            
        } else {
            self.updateTitleLabel(with: "This is not human")
            self.isHuman = false
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
                self.isHuman = false
                self.isDog = true
            } else {
                self.updateTitleLabel(with: "It might not be a dog.")
                self.isDog = false
            }
            
        } else {
            self.updateTitleLabel(with: "It might not be a dog.")
            self.isDog = false
        }
        
        DispatchQueue.main.async {
            self.buttonState = .breedCheck
            self.buttonState(state: self.buttonState)
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
            /*
                DispatchQueue.main.async {
                    let dogImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "DogImageViewController") as! DogImageViewController

                    dogImageViewController.imageIdentifier = "\(results[0].identifier)"
                    self.present(dogImageViewController, animated: true, completion: nil)
                }
            */

                DispatchQueue.main.async {
                    let resultViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
                    
                    if self.isHuman && !self.isDog {
                        resultViewController.firstString = "The person in the image"
                    } else if !self.isHuman && self.isDog {
                        resultViewController.firstString = "The dog in the image"
                    } else {
                        resultViewController.firstString = "Whatever in the image"
                    }
                    
                    resultViewController.secondString = "looks like a(n) \(results[0].identifier)."
                    
                    resultViewController.testImage = self.imageView.image
                    resultViewController.dogImage = UIImage(named: "\(results[0].identifier)")
                    
                    self.present(resultViewController, animated: true, completion: nil)
                }
                
            } else {
                self.updateTitleLabel(with: "It might not be a dog.")
            }
            
        } else {
            self.updateTitleLabel(with: "It might not be a dog.")
        }
        
        DispatchQueue.main.async {
            self.buttonState = .chooseAPhoto
            self.buttonState(state: self.buttonState)
        }
        
    }
}

// MARK:- UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            return
        }
        
        imageView.image = originalImage
        
        let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(originalImage.imageOrientation.rawValue))
        
        guard let cgImage = originalImage.cgImage else {
            return
        }
        
        performVisionRequest(image: cgImage, orientation: cgOrientation!)
        
        buttonState = .dogCheck
        buttonState(state: buttonState)
        
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
