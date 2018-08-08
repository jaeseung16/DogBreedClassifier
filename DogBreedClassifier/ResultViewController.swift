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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
