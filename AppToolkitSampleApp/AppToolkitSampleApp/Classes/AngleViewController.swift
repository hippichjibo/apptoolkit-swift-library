//
//  AngleViewController.swift
//  AppToolkitSampleApp
//
//  Created by Hamza Djerbi on 30/04/2018.
//  Copyright © 2018 Jibo Inc. All rights reserved.
//

import Foundation
import AppToolkit


class AngleViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var resBut: UIButton!
    @IBOutlet weak var PsiLbl: UILabel!
    @IBOutlet weak var thetaLbl: UILabel!
    @IBOutlet weak var psiFld: UITextField!
    @IBOutlet weak var thetaFld: UITextField!
    @IBOutlet weak var res: UILabel!
    
    //var command: Commands = .lookAt
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
    
    override func viewDidAppear(_ animated: Bool) {
      
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func getValue(_ sender: Any) {

        if let theta = thetaFld.text, let thetaFloat = Float(theta),
            let psi = psiFld.text, let psiFloat = Float(psi) {
            var choosenAngle = AngleVector(theta:thetaFloat, psi: psiFloat)

            let transactionId = self.commandExecutor.executeLookAtCommand(lookAt: LookAtType.angle, callback: { (lookAtInfo, _) in
                
                //if let look = lookAtInfo, nil == look.error {
                    lookAtInfo?.angleTarget = choosenAngle
                print("\ndidReceiveLookAtAchieved at:\(lookAtInfo?.positionTarget!), angleTarget: \(lookAtInfo?.angleTarget!)\n")
                //}
            })
            
            // (LookAtAchievedInfo?, ErrorResponse?) -> ()
         print("Executing TransactionId: \(transactionId ?? "Empty")")
        }
    }
}
