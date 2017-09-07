//
//  SelectViewController.swift
//  Project
//
//  Created by Billy Cai on 2017-07-06.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit
import Paparazzo
import ImageSource

class SelectViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.layer.cornerRadius = 10
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor.blue.cgColor
        maskButton.layer.cornerRadius = 10
        maskButton.layer.borderWidth = 1
        maskButton.layer.borderColor = UIColor.blue.cgColor

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
        ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
    //outletes
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var maskButton: UIButton!
    var myImageView = UIImageView()
    var brain = PMBrain()
    
        ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
    // MARK: - Navigation

    @IBAction func activeFilterSegue(_ sender: UIButton) {
        showCameraModal()
    }
    
    @IBAction func activeMaskSegue(_ sender: UIButton) {
        performSegue(withIdentifier: "maskSegue", sender: self)
    }
    private var photos = [ImageSource]()
    
    private func updateUI() {
        myImageView.setImage(fromSource: photos.first)
        print("first")
        print(myImageView)
        brain.storedPicture = myImageView.image
        print("second")
        UIImageWriteToSavedPhotosAlbum(brain.storedPicture, nil, nil, nil)
        print("third")
        brain.sliderMin = OpenCVWrapper.edgeDetection(brain.storedPicture)
        print("forth")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        
        if let processViewController = destinationViewController as? ProcessViewController{
            processViewController.brain = self.brain
        }
    }
    
}
