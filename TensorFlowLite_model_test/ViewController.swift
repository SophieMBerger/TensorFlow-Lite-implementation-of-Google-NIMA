//
//  ViewController.swift
//  TensorFlowLite_model_test
//
//  Created by Sophie Berger on 12.07.19.
//  Copyright © 2019 SophieMBerger. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLCommon

class ViewController: UIViewController {
    
    @IBOutlet private var meanLabel: UILabel!
    @IBOutlet private var aestheticLabel: UILabel!
    @IBOutlet private var technicalLabel: UILabel!
    @IBOutlet private var inputImageView: UIImageView!
    @IBOutlet private var picker: UIPickerView!
    
    var aesthetic = 0.0
    var technical = 0.0
    var inputs = ModelInputs()
    var ioOptions = ModelInputOutputOptions()
    let roundingDigits: Double = 100000
    
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
                      "Microsoft",
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
        
        picker.delegate = self
        picker.dataSource = self
        
        let inputImageTitle = imageNamesArray.first!
        
        aestheticInterpreter = ModelInterpreter.modelInterpreter(options: aestheticOptions)
        technicalInterpreter = ModelInterpreter.modelInterpreter(options: technicalOptions)
        
        // Specifying the I/O format of the models
        let ioOptions = ModelInputOutputOptions()
        do {
            try ioOptions.setInputFormat(index: 0, type: .float32, dimensions: [1, 224, 224, 3])
            try ioOptions.setOutputFormat(index: 0, type: .float32, dimensions: [1, 10])
        } catch let error as NSError {
            print("Failed to set input or output format with error: \(error.localizedDescription)")
        }
        
        self.ioOptions = ioOptions
        inputs = prepareImage(fromBestScore: false, inputImageTitle: inputImageTitle)
        
        runModels(fromBestScore: false, nameOfInputImage: "", aestheticInterpreter: aestheticInterpreter, technicalInterpreter: technicalInterpreter, inputs: inputs, ioOptions: ioOptions, sender: BestViewController())
    }
    
    func prepareImage(fromBestScore: Bool, inputImageTitle: String) -> ModelInputs{
        // Set and prepare the input image
        let image: CGImage = (UIImage(named: inputImageTitle)?.cgImage)!
        
        if !fromBestScore {
            inputImageView.image = UIImage(cgImage: image)
        }
        
        guard let context = CGContext(
            data: nil,
            width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            ) else { return ModelInputs()}
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        guard let imageData = context.data else { return ModelInputs()}
        
        let inputs = ModelInputs()
        var inputData = Data()
        do {
            for row in 0 ..< 224 {
                for col in 0 ..< 224 {
                    let offset = 4 * (col * context.width + row)
                    // (Ignore offset 0, the unused alpha channel)
                        let red = imageData.load(fromByteOffset: offset+1, as: UInt8.self)
                        let green = imageData.load(fromByteOffset: offset+2, as: UInt8.self)
                        let blue = imageData.load(fromByteOffset: offset+3, as: UInt8.self)
                    
                    // Normalize channel values to [0.0, 1.0]. This requirement varies
                    // by model. For example, some models might require values to be
                    // normalized to the range [-1.0, 1.0] instead, and others might
                    // require fixed-point values or the original bytes.
                    
                    var normalizedRed = Float32(red) / 255.0
                    var normalizedGreen = Float32(green) / 255.0
                    var normalizedBlue = Float32(blue) / 255.0
                    
                    // Append normalized values to Data object in RGB order.
                    let elementSize = MemoryLayout.size(ofValue: normalizedRed)
                    var bytes = [UInt8](repeating: 0, count: elementSize)
                    memcpy(&bytes, &normalizedRed, elementSize)
                    inputData.append(&bytes, count: elementSize)
                    memcpy(&bytes, &normalizedGreen, elementSize)
                    inputData.append(&bytes, count: elementSize)
                    memcpy(&bytes, &normalizedBlue, elementSize)
                    inputData.append(&bytes, count: elementSize)
                }
            }
            try inputs.addInput(inputData)
        } catch let error {
            print("Failed to add input: \(error)")
        }
        return inputs
    }
    
    func runModels(fromBestScore: Bool, nameOfInputImage: String? = nil, aestheticInterpreter: ModelInterpreter, technicalInterpreter: ModelInterpreter, inputs: ModelInputs, ioOptions: ModelInputOutputOptions, sender: BestViewController? = nil) {
        
        var roundedAesthetic = 0.0
        var roundedTechnical = 0.0
        var roundedMean = 0.0
        
        aestheticInterpreter.run(inputs: inputs, options: ioOptions) { outputs, error in
            self.aesthetic = 0.0
            self.technical = 0.0
            
            guard error == nil, let outputs = outputs else { return }
            // Process outputs
            // Get first and only output of inference with a batch size of 1
            let output = try? outputs.output(index: 0) as? [[NSNumber]]
            let probabilities = output?[0]
            
            for value in probabilities! {
                guard let index = probabilities?.firstIndex(of: value) else { return }
                // To get the over all score multiply each score between 1 and 10 by the probability of having said score and then add them together
                self.aesthetic += Double(truncating: value) * Double(index + 1)
                roundedAesthetic = round(self.aesthetic * self.roundingDigits) / self.roundingDigits
            }
            if !fromBestScore {
                self.aestheticLabel.text = "The aesthetic score is: \(self.aesthetic)"
            }
        }
        
        technicalInterpreter.run(inputs: inputs, options: ioOptions) { outputs, error in
            guard error == nil, let outputs = outputs else { return }
            // Process outputs
            // Get first and only output of inference with a batch size of 1
            let output = try? outputs.output(index: 0) as? [[NSNumber]]
            let probabilities = output?[0]
            
            for value in probabilities! {
                guard let index = probabilities?.firstIndex(of: value) else { return }
                // To get the over all score multiply each score between 1 and 10 by the probability of having said score and then add them together
                self.technical += Double(truncating: value) * Double(index + 1)
                roundedTechnical = round(self.technical * self.roundingDigits) / self.roundingDigits
            }
            if !fromBestScore {
                self.technicalLabel.text = "The technical score is: \(self.technical)"
                let meanScore = (self.aesthetic + self.technical) / 2
                roundedMean = round(meanScore * self.roundingDigits) / self.roundingDigits
                self.meanLabel.text = "The average score is: \(meanScore)"
            } else {
                let currentMeanScore = (self.aesthetic + self.technical) / 2
                if currentMeanScore > sender!.bestMeanScore {
                    roundedMean = round(currentMeanScore * self.roundingDigits) / self.roundingDigits
                    sender!.bestMeanScore = currentMeanScore
                    sender!.nameOfBestImage = nameOfInputImage!
                    
                    sender!.bestImageView.image = UIImage(named: sender!.nameOfBestImage)
                    sender!.bestMeanScoreLabel.text = "The best mean score is: \(sender!.bestMeanScore)"
                }
            }
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imageNamesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return imageNamesArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let inputs = prepareImage(fromBestScore: false, inputImageTitle: imageNamesArray[row])
        runModels(fromBestScore: false, aestheticInterpreter: aestheticInterpreter, technicalInterpreter: technicalInterpreter, inputs: inputs, ioOptions: ioOptions)
    }
    
}
