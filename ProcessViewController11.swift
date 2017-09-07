//
//  ProcessViewController.swift
//  Project
//
//  Created by Billy Cai on 2017-07-06.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit

class ProcessViewController11: UIViewController {

    @IBOutlet weak var myImageView: UIImageView!
    var passImage: UIImage!
    var PM:Int!
    var brain: PMBrain!
    
    @IBOutlet weak var sliderBar: UISlider!
    @IBAction func sliderBar(_ sender: UISlider) {
     myImageView.image = OpenCVWrapper.showDetectedEdges(brain.storedPicture, sender.value)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        myImageView.image = brain.storedPicture
        sliderBar.minimumValue = Float(brain.sliderMin)
        sliderBar.maximumValue = 1
        // Do any additional setup after loading the view.
    }

    
    @IBAction func processImage(_ sender: UIButton) {
        let colorAverage = OpenCVWrapper.averageRGB(brain.storedPicture) as NSArray
        PM = brain.calculatePM(R: colorAverage[channel.red.rawValue] as! Double, G: colorAverage[channel.green.rawValue] as! Double, B: colorAverage[channel.blue.rawValue] as! Double)
        performSegue(withIdentifier: "processSegue", sender: self)
    }
    
    enum channel:Int {
        case red
        case green
        case blue
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationViewController = segue.destination
        
        if let resultViewController = destinationViewController as? ResultViewController{
            resultViewController.PM = String(self.PM)
        }
    }
    

}
