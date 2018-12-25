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
        
        
        let activityController = UIActivityViewController(activityItems: [dogImageView.image!], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            guard completed else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
}
