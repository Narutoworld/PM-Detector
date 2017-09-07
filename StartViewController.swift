//
//  ViewController.swift
//  Project
//
//  Created by Billy Cai on 2017-07-06.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    
    @IBAction func startButton(_ sender: UIButton) {
    let alertController = UIAlertController(title: "User Guide", message: "workflow", preferredStyle: .alert)
    let nextAction = UIAlertAction(title: "Next",style: .default, handler: nil)
        
        alertController.addAction(nextAction)
        present(alertController, animated: true, completion: nil)
//        performSegue(withIdentifier: "startSegue", sender: self)
    }
    


}

