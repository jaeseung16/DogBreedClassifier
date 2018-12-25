//
//  ResultViewController.swift
//  DogBreedClassifier
//
//  Created by Jae Seung Lee on 8/7/18.
//  Copyright © 2018 Jae Seung Lee. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var firstStringLabel: UILabel!
    @IBOutlet weak var secondStringLabel: UILabel!
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var dogImageView: UIImageView!
    
    var firstString: String!
    var secondString: String!
    var testImage: UIImage!
    var dogImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstStringLabel.text = firstString
        secondStringLabel.text = secondString
        testImageView.image = testImage
        dogImageView.image = dogImage
    }

    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func presentActivityController(_ sender: UIBarButtonItem) {
        let combinedImage = generateCombinedImage()
        
        let activityController = UIActivityViewController(activityItems: [combinedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            guard completed else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
}

// MARK: Methods to create a combined image
extension ResultViewController {
    func generateCombinedImage() -> UIImage {
        // Image size to capture
        let imageSizeForCapture = imageSize()
        
        // Shift the frame of the view for capture
        let frameForCapture = shiftedFrame(for: imageSizeForCapture)
        
        // Render view to an image
        UIGraphicsBeginImageContext(imageSizeForCapture)
        view.drawHierarchy(in: frameForCapture, afterScreenUpdates: true)
        let combinedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    func imageSize() -> CGSize {
        let imageSize = dogImageView.image!.size
        
        let ratioWidth = dogImageView.frame.size.width / imageSize.width
        let ratioHeight = dogImageView.frame.size.height / imageSize.height
        
        let scale = ratioWidth < ratioHeight ? ratioWidth : ratioHeight
        
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }
    
    func shiftedFrame(for imageSize: CGSize) -> CGRect {
        let xOrigin = self.view.frame.origin.x - (self.view.frame.size.width - imageSize.width) * 0.5
        let yOrigin = self.view.frame.origin.y - dogImageView.frame.origin.y - (dogImageView.frame.size.height - imageSize.height) * 0.5
        
        let shiftOrigin = CGPoint(x: xOrigin, y: yOrigin)
        
        return CGRect(origin: shiftOrigin, size: self.view.frame.size)
    }
}
