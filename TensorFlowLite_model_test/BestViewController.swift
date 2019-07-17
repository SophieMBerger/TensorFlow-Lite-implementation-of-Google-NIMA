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
    
    var imageNamesArray = ["jump-1209647_640",
                           "42039",
                           "42040",
                           "42041",
                           "42042",
                           "42044",
                           "antelope-canyon-1128815_640",
                           "architecture-768432_640",
                           "baby-1151351_640",
                           "beach-84533_640",
                           "beach-1236581_640",
                           "blue-1845901_640",
                           "boat-house-192990_640",
                           "bridge-53769_640",
                           "buildings-1245953_640",
                           "california-1751455_640",
                           "canyon-4245261_640",
                           "castle-505878_640",
                           "children-1822704_640",
                           "cinque-terre-279013_640",
                           "city-647400_640",
                           "closedEyes",
                           "clouds-4261864_640",
                           "country-house-540796_640",
                           "dolphin-203875_640",
                           "father-656734_640",
                           "fireworks",
                           "fishermen-504098_640",
                           "fountain-197334_640",
                           "fountain-461552_640",
                           "fountain-675488_640",
                           "fox-1284512_640",
                           "godafoss-1840758_640",
                           "horse-1330690_640",
                           "hotelRoom",
                           "iceland-1979445_640",
                           "imagineCup",
                           "IMG_0825",
                           "IMG_1629",
                           "IMG_1630",
                           "IMG_1633",
                           "IMG_5519",
                           "IMG_8624",
                           "IMG_8829",
                           "italy-1587287_640",
                           "italy-2273767_640",
                           "japan-2014618_640",
                           "japanese-cherry-trees-324175_640",
                           "ladybugs-1593406_640",
                           "legs-434918_640",
                           "lighthouse-1034003_640",
                           "lion",
                           "maldives-666122_640",
                           "milky-way-916523_640",
                           "moon-1859616_640",
                           "moon-2245743_640",
                           "nature-1547302_640",
                           "netherlands-685392_640",
                           "neuschwanstein-castle-467116_640",
                           "new-years-eve-1953253_640",
                           "openEyes",
                           "pedestrians-400811_640",
                           "people-3104635_640",
                           "person-1245959_640"]

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

        for name in imageNamesArray {
            let inputs = viewController.prepareImage(fromBestScore: true, inputImageTitle: name)
            viewController.runModels(fromBestScore: true, nameOfInputImage: name, aestheticInterpreter: aestheticInterpreter, technicalInterpreter: technicalInterpreter, inputs: inputs, ioOptions: ioOptions, sender: self)

        }
    }
}
