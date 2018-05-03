//
//  LookAtActionViewController.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class LookAtActionViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
	
	var command: Commands = .lookAt
	lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
	
	@IBOutlet weak var consoleView: UITextView!
	
	var activeLookAtTransactionId: String? {
		didSet {
			self.cancelTransaction(id: oldValue)
		}
	}
	
	@IBAction func lookAtButtonDidPressed(_ sender: UIButton) {
		self.showLookAtActionSheet()
	}
	
	@IBAction func cancelButtonDidPressed(_ sender: UIButton) {
		self.cancelTransaction(id: self.activeLookAtTransactionId)
	}
	
	fileprivate func showLookAtActionSheet() {
		let actionSheet = self.makeLookAtActionSheet()
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	fileprivate func makeLookAtActionSheet() -> UIAlertController {
		let title = "LookAt"
		let message = "Choose \"LookAt\" type"
		let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		var actionSheetActions: [UIAlertAction] = LookAtType.allValues.flatMap { type in
			UIAlertAction(title: type.rawValue, style: .default, handler: { [unowned self] _ in
				self.log("Start executing LookAt: \(type.rawValue), \(type.targetType)")
                

                switch type.targetType {
                case .angle:
                    
                    self.performSegue(withIdentifier: "AngleViewSegue", sender: nil)
                    
//                    self.activeLookAtTransactionId = self.commandExecutor.executeLookAtCommand(angle: CommandRequester.Expression.Angle(angle: AngleVector(theta: 0, psi: 1.57)), callback: { (lookAtInfo, _) in
//                        if let look = lookAtInfo, nil == look.error {
//                            self.log("\ndidReceiveLookAtAcheived at:\(look.positionTarget!), angleTarget: \(look.angleTarget!)\n")
//                        }
//                    })
                case .position:
                    
                    self.performSegue(withIdentifier: "PositionSegue", sender: nil)
                    
//                    self.activeLookAtTransactionId = self.commandExecutor.executeLookAtCommand(position: CommandRequester.Expression.Position(position: Vector3(x: 0, y: 3.14, z: 0)), callback: { (lookAtInfo, _) in
//                        if let look = lookAtInfo, nil == look.error {
//                            self.log("\ndidReceiveLookAtAcheived at:\(look.positionTarget!), angleTarget: \(look.angleTarget!)\n")
//                        }
//                    })
                    
                case .screenCoords:
                    
                    self.performSegue(withIdentifier: "ScreenCoordinatesSegue", sender: nil)
                    
//                    self.activeLookAtTransactionId = self.commandExecutor.executeLookAtCommand(screenCoords: CommandRequester.Expression.ScreenCoords(coords: Vector2(x: 0, y: 5)), callback: { (lookAtInfo, _) in
//                        if let look = lookAtInfo, nil == look.error {
//                            self.log("\ndidReceiveLookAtAcheived at:\(look.positionTarget!), angleTarget: \(look.angleTarget!)\n")
//                        }
//                    })
                    
                case .entity:
                    self.activeLookAtTransactionId = self.commandExecutor.executeLookAtCommand(entity: CommandRequester.Expression.Entity(entity: 1), callback: { (lookAtInfo, _) in
                        if let look = lookAtInfo, nil == look.error {
                            self.log("\ndidReceiveLookAtAcheived at:\(look.positionTarget!), angleTarget: \(look.angleTarget!)\n")
                        }
                    })
                }
                
				self.log("Executing TransactionId: \(self.activeLookAtTransactionId ?? "Empty")")
			})
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		actionSheetActions.append(cancelAction)
		
		actionSheetActions.forEach(actionSheet.addAction)
		
		return actionSheet
	}
	
	fileprivate func cancelTransaction(id: TransactionId?) {
		guard let transactionToCancel = id else {
			return
		}
        

		commandExecutor.cancelCommand(transactionId: transactionToCancel, completion: nil)
	}
    
}


