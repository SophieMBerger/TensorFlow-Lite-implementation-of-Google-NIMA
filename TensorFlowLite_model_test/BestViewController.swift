//
//  BestViewController.swift
//  TensorFlowLite_model_test
//
//  Created by Sophie Berger on 16.07.19.
//  Copyright © 2019 SophieMBerger. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLCommon

class BestViewController: UIViewController {
    
    @IBOutlet var bestMeanScoreLabel: UILabel!
    @IBOutlet var bestImageView: UIImageView!
    
    var viewController = ViewController()
    var aesthetic = 0.0
    var technical = 0.0
    var bestMeanScore = 0.0
    var nameOfBestImage = ""
    
    // Creating an interpreter from the models
    let aestheticOptions = ModelOptions(
        remoteModelName: "aesthetic_model",
        localModelName: "aesthetic_model")
    
    let technicalOptions = ModelOptions(
        remoteModelName: "technical_model",
        localModelName: "technical_model")
    
    var aestheticInterpreter: ModelInterpreter!
    var technicalInterpreter: ModelInterpreter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        aestheticInterpreter = ModelInterpreter.modelInterpreter(options: viewController.aestheticOptions)
        technicalInterpreter = ModelInterpreter.modelInterpreter(options: viewController.technicalOptions)
        
        let ioOptions = ModelInputOutputOptions()
        do {
            try ioOptions.setInputFormat(index: 0, type: .float32, dimensions: [1, 224, 224, 3])
            try ioOptions.setOutputFormat(index: 0, type: .float32, dimensions: [1, 10])
        } catch let error as NSError {
            print("Failed to set input or output format with error: \(error.localizedDescription)")
        }

        for name in viewController.imageNamesArray {
            let inputs = viewController.prepareImage(fromBestScore: true, inputImageTitle: name)
            viewController.runModels(fromBestScore: true, nameOfInputImage: name, aestheticInterpreter: aestheticInterpreter, technicalInterpreter: technicalInterpreter, inputs: inputs, ioOptions: ioOptions, sender: self)

        }
    }
}
