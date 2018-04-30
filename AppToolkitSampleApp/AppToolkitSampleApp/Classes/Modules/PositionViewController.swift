//
//  InfoViewController.swift
//  AppToolkitSampleApp
//
//  Created by Hamza Djerbi on 30/04/2018.
//  Copyright © 2018 Jibo Inc. All rights reserved.
//

import Foundation
import AppToolkit


class PositionViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var xTextField: UITextField!
    
    @IBOutlet weak var yTextField: UITextField!
    
    @IBOutlet weak var zTextField: UITextField!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

