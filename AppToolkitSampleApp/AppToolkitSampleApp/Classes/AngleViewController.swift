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
            
            let transcationId = self.commandExecutor.executeLookAtCommand(angle: CommandRequester.Expression.Angle(angle: AngleVector(theta: thetaFloat, psi: psiFloat)), callback: { (lookAtInfo, _) in
                if let look = lookAtInfo, nil == look.error {
                    print("\ndidReceiveLookAtAcheived at:\(look.positionTarget!), angleTarget: \(look.angleTarget!)\n")
                }
            })
            ((LookAtAchievedInfo?, ErrorResponse?) -> ()).self
            print("Executing TransactionId: \(transcationId ?? "Empty")")
            
        }
    }
}
