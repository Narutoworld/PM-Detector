//
//  PopoverViewController.swift
//  Project
//
//  Created by Billy Cai on 2017-07-25.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController{
    //intial custom view
    let arrowView1 = ArrowView()
    let arrowView2 = ArrowView()
    
    // actions and outlets
        ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
    @IBAction func selectUserGuide(_ sender: UIButton) {
        animateGuideView(guideImage: selectGuideImageView)
        if selectGuideImageView.alpha == 0 {
            view.addSubview(arrowView1)
        }
        else{
            arrowView1.removeFromSuperview()
            print("view has been removed")
        }
    }
    
    @IBOutlet weak var selectButton: UIButton!
    @IBAction func processUserGuide(_ sender: UIButton) {
        animateGuideView(guideImage: processGuideImageView)
        if processGuideImageView.alpha == 0 {
            view.addSubview(arrowView2)
        }
        else{
            arrowView2.removeFromSuperview()
            print("view has been removed")
        }
    }
    
    @IBOutlet weak var processButton: UIButton!
    
    @IBAction func resultUserGuide(_ sender: UIButton) {
        switch resultGuideLabel.alpha {
        case 1:
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { self.resultGuideLabel.alpha = 0 }, completion: nil)
        case 0:
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { self.resultGuideLabel.alpha = 1}, completion: nil)
        default: break
        }
    }
    
    @IBOutlet weak var resultButton: UIButton!
    
    @IBOutlet weak var selectGuideImageView: UIImageView!
    
    @IBOutlet weak var processGuideImageView: UIImageView!

    @IBOutlet weak var resultGuideLabel: UILabel!
        ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let blueColor : UIColor = UIColor( red: 68.0/255, green: 126.0/255, blue:194.0/255, alpha: 1.0 )
        
        selectGuideImageView.layer.borderColor = blueColor.cgColor
        selectGuideImageView.layer.borderWidth = 1
        selectGuideImageView.layer.cornerRadius = 10
        
        processGuideImageView.layer.borderColor = blueColor.cgColor
        processGuideImageView.layer.borderWidth = 1
        processGuideImageView.layer.cornerRadius = 10
        
        resultGuideLabel.layer.borderColor = blueColor.cgColor
        resultGuideLabel.layer.borderWidth = 1
        resultGuideLabel.layer.cornerRadius = 5
        resultGuideLabel.text = "    Air Quility Index value is shown here    "
        
    }
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(arrowView1)
        view.addSubview(arrowView2)
    }
    
    override func viewDidLayoutSubviews() {
        arrowView1.frame = CGRect(x: selectButton.frame.minX, y: selectButton.frame.maxY, width: selectButton.frame.size.width, height: processButton.frame.minY - selectButton.frame.maxY)
        arrowView1.backgroundColor = UIColor.white
        
        arrowView2.frame = CGRect(x: processButton.frame.minX, y: processButton.frame.maxY, width: processButton.frame.size.width, height: resultButton.frame.minY - processButton.frame.maxY)
        arrowView2.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectGuideImageView.alpha = 0
        processGuideImageView.alpha = 0
        resultGuideLabel.alpha = 0
    }

    @IBAction func dismissPopover(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func animateGuideView(guideImage: UIImageView){
        switch guideImage.alpha {
        case 1:
            UIView.animate(withDuration: 0, delay: 0, options: [], animations: { guideImage.alpha = 0}, completion: nil)
        case 0:
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [], animations: { guideImage.alpha = 1}, completion: nil)
        default: break
            
        }
    }
}


