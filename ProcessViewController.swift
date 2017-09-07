//
//  FilterViewController.swift
//  Project
//
//  Created by Billy Cai on 2017-07-06.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit
import ImageSource
import Paparazzo
import TNSlider

class ProcessViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,TNSliderDelegate{
    ///////////////////////////////////////////////LINE/////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        slider.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    ///////////////////////////////////////////////Actions and Outlets/////////////////////////////////////////////////////////////////
    @IBAction func processImage(_ sender: UIButton)
    {
        //error detection may apply
        if brain.storedPicture != nil{
            let colorAverage = OpenCVWrapper.averageRGB(brain.storedPicture) as NSArray
            PM = brain.calculatePM(R: colorAverage[channel.red.rawValue] as! Double, G: colorAverage[channel.green.rawValue] as! Double, B: colorAverage[channel.blue.rawValue] as! Double)
            performSegue(withIdentifier: "processSegue", sender: self)
        }
        else {
            showAlert()
        }
    }

    @IBOutlet weak var processImageButton: UIButton!
    
    
    @IBOutlet weak var slider: TNSlider!
    @IBAction func sliderBar(_ sender: TNSlider) {
        if brain.storedPicture != nil{
            sender.minimum = Float(brain.sliderMin)
            sender.maximum = 1
            myImageView.image = OpenCVWrapper.showDetectedEdges(brain.storedPicture, sender.value)
            ifSliderUsed = true
        }
        else {
            showAlert()
        }
    }
    
    // PAPARAZZO init function
    
    private var photos = [ImageSource]()
    
    private func updateUI() {
        myImageView.setImage(fromSource: photos.first)
        brain.storedPicture = myImageView.image
        UIImageWriteToSavedPhotosAlbum(brain.storedPicture, nil, nil, nil)
        brain.sliderMin = OpenCVWrapper.edgeDetection(brain.storedPicture)
        ifSliderUsed = false
    }
    
    // init model
    var PM:Double!
    var BC:Int!
    var brain:PMBrain!
    var ifSliderUsed = false {
        willSet{
            if newValue == true {
                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {self.processImageButton.alpha = 1}, completion: nil)
            }
            else{
                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {self.processImageButton.alpha = 0}, completion: nil)
            }
        }
    }
    @IBOutlet weak var myImageView: UIImageView!
    
    enum channel:Int {
        case red
        case green
        case blue
    }
    
    // the default Photo Library
    let picker = UIImagePickerController()

    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem)
    {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
        picker.popoverPresentationController?.barButtonItem = sender
    }

    @IBAction func shootPhoto(_ sender: UIBarButtonItem)
    {
        showCameraModal()
    }
    
    private func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
        ///////////////////////////////////////////////////Alert for user///////////////////////////////////////////////////
    
    private func showAlert(){
        let alertController = UIAlertController(title: "None Image has been selected", message: "Please select picture from picture or photo library", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Close",style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    
    //MARK: - Delegates
    // The default UIimageView controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        myImageView.contentMode = .scaleAspectFit
        myImageView.image = chosenImage
        brain.storedPicture = chosenImage
        brain.sliderMin = OpenCVWrapper.edgeDetection(brain.storedPicture)
        ifSliderUsed = false
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showCameraModal(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var theme = PaparazzoUITheme()
            theme.shutterButtonColor = UIColor(colorLiteralRed: 0.0, green: 0.59, blue: 1.0, alpha: 1.0)
            theme.accessDeniedTitleFont = .boldSystemFont(ofSize: 17)
            theme.accessDeniedMessageFont = .systemFont(ofSize: 17)
            theme.accessDeniedButtonFont = .systemFont(ofSize: 17)
            theme.cameraContinueButtonTitleFont = .systemFont(ofSize: 17)
            theme.cancelRotationTitleFont = .boldSystemFont(ofSize: 14)
            
            let assemblyFactory = Paparazzo.AssemblyFactory(theme:theme)
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            let mediaPickerController = assembly.module(
                items: [],
                selectedItem: nil,
                maxItemsCount: 20,
                cropEnabled: true,
                cropCanvasSize: CGSize(width: 1280, height: 960),
                configuration: { [weak self] module in
                    weak var module = module
                    
                    module?.setContinueButtonTitle("Done")
                    module?.setContinueButtonEnabled(true)
                    
                    module?.onFinish = { mediaPickerItems in
                        module?.dismissModule()
                        
                        // storing picked photos in instance var and updating UI
                        self?.photos = mediaPickerItems.map { $0.image }
                        self?.updateUI()
                    }
                    module?.onCancel = {
                        module?.dismissModule()
                    }
                }
            )
            self.navigationController?.pushViewController(mediaPickerController, animated: true)
        } else {
            noCamera()
        }
    }
    
    func slider(_ slider: TNSlider, displayTextForValue value: Float) -> String {
        return String(format: " sliding ")
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationViewController = segue.destination
        
        if let resultViewController = destinationViewController as? ResultViewController{
            resultViewController.PM = self.PM
            resultViewController.brain = self.brain
        }
    }
    

}
