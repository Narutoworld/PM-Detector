//
//  ResultViewController.swift
//  Project
//
//  Created by Billy Cai on 2017-07-06.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit
import HGCircularSlider

class ResultViewController: UIViewController {

    @IBOutlet weak var PMLabel: UILabel!
    @IBOutlet weak var AQILabel: UILabel!
        
    @IBOutlet weak var healthImpactInfo: UILabel!
    @IBOutlet weak var customSlider: CircularSlider!
    
    var brain:PMBrain!
    var PM:Double!
    var AQI:Double!
    var AQIWrap:AQIInfo!
    
    //Setup for animation with timer
    
    let totalTimeInterval: TimeInterval = 1.00
    
    var estimatedTimeInterval: TimeInterval {
        get {
            return AQI/500*totalTimeInterval
        }
    }
    
    func updateSlider(){
        if customSlider.endPointValue <= CGFloat(AQI){
            customSlider.endPointValue += 1
            if let aqiInfo = brain.selectAQIInformation(aqi: Double(customSlider.endPointValue)){
                customSlider.diskFillColor = aqiInfo.color
            }
        }
        else {
            sliderTimer.invalidate()
            customSlider.endPointValue = CGFloat(AQI)
        }
    }
    
    func updatePMLabel(){
        let range: Range<String.Index> = PMLabel.text!.range(of: " ")!
        var number = Double(PMLabel.text!.substring(to: range.lowerBound))!
        if number <= PM {
            number += 1
            PMLabel.text =  String(format: "%0.2f µg", number)
        }
        else{
            PMLabelTimer.invalidate()
            PMLabel.text =  String(format: "%0.2f µg", PM)
        }
    }
    
    func revertChange(){
        customSlider.endPointValue = CGFloat(AQI)
    }
    
    var sliderTimer = Timer()
    var PMLabelTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PM > 0 {
        AQI = brain.calculateAQI(pmAverage: PM/24)
        AQIWrap = brain.selectAQIInformation(aqi: AQI)
        AQILabel.text = AQIWrap.statement
        healthImpactInfo.text = AQIWrap.description
        customSlider.addTarget(self, action: #selector(revertChange), for: .valueChanged)
        }
        else{
            showAlert()
            AQI = 2.0
            AQIWrap = AQIInfo()
            AQILabel.text = AQIWrap.statement
            healthImpactInfo.text = "The following information is for debug purpose: \nR:\(brain.red!) \n G:\(brain.green!) \n B:\(brain.blue!)"
            customSlider.addTarget(self, action: #selector(revertChange), for: .valueChanged)
        }
        // Do any additional setup after loading the view.
    }
    
   private func showAlert(){
        let alertController = UIAlertController(title: "the estimated PM is below zero", message: "Please adjust the multi-linear regression model", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Close",style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AQILabel.backgroundColor = AQIWrap.color
        healthImpactInfo.layer.borderWidth = 3
        healthImpactInfo.layer.cornerRadius = 5
        healthImpactInfo.layer.borderColor = AQIWrap.color.cgColor
        customSlider.endPointValue = 0
        PMLabel.text = "0 µg"
        customSlider.diskFillColor = UIColor.green
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sliderTimer = Timer.scheduledTimer(timeInterval: estimatedTimeInterval/AQI, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        PMLabelTimer = Timer.scheduledTimer(timeInterval: estimatedTimeInterval/PM, target: self, selector: #selector(self.updatePMLabel), userInfo: nil, repeats: true)
    }
}
