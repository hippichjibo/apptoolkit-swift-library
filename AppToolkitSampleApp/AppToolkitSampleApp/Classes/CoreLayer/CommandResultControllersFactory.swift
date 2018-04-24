//
//  CommandExecutor.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import AppToolkit
import UIKit

enum Commands: String {
	case undefined
	case getConfig
    case setConfig
	case lookAt
	case video
    case photo
	case say
	case listen
	case faceEntity
    case display
    case motion
    case headTouch
    case fetchAsset
	case screenGesture
}

enum LookAtType: String {
	case position 		= "Position"
	case angle 			= "Angle"
	case screenCoords 	= "Screen Coordinates"
	case entity			= "Entity"
	
	static var allValues: [LookAtType] = [.position, .angle, .screenCoords, .entity]
	static var allRawValues: [String] = allValues.flatMap { $0.rawValue }
	
	var targetType: LookAtTargetType {
		switch self {
		case .position:
			let vector3 = Vector3(x: 0, y: 3.14, z: 0)
			return LookAtTargetType.position(position: vector3)
		case .angle:
			let angle = AngleVector(theta: 0, psi: 1.57)
			return LookAtTargetType.angle(angle: angle)
		case .screenCoords:
			let vector2 = Vector2(x: 0, y: 5)
			return LookAtTargetType.screenCoords(screenCoords: vector2)
		case .entity:
			return LookAtTargetType.entity(entity: 1)
		}
	}
}

typealias TransactionId = String

protocol CommandConfigurable where Self: UIViewController {
	var command: Commands {get set}
}

protocol ConsoleLoggable where Self: UIViewController {
	var consoleView: UITextView! { get set }
}
extension ConsoleLoggable {
	func log(_ msg: String) {
		let logMsg = "\(msg)\n\(consoleView.text ?? "")"
		consoleView.text = logMsg
	}
}

class CommandExecutor {
	
	static let shared: CommandExecutor = CommandExecutor()
	private init() { }
	
	lazy var remote: CommandRequester = CommandRequester()
	
    @discardableResult
	func executeGetConfigCommand(completion: ConfigProtocol.GetConfigClosure?) -> TransactionId? {
		return remote.config?.get(completion: completion)
	}
	
    @discardableResult
    func executeSetConfigCommand(_ options: SetConfigOptionsProtocol, completion: ConfigProtocol.SetConfigClosure?) -> TransactionId? {
        return remote.config?.set(options, completion: completion)
    }

    @discardableResult
	func executeTakeVideoCommand(callback: CaptureProtocol.TakeVideoClosure?) -> TransactionId? {
        return remote.media?.capture?.video(duration: 1.0, completion: callback)
	}
	
	func cancelCommand(transactionId: String,
	                   completion: CommandRequester.CompletionHandler?) {
		remote.cancel(transactionId: transactionId, completion: completion)
	}
    func executeLookAtCommand(position: CommandRequester.Expression.Position, callback: ExpressionProtocol.LookAtClosure?) -> TransactionId? {
        return remote.expression?.look(position: position, completion: callback)
    }
    func executeLookAtCommand(angle: CommandRequester.Expression.Angle, callback: ExpressionProtocol.LookAtClosure?) -> TransactionId? {
        return remote.expression?.look(angle: angle, completion: callback)
    }
    func executeLookAtCommand(screenCoords: CommandRequester.Expression.ScreenCoords, callback: ExpressionProtocol.LookAtClosure?) -> TransactionId? {
        return remote.expression?.look(screenCoords: screenCoords, completion: callback)
    }
    func executeLookAtCommand(entity: CommandRequester.Expression.Entity, callback: ExpressionProtocol.LookAtClosure?) -> TransactionId? {
        return remote.expression?.look(entity: entity, completion: callback)
    }
	
	func executeSayCommand(phrase: String,
                           completion: ExpressionProtocol.SayClosure?) -> TransactionId? {
        return remote.expression?.say(phrase: phrase, completion: completion)
	}
	
	func executeGetFaceEntity(callback: SubscribeProtocol.TrackedEntityClosure?) -> TransactionID? {
        return remote.perception?.subscribe?.face(completion: callback)
	}
    
    func executeTakePhotoCommand(camera: Camera = .left, resolution: CameraResolution = .medium, distortion: Bool = true, callback: CaptureProtocol.TakePhotoClosure?) -> TransactionId? {
        return remote.media?.capture?.photo(camera: camera, resolution: resolution, distortion: distortion, completion: callback)
    }
    
    func executeDisplayEye(_ view: String, callback: DisplayProtocol.DisplayClosure?) -> TransactionID? {
        return remote.display?.swap(view: CommandRequester.Display.EyeView(view: view), completion: callback)
    }

    func executeDisplayText(_ text: String, in view: String, callback: DisplayProtocol.DisplayClosure?) -> TransactionID? {
        return remote.display?.swap(view: CommandRequester.Display.TextView(text: text, view: view), completion: callback)
    }

    func executeDisplayImage(_ image: ImageData, in view: String, callback: DisplayProtocol.DisplayClosure?) -> TransactionID? {
        return remote.display?.swap(view: CommandRequester.Display.ImageView(imageData: image, view: view), completion: callback)
    }
    
    func executeGetMotion(callback: SubscribeProtocol.MotionClosure?) -> TransactionID? {
        return remote.perception?.subscribe?.motion(completion: callback)
    }

    func executeListenForSpeech(maxSpeechTimeOut: Timeout = 15, maxSpeechNoTimeout: Timeout = 15, languageCode: LangCode = .enUS, callback: ListenProtocol.ListenClosure?) -> TransactionID? {
        return remote.listen?.start(maxSpeechTimeOut: maxSpeechTimeOut, maxSpeechNoTimeout: maxSpeechNoTimeout, languageCode: languageCode, completion: callback)
    }

    func executeListenForHeadTouch(callback: SubscribeProtocol.HeadTouchClosure?) -> TransactionID? {
        return remote.perception?.subscribe?.headTouch(completion: callback)
    }

    @discardableResult
    func executeFetchAsset(_ uri: String, name: String, callback: AssetsProtocol.FetchAssetClosure?) -> TransactionID? {
        return remote.assets?.load(uri: uri, name: name, completion: callback)
    }

    func executeListenForScreenGesture(_ params: ScreenGestureListenParams, callback: SubscribeProtocol.ScreenGestureClosure?) -> TransactionID?{
        return remote.display?.subscribe?.gesture(params, completion: callback)
    }
    
}

class CommandResultControllersFactory {
	
    func viewController(for command: Commands, robot: Robot?) -> UIViewController? {
		switch command {
		case .getConfig:
			return simpleTextViewController(command: command)
        case .setConfig:
            return setConfigViewController(command: command)
		case .video:
			return videoViewController(command: command, robot: robot)
		case .lookAt:
			return lookAtViewController(command: command)
		case .say:
			return sayViewController(command: command)
		case .faceEntity:
			return simpleTextViewController(command: command)
        case .photo:
            return photoViewController(command: command, robot: robot)
        case .display:
            return displayViewController(command: command)
        case .motion:
            return motionViewController(command: command)
        case .undefined:
            print("Error: should never be happen!!!")
            break
        case .listen:
            return listenViewController(command: command)
        case .headTouch:
            return headTouchViewController(command: command)
        case .fetchAsset:
            return fetchAssetViewController(command: command)
        case .screenGesture:
            return screenGestureViewController(command: command)
//            print("\nNot implemented yet: \(command)\n")
        }
		return nil
	}
	
	fileprivate func viewController<T: CommandConfigurable>(type: T.Type, command: Commands) -> T {
		var viewController = type.controller(from: .main)
		viewController.command = command
		return viewController
	}
	
	fileprivate func simpleTextViewController(command: Commands) -> TextContentTypeViewController {
		return self.viewController(type: TextContentTypeViewController.self, command: command)
	}
	
    fileprivate func setConfigViewController(command: Commands) -> SetConfigViewController {
        let config = self.viewController(type: SetConfigViewController.self, command: command)
        return config
    }

    fileprivate func videoViewController(command: Commands, robot: Robot?) -> VideoViewController {
		let video = self.viewController(type: VideoViewController.self, command: command)
        video.robot = robot
        return video
	}
	
	fileprivate func lookAtViewController(command: Commands) -> LookAtActionViewController {
		return self.viewController(type: LookAtActionViewController.self, command: command)
	}
	
	fileprivate func sayViewController(command: Commands) -> SayViewController {
		return self.viewController(type: SayViewController.self, command: command)
	}

    fileprivate func photoViewController(command: Commands, robot: Robot?) -> PhotoViewController {
        let photo = self.viewController(type: PhotoViewController.self, command: command)
        photo.robot = robot
        return photo
    }

    fileprivate func displayViewController(command: Commands) -> DisplayViewController {
        let display = self.viewController(type: DisplayViewController.self, command: command)
        return display
    }

    fileprivate func motionViewController(command: Commands) -> MotionViewController {
        let motion = self.viewController(type: MotionViewController.self, command: command)
        return motion
    }

    fileprivate func listenViewController(command: Commands) -> ListenViewController {
        let listen = self.viewController(type: ListenViewController.self, command: command)
        return listen
    }

    fileprivate func headTouchViewController(command: Commands) -> HeadTouchViewController {
        let headTouch = self.viewController(type: HeadTouchViewController.self, command: command)
        return headTouch
    }
    
    fileprivate func fetchAssetViewController(command: Commands) -> FetchAssetViewController {
        let fetchAsset = self.viewController(type: FetchAssetViewController.self, command: command)
        return fetchAsset
    }
    
    fileprivate func screenGestureViewController(command: Commands) -> ScreenGestureViewController {
        let screenGesture = self.viewController(type: ScreenGestureViewController.self, command: command)
        return screenGesture
    }
    

}
