//
//  ScreenCoordinates.swift
//  AppToolkitSampleApp
//
//  Created by Hamza Djerbi on 30/04/2018.
//  Copyright © 2018 Jibo Inc. All rights reserved.
//

import Foundation
import AppToolkit


class ScreenCoordinatesViewController: UIViewController {
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared

    @IBOutlet var back: UIView!
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var xField: UITextField!
    
    @IBOutlet weak var yLbl: UILabel!
    @IBOutlet weak var xLbl: UILabel!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var yField: UITextField!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
}
    @IBAction func getValues(_ sender: Any) {
        
        
        
        if  let xVal = xField.text ,  let xFloat = Float(xVal),
            let yVal = yField.text , let yFloat = Float(yVal){
            var ScreenCoord = Vector2(x: xFloat, y: yFloat)
            
            
            let transactionId = self.commandExecutor.executeLookAtCommand(screenCoords: CommandRequester.Expression.ScreenCoords(coords: Vector2(x: xFloat, y: yFloat)), callback: { (lookAtInfo, _) in
                if let look = lookAtInfo, nil == look.error {
                    print("\ndidReceiveLookAtAcheived at:\(look.positionTarget!), angleTarget: \(look.angleTarget!)\n")
                }
                
            })
                // (LookAtAchievedInfo?, ErrorResponse?) -> ()
                print("Executing TransactionId: \(transactionId ?? "Empty")")
            
        }
        
    }
}

