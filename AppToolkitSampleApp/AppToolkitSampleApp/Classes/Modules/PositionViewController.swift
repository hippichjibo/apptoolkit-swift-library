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
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var xTextField: UITextField!
    
    @IBOutlet weak var rButton: UIButton!
    @IBOutlet weak var yTextField: UITextField!
    
    @IBOutlet weak var zTextField: UITextField!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func getPosition(_ sender: Any) {
        
        
        if  let xValue = xTextField.text ,  let xFloat = Float(xValue),
            let yValue = yTextField.text ,  let yFloat = Float(yValue),
            let zvalue = zTextField.text ,  let zFloat = Float(zvalue) {
            
            var positonScreen = Vector3(x: xFloat, y: yFloat, z: zFloat)
            
//            let transactionId = self.commandExecutor.executeLookAtCommand(lookAt: LookAtType.angle, callback: { (lookAtInfo, _) in
//            if let look = lookAtInfo, nil == look.error {
//                lookAtInfo?.positionTarget = positonScreen
//                    print("\ndidReceiveLookAtAchieved at:\(lookAtInfo?.positionTarget!), angleTarget: \(lookAtInfo?.angleTarget!)\n")
//                }
//                })
//
//                // (LookAtAchievedInfo?, ErrorResponse?) -> ()
//                print("Executing TransactionId: \(transactionId ?? "Empty")")
//            }
        
        }
        
    }
        



