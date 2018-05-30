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

/// :nodoc:
public protocol AssetsProtocol {
    func load(uri: String, name: String, completion: FetchAssetClosure?) -> TransactionID?
}

/// :nodoc:
public protocol AttentionProtocol {
}

/// :nodoc:
public protocol DisplayProtocol {
    func swap(view: CommandRequester.Display.ImageView, completion: DisplayClosure?) -> TransactionID?
    func swap(view: CommandRequester.Display.TextView, completion: DisplayClosure?) -> TransactionID?
    func swap(view: CommandRequester.Display.EyeView, completion: DisplayClosure?) -> TransactionID?
    
}

/// :nodoc:
public protocol ConfigProtocol {
    func get(completion: GetConfigClosure?) -> TransactionID?
    func set(_ options: SetConfigOptionsProtocol, completion: SetConfigClosure?) -> TransactionID?
}

/// :nodoc:
public protocol SubscribeProtocol {
    func gesture(_ params: ScreenGestureListenParams, completion: ScreenGestureClosure?) -> TransactionID?
    func face(completion: TrackedEntityClosure?) -> TransactionID?
    func motion(completion: MotionClosure?) -> TransactionID?
    func headTouch(completion: HeadTouchClosure?) -> TransactionID?
    
}
/// :nodoc:
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

/// :nodoc:
public protocol ListenProtocol {
    func start(maxSpeechTimeOut: Timeout, maxSpeechNoTimeout: Timeout, languageCode: LangCode, completion: ListenClosure?) -> TransactionID?

}

/// :nodoc:
public protocol ExpressionProtocol {
    func look(angle: CommandRequester.Expression.Angle, completion: LookAtClosure?) -> TransactionID?
    func look(entity: CommandRequester.Expression.Entity, completion: LookAtClosure?) -> TransactionID?
    func look(position: CommandRequester.Expression.Position, completion: LookAtClosure?) -> TransactionID?
    func look(screenCoords: CommandRequester.Expression.ScreenCoords, completion: LookAtClosure?) -> TransactionID?
    func say(phrase: String, completion: SayClosure?) -> TransactionID?
}

/// :nodoc:
public protocol CaptureProtocol {
    func video(videoType: VideoType, duration: TimeInterval, completion: TakeVideoClosure?) -> TransactionID?
    func photo(camera: Camera, resolution: CameraResolution, distortion: Bool, completion: TakePhotoClosure?) -> TransactionID?
}


/// :nodoc:
public protocol CommandRequesterInterface {
    typealias CompletionHandler = ((Bool, Error?) -> ())
    typealias ConnectionStateChangeHandler = ((Bool, Error?) -> ())
    var onConnectionStateChange: ConnectionStateChangeHandler? { get set }
    var isAuthenticated: Bool { get }
    func signIn(completion: @escaping CompletionHandler)
    func logOut(completion: @escaping CompletionHandler)
    func getRobots(completion: RobotListClosure?)
    @available(*, deprecated: 0.0.4, message: "Use invalidate(completion:)")
    func getIpAddress(robot: RobotInfoProtocol, completion: RobotClosure?)
    func connect(robot: Robot, completion: CompletionHandler?)
    func disconnect(completion: CompletionHandler?)
    func cancel(transactionId: TransactionID, completion: CompletionHandler?)
    static var useSimulator: Bool { get set }
}

// MARK: Main Library

/**
 Main library for the Jibo Protocol
 */
public class CommandRequester: CommandRequesterInterface {
    /// :nodoc:
	public var onConnectionStateChange: ConnectionStateChangeHandler? {
		didSet {
			self.connectionPolicyManager.onConnectionStateChange = self.onConnectionStateChange
		}
	}

    /// :nodoc:
	internal var requestProtocol: CommandRequestProtocol? {
		return self.connectionPolicyManager.requester
	}
    /// :nodoc:
	fileprivate var connectionManager: ConnectivityManager? {
		return self.connectionPolicyManager.connectionManager
	}
    /// :nodoc:
    fileprivate lazy var authManager: AuthManagerProtocol = AuthManager()
    /// :nodoc:
    fileprivate lazy var executor: RequestExecutor = requestExecutor
	/// :nodoc:
	fileprivate lazy var connectionPolicyManager: ConnectionPolicyManagerProtocol = {
		return ConnectionPolicyManager(authManager: self.authManager)
	}()
    /// :nodoc:
    fileprivate var videoFetcher: CommandVideoFetcher? = nil
    /// :nodoc:
    fileprivate var photoFetcher: CommandPhotoFetcher? = nil
    /// :nodoc:
    private lazy var simulatedRobotInfo: RobotInfoProtocol = {
        struct SimulatedRobotInfo: RobotInfoProtocol {
            var id: String? = "simulatedRobot"
            var name: String? = "simulatedRobotName"
            var robotName: String? = "ImmaLittleTeapot"
        }
        return SimulatedRobotInfo()
    }()
    /// :nodoc:
    private lazy var simulatedRobot: Robot = {
        let robot = Robot(ip: "127.0.0.1", port: 8160, info: self.simulatedRobotInfo)
        return robot
    }()

    /// :nodoc:
    public required init() { }
    
    //MARK: Command Namespaces

    /// :nodoc:
    public var assets: Assets? {
        return Assets(requester: self);
    }
    
    /**
     Protocol for working with external assets
     */
    public class Assets: AssetsProtocol {
        
        /// :nodoc:
        internal var requester: CommandRequester
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        /**
         Retrieve external asset and store in local cache by name.
         - Parameters:
         - uri: URI to the asset to be fetched.
         - name: Name the asset will be called by.
         - completion: (`FetchAssetInfo`?, `ErrorResponse`?)
         */
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
    
    
    /// :nodoc:
    public var attention: Attention? {
        return Attention(requester: self);
    }
    
    
    /**
     Protocol for modifying Jibo's attention mode
     */
    public class Attention: AttentionProtocol {
        
        /// :nodoc:
        internal var requester: CommandRequester
        
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        /** Set jibo's attention mode*/
        public func set(){
        }
    }
    
    /// :nodoc:
    public var display: Display? {
        return Display(requester: self);
    }
    
    /**
     Protocol for working with Jibo's screen
     */
    public class Display: DisplayProtocol {
        
        /**
         Create view for displaying images on Jibo's screen
         */
        public class ImageView {
            /// :nodoc:
            fileprivate let data: ImageData
            /// :nodoc:
            public let view: String
            /// :nodoc:
            public init(name: String, source: String, set: String, view: String){
                self.data = ImageData(name, source: source, set: set)
                self.view = view;
            }
            /**
             - Parameters:
             - imageData: Data for retrieving image.
             - view: Unique name of view
             */
            public init(imageData: ImageData, view: String){
                self.data = imageData
                self.view = view;
            }
            
            public func getImageData() -> ImageData { return data }
        }
        
        /**
         Create view for displaying text on Jibo's screen
         */
        public class TextView {
            /// :nodoc:
            public let text: String
            /// :nodoc:
            public let view: String
            /**
             - Parameters:
             - text: Text to display on Jibo's screen
             - view: Unique name of view
             */
            public required init(text: String, view: String){
                self.text = text
                self.view = view
            }
        }
        
        /**
         Create view for displaying Jibo's eye on screen
         */
        public class EyeView {
            /// :nodoc:
            public let view: String
            /**
             - Parameters:
             - view: Unique name of view
             */
            public required init(view: String){
                self.view = view
            }
        }
        /// :nodoc:
        internal var requester: CommandRequester
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        /// :nodoc:
        public var subscribe: Subscribe? {
            return Subscribe(requester: self.requester);
        }
        
        /** Protocol for subscribing to streams on Jibo */
        public class Subscribe : SubscribeProtocol{
            /// :nodoc:
            internal var requester: CommandRequester
            /// :nodoc:
            public required init(requester: CommandRequester){
                self.requester = requester
            }
            
            /** Listen for a tap or swipe on Jibo's screen
             - Parameters:
             - params: Options for type of gesture and location of gesture
             - completion: (`ScreenGestureInfo`?, `ErrorResponse`?)
             */
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
        
        /**
         Display an image on Jibo's screen
         - Parameters:
         - view: Image view information
         - completion: (`DisplayInfo`?, `ErrorResponse`?)
         */
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
        
        /**
         Display text on Jibo's screen
         - Parameters:
         - view: Text view information
         - completion: (`DisplayInfo`?, `ErrorResponse`?)
         */
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
        
        /**
         Display Jibo's eye on his screen
         - Parameters:
         - view: Eye view information
         - completion: (`DisplayInfo`?, `ErrorResponse`?)
         */
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

    /// :nodoc:
    public var config: Config? {
        return Config(requester: self);
    }
    
    /** Class for working with Jibo's settings and configurations */
    public class Config: ConfigProtocol {
        /// :nodoc:
        internal var requester: CommandRequester
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        /**
         Get Jibo's current settings and configuration info
         - Parameters:
         - completion: (`GetConfigInfo`?, `ErrorResponse`?)
         */
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
        /**
         Set available Jibo configurations
         - Parameters:
         - options: Settings availble to configure
         - completion: (`SetConfigInfo`?, `ErrorResponse`?)
         */
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
    
    /// :nodoc:
    public var perception: Perception? {
        return Perception(requester: self);
    }
    
    /** Class for working with Jibo's sensory input */
    public class Perception {
        /// :nodoc:
        internal var requester: CommandRequester
        /// :nodoc:

        public required init(requester: CommandRequester){
            self.requester = requester
        }
        /// :nodoc:
        public var subscribe: Subscribe? {
            return Subscribe(requester: self.requester);
        }
        
        /** Class for subscribing to Jibo's input streams */
        public class Subscribe : SubscribeProtocol{
            /// :nodoc:
            internal var requester: CommandRequester
            /// :nodoc:
            public required init(requester: CommandRequester){
                self.requester = requester
            }
            
            /** 
             Subscribe to face-detection events
             - Parameters:
             - completion : (`TrackedEntityInfo`?, `ErrorResponse`?)
             */
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
            
            /**
             Subscribe to motion-detection events
             - Parameters:
             - completion: (`MotionInfo`?, `ErrorResponse`?)
             */
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
            
            /**
             Listen for Jibo to receive a head touch
             - Parameters:
             - completion: (`HeadTouchInfo`?, `ErrorResponse`?)
             */
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

    /// :nodoc:
    public var listen: Listen? {
        return Listen(requester: self);
    }
    
    /** Class for Jibo's listening abilities */
    public class Listen: ListenProtocol {
        
        /// :nodoc:
        internal var requester: CommandRequester
        
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        /**
         Start listening
         - Parameters:
         - maxSpeechTimeout: Seconds to listen before timing out
         - maxNoSpeechTimeout: Seconds to wait for speech to start before timing out
         - languageCode: Language to listen for. Currently only US English is supported.
         - completion: (`ListenInfo`?, `ErrorResponse`?)
         */
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
    
    /// :nodoc:
    public var expression: Expression? {
        return Expression(requester: self);
    }
    
    /** Class for Jibo's verbal and physical expression */
    public class Expression: ExpressionProtocol {
        /**
         Data object for Angle information
         */
        public struct Angle {
            /** Currently unsupported */
            public var trackFlag: Bool = false
            /** `true` to keep Jibo's head level while he moves */
            public var levelHeadFlag: Bool = false
            /** Angle to look toward */
            public var angle: AngleVector
            public init(angle: AngleVector){
                self.angle = angle
            }
        }
        /**
         Data object for looking at a face
         */
        public struct Entity {
            /** Currently unsupported */
            public var trackFlag: Bool = false
            /** `true` to keep Jibo's head level while he moves */
            public var levelHeadFlag: Bool = false
            /** Entity to look at */
            public var entity: Int
            public init(entity: Int){
                self.entity = entity
            }
        }
        /**
         Data object for Position information
         */
        public struct Position {
            /** Currently unsupported */
            public var trackFlag: Bool = false
            /** `true` to keep Jibo's head level while he moves */
            public var levelHeadFlag: Bool = false
            /** Position to look toward */
            public var position: Vector3
            public init(position: Vector3){
                self.position = position
            }
        }
        /**
         Data object for Screen Coordinate information
         */
        public struct ScreenCoords {
            /** Currently unsupported */
            public var trackFlag: Bool = false
            /** `true` to keep Jibo's head level while he moves */
            public var levelHeadFlag: Bool = false
            /** 2D coordinates to look towards */
            public var coords: Vector2
            public init(coords: Vector2){
                self.coords = coords
            }
        }
        
        /// :nodoc:
        internal var requester: CommandRequester
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        
        /**
         Make Jibo look at a specific angel
         - Parameters:
         - angle: Angle to look toward
         - completion: (`LookAtAchievedInfo`?, `ErrorResponse`?)
         */
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
       
        /**
         Make Jibo look at an entity (face/motion)
         - Parameters:
         - entity: Entity to look toward
         - completion: (`LookAtAchievedInfo`?, `ErrorResponse`?)
         */
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
        
        /**
         Make Jibo turn at a 3D position
         - Parameters:
         - position: Position to look toward
         - completion: (`LookAtAchievedInfo`?, `ErrorResponse`?)
         */
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
        
        /**
         Make Jibo turn at a 2D position
         - Parameters:
         - screenCoords: Coords to look toward
         - completion: (`LookAtAchievedInfo`?, `ErrorResponse`?)
         */
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
        
        /**
         Make Jibo say something or use [ESML](https://app-toolkit.jibo.com/esml/) to display emojis or animations
         - Parameters:
         - say: Text or ESML to say.
         - completion: (`SayCompletedInfo`?, `ErrorResponse`?)
         */
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
    
    /// :nodoc:
    public var media: Media? {
        return Media(requester: self);
    }
    /** Class for working with media on Jibo */
    public class Media {
        /// :nodoc:
        internal var requester: CommandRequester
        /// :nodoc:
        public required init(requester: CommandRequester){
            self.requester = requester
        }
        /** Public instance of the Capture class */
        public var capture: Capture? {
            return Capture(requester: self.requester);
        }
        /** Class for capturing camera input from Jibo */
        public class Capture : CaptureProtocol{
            /// :nodoc:
            internal var requester: CommandRequester
            /// :nodoc:
            public required init(requester: CommandRequester){
                self.requester = requester
            }
            
            /**
             Get a stream of what Jibo sees.
             Please note that this option does NOT record a video. It provides a stream of live camera information.
             - Parameters:
             - video: `.normal` = only currently supported otion
             - duration: Unsupported. Use [cancel] to stop the stream
             - completion: (UIImage?, `ErrorResponse`?)
             */
            public func video(videoType: VideoType = .normal,
                                  duration: TimeInterval,
                                  completion: TakeVideoClosure?) -> TransactionID? {
                
                let closure: ((URIBasedInfo?, ErrorResponse?) -> ()) = {  (value, error) in
                     let sself = self
                     guard let robot = sself.requester.connectionPolicyManager.currentRobot, let video = value, let uri = video.uri else {
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
            
            /**
             Take a photo
             - Parameters:
             - camera: Which camera to use. Default = left
             - resolution: Resolution of photo to take. Default = low.
             - distortion: `true` for regular lense. `false` for fisheye.
             - completion: (`TakePhotoInfo`?, `ErrorResponse`?)
             */
            public func photo(camera: Camera,
                                  resolution: CameraResolution,
                                  distortion: Bool,
                                  completion: TakePhotoClosure?) -> TransactionID? {
                
                let closure: ((URIBasedInfo?, ErrorResponse?) -> ()) = {  (value, error) in
                     let sself = self
                     guard let robot = sself.requester.connectionPolicyManager.currentRobot, let photo = value, let uri = photo.uri else {
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
  
    // MARK: Connectivity
    
    /**
     `true` if the robot has been successfully authenticated.
     */
    public var isAuthenticated: Bool { return authManager.isAuthenticated }

    /**
     Authenticate with Jibo cloud. This function will prompt users to
     sign into their Jibo account with their email and password. Once they have
     authenticated their account, they will be able to connect their robot to your app.
     */
    public func signIn(completion: @escaping CompletionHandler) {
		self.connectionPolicyManager.authenticate(completion: completion)
    }
    
    /**
     Get the IP address of the robot you want to connect to. Can only be called for robots where `isAuthenticated = true`
     - Parameters:
     - robot: `your-friendly-robot-name.local` See underside of robot base for name.
     - completion: (`Robot`?, `ErrorResponse`?)
     */
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

    /**
     Remove authentication for the account. Users will have to authenticate again
     to connect to your app.
     */
    public func logOut(completion: @escaping CompletionHandler) {
        self.connectionPolicyManager.invalidate(completion: completion)
    }

    /**
     Connect to a robot. Can only be called for robots where `isAuthenticated = true`
     - Parameters:
     - robot: `your-friendly-robot-name.local` See underside of robot base for name.
     - completion: (Bool, Error?)
     */
    public func connect(robot: Robot, completion: CompletionHandler? = nil) {
        let robot = CommandRequester.useSimulator ? simulatedRobot : robot

        self.connectionPolicyManager.connect(robot: robot, completion: completion)
    }
    
    /**
     Disconnect from the currently connected robot.
     */
    public func disconnect(completion: CompletionHandler? = nil) {
        self.connectionPolicyManager.disconnect(completion: completion)
    }
    
    /**
     Cancel a transaction.
     - Parameters:
     - transactionId: ID of the transaction to cancel.
     - completion: (Bool, Error?)
     */
	public func cancel(transactionId: TransactionID, completion: CompletionHandler? = nil) {
		requestProtocol?.cancel(transactionId: transactionId).then { cancel -> () in
			completion?(cancel.cancelledTransactionId != nil, nil)
		}.catch { error in
			completion?(false, error)
		}
    }
    
    /**
     Get a list of all robots associated with the user's authenticated account.
     It is suggested that you prompt users to select which robot they would
     like to connect to use your app in the event that they own multiple robots.
     */
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

    public static var useSimulator: Bool {
        get {
            return _useSimulator
        }
        set {
            _useSimulator = newValue
        }
    }

}
/**
 :nodoc:
 */
private var _useSimulator: Bool = false
