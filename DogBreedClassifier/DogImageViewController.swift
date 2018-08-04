//
//  DogImageViewController.swift
//  DogBreedClassifier
//
//  Created by Jae Seung Lee on 8/4/18.
//  Copyright © 2018 Jae Seung Lee. All rights reserved.
//

import UIKit

class DogImageViewController: UIViewController {

    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    var imageIdentifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        dogImageView.image = UIImage(named: imageIdentifier)
        imageLabel.text = imageIdentifier
    }

    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
