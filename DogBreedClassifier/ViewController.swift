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
        var requests: [VNRequest] = []
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
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
                
                // Check whether this is a dog.
            }
            
            // Check dog breed...
            
        }
        
        requests.append(faceDetectionRequest)
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
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
