//
//  CommandRequester.swift
//  AppToolkit
//
//  Created by Calvin Park on 9/28/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Robot Info
/**
 Information for the robot we're connecting to.
 - Parameters:
    - info: See `RobotInfoProtocol`.
    - ip: Robot's IP address.
    - port: Robot's port number.
 */
public struct Robot {
    let info: RobotInfoProtocol
    let ip: String
    let port: Int

    /// :nodoc:
    public init(ip: String, port: Int, info: RobotInfoProtocol) {
        self.ip = ip
        self.port = port
        self.info = info
    }
    /// :nodoc:
    public func getIp() -> String? {
        return ip
    }
    /// :nodoc:
    public func getPort() -> Int {
        return port
    }
    /// :nodoc:
    public func getName() -> String? {
        return info.name  
    }
    /// :nodoc:
    public func getRobotName() -> String? {
        return info.robotName
    }
}

//Assets protocol
/**
 Assets protocol
 */
public protocol AssetsProtocol {
    
    /**
     Retrieve external asset and store in local cache by name.
     - Parameters:
     - uri: URI to the asset to be fetched.
     - name: Name the asset will be called by.
     - completion: `FetchAssetClosure`
     */
    func load(uri: String, name: String, completion: FetchAssetClosure?) -> TransactionID?
}

//Attention protocol
/**
 Attention protocol
 */
public protocol AttentionProtocol {
    // Not implemented yet
}

//Display protocol
/**
 Display protocol
 */
public protocol DisplayProtocol {
    /**
     Display Jibo's Image on screen.
     - Parameters:
     - view: Unique name of view.
     - completion: `DisplayClosure`
     */
    func swap(view: CommandRequester.Display.ImageView, completion: DisplayClosure?) -> TransactionID?
    
    /**
     Display text on screen.
     - Parameters:
     - text: text to display.
     - view: Unique name of view.
     - completion: `DisplayClosure`
     */
    func swap(view: CommandRequester.Display.TextView, completion: DisplayClosure?) -> TransactionID?
    
    /**
     Display Jibo's eye on screen.
     - Parameters:
     - view: Unique name of view.
     - completion: `DisplayClosure`
     */
    func swap(view: CommandRequester.Display.EyeView, completion: DisplayClosure?) -> TransactionID?
    
}

//Config protocol
/**
 Config protocol
 */
public protocol ConfigProtocol {
    // MARK: Commands
    /**
     Get robot configuration data.
     */
    func get(completion: GetConfigClosure?) -> TransactionID?
    
    /**
     Set robot configuration data.
     - Parameters:
     - options: `SetConfigOptionsProtocol`
     - completion: `SetConfigClosure`
     */
    func set(_ options: SetConfigOptionsProtocol, completion: SetConfigClosure?) -> TransactionID?
}

//Subscribe protocol
/**
 Subscribe protocol
 */
public protocol SubscribeProtocol {
    /**
     Listen for screen gesture.
     - Parameters:
     - params: `ScreenGestureListenParams`
     - completion: `ScreenGestureClosure`
     */
    func gesture(_ params: ScreenGestureListenParams, completion: ScreenGestureClosure?) -> TransactionID?
    /**
     Get a face to track. Currently unsupported.
     */
    func face(completion: TrackedEntityClosure?) -> TransactionID?
    
    /**
     Track motion in Jibo's perceptual space.
     */
    func motion(completion: MotionClosure?) -> TransactionID?
    /**
     Listen for head touch.
     */
    func headTouch(completion: HeadTouchClosure?) -> TransactionID?
    
}

// For optional protocol methods
extension SubscribeProtocol {
    public func gesture(_ params: ScreenGestureListenParams, completion: ScreenGestureClosure?) -> TransactionID? {
        return ""
    }
    
    public func face(completion: TrackedEntityClosure?) -> TransactionID?{
        return ""
    }
    
    public func motion(completion: MotionClosure?) -> TransactionID?{
        return ""
    }
    
    public func headTouch(completion: HeadTouchClosure?) -> TransactionID?{
        return ""
    }
}

//Listen protocol
/**
 Listen protocol
 */
public protocol ListenProtocol {
    /**
     Listen for speech input.
     - Parameters:
     - maxSpeechTimeOut: [default = 15] In seconds
     - maxNoSpeechTimeout: [default = 15] In seconds
     - languageCode: [default = `en_US`] Language code. Only English is supported.
     - completion: `ListenClosure`
     */
    func start(maxSpeechTimeOut: Timeout, maxSpeechNoTimeout: Timeout, languageCode: LangCode, completion: ListenClosure?) -> TransactionID?

}

//Expression protocol
/**
 Expression protocol
 */
public protocol ExpressionProtocol {
    /**
     Make Jibo look toward a specific angle
     - Parameters:
     - targetType: Where to make Jibo look. See `LookAtTargetType`
     - trackFlag: Unsupported. Use `false`.
     - levelHeadFlag: `true` to keep Jibo's head level while he moves.
     - completion: `LookAtClosure`
     */
    func look(angle: CommandRequester.Expression.Angle, completion: LookAtClosure?) -> TransactionID?
    /**
     Make Jibo look toward a specific entity
     - Parameters:
     - targetType: Where to make Jibo look. See `LookAtTargetType`
     - trackFlag: Unsupported. Use `false`.
     - levelHeadFlag: `true` to keep Jibo's head level while he moves.
     - completion: `LookAtClosure`
     */
    func look(entity: CommandRequester.Expression.Entity, completion: LookAtClosure?) -> TransactionID?
    /**
     Make Jibo look toward a specific position
     - Parameters:
     - targetType: Where to make Jibo look. See `LookAtTargetType`
     - trackFlag: Unsupported. Use `false`.
     - levelHeadFlag: `true` to keep Jibo's head level while he moves.
     - completion: `LookAtClosure`
     */
    func look(position: CommandRequester.Expression.Position, completion: LookAtClosure?) -> TransactionID?
    /**
     Make Jibo look toward a specific screen coordinate
     - Parameters:
     - targetType: Where to make Jibo look. See `LookAtTargetType`
     - trackFlag: Unsupported. Use `false`.
     - levelHeadFlag: `true` to keep Jibo's head level while he moves.
     - completion: `LookAtClosure`
     */
    func look(screenCoords: CommandRequester.Expression.ScreenCoords, completion: LookAtClosure?) -> TransactionID?
    
    /**
     Make Jibo speak.
     - Parameters:
     - phrase: What Jibo should say. Can take plain text or [ESML](https://app-toolkit.jibo.com/esml.html#esml).
     - completion: `SayClosure`
     */
    func say(phrase: String, completion: SayClosure?) -> TransactionID?
}

//Capture protocol
/**
 Capture protocol
 */
public protocol CaptureProtocol {
    /**
     Get a stream of what Jibo's cameras see.
     - Parameters:
     - videoType: Use `normal`. `debug` not currently supported.
     - duration: Unsupported. Call `cancel()` to stop the stream.
     - completion: `TakeVideoClosure`
     */
    func video(videoType: VideoType, duration: TimeInterval, completion: TakeVideoClosure?) -> TransactionID?
    
    /**
     Take a photo.
     - Parameters:
     - camera: `left` or `right` camera to take photo with. Only `left` is supported at this time.
     - resolution: Choose a `CameraResolution`. Default = `low`.
     - distortion: `true` for regular lense. `false` for fisheye lense.
     - completion: `TakePhotoClosure`
     */
    func photo(camera: Camera, resolution: CameraResolution, distortion: Bool, completion: TakePhotoClosure?) -> TransactionID?
}

//MARK: Main Library
/**
 Main library for the Jibo Protocol
 */
public protocol CommandRequesterInterface {
    // MARK: - Handler
    /// Completion handler
    typealias CompletionHandler = ((Bool, Error?) -> ())
    /// :nodoc:
    typealias ConnectionStateChangeHandler = ((Bool, Error?) -> ())

    // MARK: - Connectivity
    /// :nodoc:
    var onConnectionStateChange: ConnectionStateChangeHandler? { get set }

    /**
     `true` if the robot has been successfully authenticated. 
     */
    var isAuthenticated: Bool { get }

    /**
     Authenticate with Jibo cloud. This function will prompt users to 
     sign into their Jibo account with their email and password. Once they have 
     authenticated their account, they will be able to connect their robot to your app.
     */
    func signIn(completion: @escaping CompletionHandler)

    /**
     Remove authentication for the account. Users will have to authenticate again
     to connect to your app.
     */
    func logOut(completion: @escaping CompletionHandler)
    
    /**
     Get a list of all robots associated with the user's authenticated account. 
     It is suggested that you prompt users to select which robot they would 
     like to connect to use your app in the event that they own multiple robots.
     */
    func getRobots(completion: RobotListClosure?)
    @available(*, deprecated: 0.0.4, message: "Use invalidate(completion:)")
    
    /**
     Get the IP address of the robot you want to connect to.
     - Parameters:
        - robot: The robot to get the IP address for
        - completion: `RobotClosure`
     */
    func getIpAddress(robot: RobotInfoProtocol, completion: RobotClosure?)

    /** 
     Connect to a robot. Can only be called for robots where `isAuthenticated = true`
     - Parameters:
        - robot: `your-friendly-robot-name.local` See underside of robot base for name.
        - completion: `CompletionHandler`
     */
    func connect(robot: Robot, completion: CompletionHandler?)

    /**
     Disconnect from the currently connected robot.
     */
    func disconnect(completion: CompletionHandler?)

    /**
     Cancel a transaction.
     - Parameters:
         - transactionId: ID of the transaction to cancel.
         - completion: `CompletionHandler`
     */
    func cancel(transactionId: TransactionID, completion: CompletionHandler?)

    /**
     Turn on Jibo Simulator flow. Default value is `false`.

     Use `CommandRequester.useSimulator = false` in `viewDidLoad()`
     */
    static var useSimulator: Bool { get set }
}

/**
 :nodoc:
 */
public class CommandRequester: CommandRequesterInterface {
    // MARK: - Connection state
	public var onConnectionStateChange: ConnectionStateChangeHandler? {
		didSet {
			self.connectionPolicyManager.onConnectionStateChange = self.onConnectionStateChange
		}
	}

    // MARK: - Private Variables
	internal var requestProtocol: CommandRequestProtocol? {
		return self.connectionPolicyManager.requester
	}
    
	fileprivate var connectionManager: ConnectivityManager? {
		return self.connectionPolicyManager.connectionManager
	}
    fileprivate lazy var authManager: AuthManagerProtocol = AuthManager()
    fileprivate lazy var executor: RequestExecutor = requestExecutor
	
	fileprivate lazy var connectionPolicyManager: ConnectionPolicyManagerProtocol = {
		return ConnectionPolicyManager(authManager: self.authManager)
	}()
    fileprivate var videoFetcher: CommandVideoFetcher? = nil
    fileprivate var photoFetcher: CommandPhotoFetcher? = nil
    
    private lazy var simulatedRobotInfo: RobotInfoProtocol = {
        struct SimulatedRobotInfo: RobotInfoProtocol {
            var id: String? = "simulatedRobot"
            var name: String? = "simulatedRobotName"
            var robotName: String? = "ImmaLittleTeapot"
        }
        return SimulatedRobotInfo()
    }()
    
    private lazy var simulatedRobot: Robot = {
        let robot = Robot(ip: "127.0.0.1", port: 8160, info: self.simulatedRobotInfo)
        return robot
    }()

    // MARK: Public interface

    public required init() { }
    
    ///// Assets ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var assets: Assets? {
        return Assets(requester: self);
    }
    
    public class Assets: AssetsProtocol {

        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public func load(uri: String, name: String, completion: FetchAssetClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.fetchAssetWithURI(uri, name: name, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Attention /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var attention: Attention? {
        return Attention(requester: self);
    }
    
    public class Attention: AttentionProtocol {
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        /**
         Retrieve external asset and store in local cache by name.
         - Parameters:
         - uri: URI to the asset to be fetched.
         - name: Name the asset will be called by.
         - completion: `FetchAssetClosure`
         */
        public func set(){
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Display ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var display: Display? {
        return Display(requester: self);
    }
    
    public class Display: DisplayProtocol {
        
        /**
         ImageView class for display
         - Parameters:
         - name: Name for the asset
         - source: source URL
         - set: set name
         */
        public class ImageView {
            fileprivate let data: ImageData
            public let view: String
            public init(name: String, source: String, set: String, view: String){
                self.data = ImageData(name, source: source, set: set)
                self.view = view;
            }
            
            public init(imageData: ImageData, view: String){
                self.data = imageData
                self.view = view;
            }
            
            public func getImageData() -> ImageData { return data }
        }
        
        /**
         TextView class for display
         - Parameters:
         - text: text for textview
         */
        public class TextView {
            public let text: String
            public let view: String
            public required init(text: String, view: String){
                self.text = text
                self.view = view
            }
        }
        
        /**
         EyeView class for display
         - Parameters:
         - text: text for eyeview
         */
        public class EyeView {
            public let view: String
            public required init(view: String){
                self.view = view
            }
        }
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public var subscribe: Subscribe? {
            return Subscribe(requester: self.requester);
        }
        
        public class Subscribe : SubscribeProtocol{
            // MARK: - Private Variables
            internal var requester: CommandRequester
            
            public required init(requester: CommandRequester){
                self.requester = requester
            }
            
            public func gesture(_ params: ScreenGestureListenParams, completion: ScreenGestureClosure?) -> TransactionID? {
                let genericCallback = Callback(callback: completion)
                let command = requester.requestProtocol?.listenForScreenGesture(params, callback: genericCallback.execute)
                
                command?.tokenAcknowledged.then { result in
                    return // no need to handle here, callback is handled separately
                    }.catch { error in
                        completion?(nil, ErrorResponse(error))
                }
                return command?.transactionId
            }
            
        }
        
        public func swap(view: CommandRequester.Display.ImageView, completion: DisplayClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.displayImage(view.getImageData(), in: view.view, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
        public func swap(view: CommandRequester.Display.TextView, completion: DisplayClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.displayText(view.text, in: view.view, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
        public func swap(view: CommandRequester.Display.EyeView, completion: DisplayClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.displayEye(in: view.view, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Config ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var config: Config? {
        return Config(requester: self);
    }
    
    public class Config: ConfigProtocol {
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public func get(completion: GetConfigClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.getConfig(genericCallback.execute)
            
            command?.tokenAcknowledged.then { _ in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
        public func set(_ options: SetConfigOptionsProtocol, completion: SetConfigClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.setConfig(options, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { _ in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Perception ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var perception: Perception? {
        return Perception(requester: self);
    }
    
    public class Perception {
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public var subscribe: Subscribe? {
            return Subscribe(requester: self.requester);
        }
        
        public class Subscribe : SubscribeProtocol{
            // MARK: - Private Variables
            internal var requester: CommandRequester
            
            public required init(requester: CommandRequester){
                self.requester = requester
            }
            
            public func face(completion: TrackedEntityClosure?) -> TransactionID? {
                let genericCallback = Callback(callback: completion)
                let command = self.requester.requestProtocol?.entityRequest(callback: genericCallback.execute)
                command?.tokenAcknowledged.then { result in
                    return // no need to handle here, callback is handled separately
                    }.catch { error in
                        completion?(nil, ErrorResponse(error))
                }
                return command?.transactionId
            }
            
            public func motion(completion: MotionClosure?) -> TransactionID? {
                let genericCallback = Callback(callback: completion)
                let command = self.requester.requestProtocol?.getMotion(callback: genericCallback.execute)
                
                command?.tokenAcknowledged.then { result in
                    return // no need to handle here, callback is handled separately
                    }.catch { error in
                        completion?(nil, ErrorResponse(error))
                }
                return command?.transactionId
            }
            
            public func headTouch(completion: HeadTouchClosure?) -> TransactionID? {
                let genericCallback = Callback(callback: completion)
                let command = self.requester.requestProtocol?.listenForHeadTouch(callback: genericCallback.execute)
                
                command?.tokenAcknowledged.then { result in
                    return // no need to handle here, callback is handled separately
                    }.catch { error in
                        completion?(nil, ErrorResponse(error))
                }
                return command?.transactionId
            }
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Listen ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var listen: Listen? {
        return Listen(requester: self);
    }
    
    public class Listen: ListenProtocol {
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public func start(maxSpeechTimeOut: Timeout = 15, maxSpeechNoTimeout: Timeout = 15, languageCode: LangCode = .enUS, completion: ListenClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.listenForSpeech(maxSpeechTimeOut: maxSpeechTimeOut, maxNoSpeechTimeout: maxSpeechNoTimeout, languageCode: languageCode, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                return // no need to handle here, callback is handled separately
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Expression ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var expression: Expression? {
        return Expression(requester: self);
    }
    
    public class Expression: ExpressionProtocol {
        /**
         Data object for Angle information
         */
        public struct Angle {
            public var trackFlag: Bool = false
            public var levelHeadFlag: Bool = false
            public var angle: AngleVector
            public init(angle: AngleVector){
                self.angle = angle
            }
        }
        /**
         Data object for Entity information
         */
        public struct Entity {
            public var trackFlag: Bool = false
            public var levelHeadFlag: Bool = false
            public var entity: Int
            public init(entity: Int){
                self.entity = entity
            }
        }
        /**
         Data object for Position information
         */
        public struct Position {
            public var trackFlag: Bool = false
            public var levelHeadFlag: Bool = false
            public var position: Vector3
            public init(position: Vector3){
                self.position = position
            }
        }
        /**
         Data object for Screen Coordinate information
         */
        public struct ScreenCoords {
            public var trackFlag: Bool = false
            public var levelHeadFlag: Bool = false
            public var coords: Vector2
            public init(coords: Vector2){
                self.coords = coords
            }
        }
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public func look(angle: CommandRequester.Expression.Angle, completion: LookAtClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.lookAt(targetType: LookAtTargetType.angle(angle: angle.angle), trackFlag: angle.trackFlag, levelHeadFlag: angle.levelHeadFlag, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                completion?(nil, nil)
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
       
        public func look(entity: CommandRequester.Expression.Entity, completion: LookAtClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.lookAt(targetType: LookAtTargetType.entity(entity: entity.entity), trackFlag: entity.trackFlag, levelHeadFlag: entity.levelHeadFlag, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                completion?(nil, nil)
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
        public func look(position: CommandRequester.Expression.Position, completion: LookAtClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.lookAt(targetType: LookAtTargetType.position(position: position.position), trackFlag: position.trackFlag, levelHeadFlag: position.levelHeadFlag, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                completion?(nil, nil)
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
        public func look(screenCoords: CommandRequester.Expression.ScreenCoords, completion: LookAtClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.lookAt(targetType: LookAtTargetType.screenCoords(screenCoords: screenCoords.coords), trackFlag: screenCoords.trackFlag, levelHeadFlag: screenCoords.levelHeadFlag, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { result in
                completion?(nil, nil)
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
        
        public func say(phrase: String, completion: SayClosure?) -> TransactionID? {
            let genericCallback = Callback(callback: completion)
            let command = self.requester.requestProtocol?.say(phrase: phrase, callback: genericCallback.execute)
            
            command?.tokenAcknowledged.then { _ in
                completion?(nil, nil)
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
            return command?.transactionId
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///// Media ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var media: Media? {
        return Media(requester: self);
    }
    
    public class Media {
        
        internal var requester: CommandRequester
        
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        public var capture: Capture? {
            return Capture(requester: self.requester);
        }
        
        public class Capture : CaptureProtocol{
            // MARK: - Private Variables
            internal var requester: CommandRequester
            
            public required init(requester: CommandRequester){
                self.requester = requester
            }
            
            public func video(videoType: VideoType = .normal,
                                  duration: TimeInterval,
                                  completion: TakeVideoClosure?) -> TransactionID? {
                
                let closure: ((URIBasedInfo?, ErrorResponse?) -> ()) = { [weak self] (value, error) in
                    guard let sself = self, let robot = sself.requester.connectionPolicyManager.currentRobot, let video = value, let uri = video.uri else {
                        completion?(nil, error)
                        return
                    }
                    // Use separate instance (with additional security handling) to get media
                    sself.requester.authManager.certificate(for: robot).then { (certificate) -> () in
                        let schema = CommandRequester.useSimulator ? "http://" : "https://"
                        let urlString = "\(schema)\(robot.getIp()!):\(robot.getPort())" + uri
                        let fetcher = CommandVideoFetcher(URL(string: urlString)!, certificate: certificate)
                        fetcher.didFetchImage = { (image) in
                            completion?(image, nil)
                        }
                        
                        sself.requester.videoFetcher = fetcher
                        fetcher.start()
                        }.catch { error in
                            completion?(nil, ErrorResponse(error))
                    }
                }
                
                let genericCallback = Callback(callback: closure)
                let command = self.requester.requestProtocol?.takeVideo(videoType: videoType, duration: duration, callback: genericCallback.execute, finalizer: { [weak self] in
                    guard let sself = self else { return }
                    // cleanup fetcher on exit
                    sself.requester.videoFetcher = nil
                })
                
                command?.tokenAcknowledged.then { _ in
                    return // no need to handle here, callback is handled separately
                    }.catch { error in
                        completion?(nil, ErrorResponse(error))
                }
                return command?.transactionId
            }
            
            public func photo(camera: Camera,
                                  resolution: CameraResolution,
                                  distortion: Bool,
                                  completion: TakePhotoClosure?) -> TransactionID? {
                
                let closure: ((URIBasedInfo?, ErrorResponse?) -> ()) = { [weak self] (value, error) in
                    guard let sself = self, let robot = sself.requester.connectionPolicyManager.currentRobot, let photo = value, let uri = photo.uri else {
                        completion?(nil, error)
                        return
                    }
                    // Use separate instance (with additional security handling) to get media
                    sself.requester.authManager.certificate(for: robot).then { (certificate) -> () in
                        let schema = CommandRequester.useSimulator ? "http://" : "https://"
                        let urlString = "\(schema)\(robot.getIp()!):\(robot.getPort())" + uri
                        let fetcher = CommandPhotoFetcher(URL(string: urlString)!, certificate: certificate)
                        fetcher.didFetchImage = { (image) in
                            if let info = value as? TakePhotoInfoInternal {
                                let photoInfo = TakePhotoInfo(internal: info)
                                photoInfo.image = image
                                completion?(photoInfo, nil)
                            }
                        }
                        
                        sself.requester.photoFetcher = fetcher
                        fetcher.start()
                        }.catch { error in
                            completion?(nil, ErrorResponse(error))
                    }
                }
                
                let genericCallback = Callback(callback: closure)
                let command = self.requester.requestProtocol?.takePhoto(with: camera, resolution: resolution, distortion: distortion, callback: genericCallback.execute, finalizer: { [weak self] in
                    guard let sself = self else { return }
                    // cleanup fetcher on exit
                    sself.requester.photoFetcher = nil
                })
                
                command?.tokenAcknowledged.then { result in
                    return // no need to handle here, callback is handled separately
                    }.catch { error in
                        completion?(nil, ErrorResponse(error))
                }
                return command?.transactionId
            }
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public var isAuthenticated: Bool { return authManager.isAuthenticated }

    public func signIn(completion: @escaping CompletionHandler) {
		self.connectionPolicyManager.authenticate(completion: completion)
    }
    
    public func getIpAddress(robot: RobotInfoProtocol, completion: RobotClosure?) {
        guard !CommandRequester.useSimulator else {
            // use predefined robot for simulator flow
            completion?(simulatedRobot, nil)
            return
        }

        authManager.getIpAddress(robot: robot)
            .then { robot -> () in
                completion?(robot, nil)
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
    }

    public func logOut(completion: @escaping CompletionHandler) {
        self.connectionPolicyManager.invalidate(completion: completion)
    }

    public func connect(robot: Robot, completion: CompletionHandler? = nil) {
        let robot = CommandRequester.useSimulator ? simulatedRobot : robot

        self.connectionPolicyManager.connect(robot: robot, completion: completion)
    }
    
    public func disconnect(completion: CompletionHandler? = nil) {
        self.connectionPolicyManager.disconnect(completion: completion)
    }
    
	public func cancel(transactionId: TransactionID, completion: CompletionHandler? = nil) {
		requestProtocol?.cancel(transactionId: transactionId).then { cancel -> () in
			completion?(cancel.cancelledTransactionId != nil, nil)
		}.catch { error in
			completion?(false, error)
		}
    }
    
    public func getRobots(completion: RobotListClosure? = nil) {
        guard !CommandRequester.useSimulator else {
            // use predefined robot for simulator flow
            completion?([simulatedRobotInfo], nil)
            return
        }
		let robotsService = RobotsService(executor: requestExecutor)
		robotsService.obtainRobotsList(authorizer: authManager.authorizer(), completion: completion)
    }
}

/**
 :nodoc:
 */
extension CommandRequester {
    public static var environment: Environment {
        get {
            return EnvironmentSwitcher.shared().currentEnvironment
        }
        set {
            EnvironmentSwitcher.shared().currentEnvironment = newValue
        }
    }
}

/**
 :nodoc:
 */
extension CommandRequester {
    public func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        // redirect OAuth callback
        return authManager.application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

/**
 :nodoc:
 */
extension CommandRequester {
    /**
     for using simulator to test
     */
    public static var useSimulator: Bool {
        get {
            return _useSimulator
        }
        set {
            _useSimulator = newValue
        }
    }

}

private var _useSimulator: Bool = false
