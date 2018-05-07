//  Callbacks.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/20/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import ObjectMapper

/// :nodoc:
final class Callback<T> {
    private let callback: ((_ value: T?, _ error: ErrorResponse?) -> (Void))?
    
    func execute(value: Any?, error: ErrorResponse?) {
        if let value = value as? T {
            callback?(value, error)
        }
    }
    
    init(callback: ((_ value: T?, _ error: ErrorResponse?) -> ())? ) {
        self.callback = callback
    }
}
//MARK: Callback
/// General callback info
public class CallbackInfo {
    /// Error info for callback
    public var error: Error?
}

//MARK: Closure Info

/**
 When Jibo achieves his `lookAt`.
 */
public class LookAtAchievedInfo: CallbackInfo {
    /// 3D base coordinate frame of the robot. See `Vector3`.
    public var positionTarget: Vector3?
    /// 2D current orientation of the robot, See `AngleVector`
    public var angleTarget: AngleVector?
    // Emitted when Jibo has finished his `lookAt` command.
    public var type: EventType = .undefined
}

/**
 When we get configuration info
 */
public class GetConfigInfo: CallbackInfo, Mappable {
    /// :nodoc:
    public override init() {
    }
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        info <- (map["info"], BasicProtocolTypeSerializationTransform<ModelObject, ConfigInfoProtocol>())
    }
    
    /// Availble config info.
    public var info: ConfigInfoProtocol? = nil
}

/**
 When we set volume
 */
public class SetConfigInfo: CallbackInfo, Mappable {
    /// :nodoc:
    public override init() {
        super.init()
    }
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        succeed <- map["succeed"]
    }
    
    /// `true` if setting volume was successful
    public var succeed: Bool = false
}

/**
 When Jibo finishes speaking 
 */
public class SayCompletedInfo: CallbackInfo {
    /// Emitted when Jibo has finished his `say` command.
	public var type: EventType = .undefined
}

/** 
 When Jibo takes a photo
 */
public class TakePhotoInfo: CallbackInfo {
    /// The image that was taken.
    public var image: UIImage?
    /// Name of the image in local cache
    public var name: String?
    /// 3D base coordinate of where Jibo was when he took the photo
    public var positionTarget: Vector3?
    /// 2D orientation of Jibo when he took the photo
    public var angleTarget: AngleVector?
}

/**
 When display changes
 */
public class DisplayInfo: CallbackInfo {
    /// Jibo's current display state. See `DisplayViewState`
    public var state: DisplayViewState?
}

/** 
 When Jibo sees motion in his field of vision
 */
public class MotionInfo: CallbackInfo, Mappable {
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        motions <- (map["motions"], BasicProtocolTypeSerializationTransform<ModelObject, MotionEntityProtocol>())
    }
    /// :nodoc:
    override public init() {
    }
    
    /// Info for the motion that was seen. See `MotionEntityProtocol`
    public var motions: [MotionEntityProtocol]?
    
}

/**
 Jibo heard speech
 */
public class ListenInfo: CallbackInfo, Mappable {
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        listen <- (map["listen"], BasicProtocolTypeSerializationTransform<ModelObject, ListenEntityProtocol>())
    }
    /// :nodoc:
    override public init() {
    }
    
    /// Info for the listen. See `ListenEntityProtocol`
    public var listen: ListenEntityProtocol?
    
    /// Type of speach heard
    public enum ListenType {
        /// Regular speech
        case speech(speech: SpeechInfo)
        /// "Hey Jibo". Currently unsupported
        case hotWord(hotWord: HotWordInfo)
        /// "Stop"
        case stop(reason: String)
    }
    
    /// Type of speech heard
    public var listenType: ListenType?
}

/**
 Someone touched Jibo's head
 */
public class HeadTouchInfo: CallbackInfo, Mappable {
    /**
     There are 6 touch sensors on the back of Jibo's head. Three run
     down each side of his head. Left is Jibo's left and 
     right is Jibo's right. 
     See [HeadSensors](https://app-toolkit.jibo.com/images/JiboHeadSensors.png)
     for a diagram.
     */
    public struct HeadSensors: Mappable {
        //// :nodoc:
        public init?(map: Map) {
            self.init(leftFront: false,
            leftMiddle: false,
            leftBack: false,
            rightFront: false,
            rightMiddle: false,
            rightBack: false)
        }
        /// :nodoc:
        public mutating func mapping(map: Map) {
            
            leftFront <- map["leftFront"]
            leftMiddle <- map["leftMiddle"]
            leftBack <- map["leftBack"]
            rightFront <- map["rightFront"]
            rightMiddle <- map["rightMiddle"]
            rightBack <- map["rightBack"]
        }
        /// :nodoc:
        init(leftFront: Bool,
             leftMiddle: Bool,
             leftBack: Bool,
             rightFront: Bool,
             rightMiddle: Bool,
             rightBack: Bool) {
            
            self.leftFront = leftFront
            self.leftMiddle = leftMiddle
            self.leftBack = leftBack
            self.rightFront = rightFront
            self.rightMiddle = rightMiddle
            self.rightBack = rightBack
        }
        
        /// 0 `true` if left front sensor is touched
        public var leftFront: Bool
        /// 1 `true` is left middle sensor is touched
        public var leftMiddle: Bool
        /// 2 `true` if left back sensor is touched
        public var leftBack: Bool
        /// 3 `true` if right front sensor is touched
        public var rightFront: Bool
        /// 4 `true` if right middle sensor is touched
        public var rightMiddle: Bool
        /// 5 `true` if right back sensor is touched
        public var rightBack: Bool
    }
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        
        headSensors <- map["HeadSensors"]
    }
    /// :nodoc:
    override public init() {
        super.init()
    }
        
    /// Head touch sensor info
    public var headSensors: HeadSensors? = nil
    /// :nodoc
    public convenience init(_ sensors:[Bool]) {
        self.init()
        
        if sensors.count == 6 {
            headSensors = HeadSensors(leftFront: sensors[0], leftMiddle: sensors[1], leftBack: sensors[2], rightFront: sensors[3], rightMiddle: sensors[4], rightBack: sensors[5])
        }
    }
}

/**
 We got an asset
 */
public class FetchAssetInfo: CallbackInfo {
    /// Asset details
    public var detail: String?
}

/**
 Someone touched Jibo's scren
 */
public class ScreenGestureInfo: CallbackInfo, Mappable {
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        gesture <- (map["gesture"], BasicProtocolTypeSerializationTransform<ModelObject, ScreenGestureEntityProtocol>())
    }
    /// :nodoc:
    override public init() {
    }
    
    /// Info for the listen. See `ListenEntityProtocol`
    public var gesture: ScreenGestureEntityProtocol?
    
    /// Type of gesture
    public enum ScreenGestureType {
        /// Tap at a 2D coordinate on Jibo's screen.
        case tap(coordinate: Vector2)
        /// Swipe in a certain direction
        case swipe(direction: ScreenGestureSwipeDirection, velocity: Vector2)
    }
    /// Type of gesture
    public var gestureType: ScreenGestureType?
}

/**
 Jibo tracked an entity.
 */
public class TrackedEntityInfo: CallbackInfo, Mappable {
    /// :nodoc:
    public required init?(map: Map) {
    }
    /// :nodoc:
    public func mapping(map: Map) {
        
        type <- (map["type"], EnumTransform<EventType>())
        tracks <- (map["tracks"], BasicProtocolTypeSerializationTransform<ModelObject, TrackedEntityProtocol>())
    }
    
    /// event emitted on track
    public var type: EventType?
    /// track Jibo saw
    public var tracks: [TrackedEntityProtocol]?
    /// :nodoc:
    public init(type: EventType) {
        
        super.init()
        
        self.type = type
    }
    /// :nodoc:
    public init(type: EventType,
                tracks:[TrackedEntityProtocol]?) {
        
        super.init()
        
        self.type = type
        self.tracks = tracks
    }
}
//MARK: Perception
/**
 Location of something in Jibo's LPS system. Can be a face, motion, or other visual entity.
 */
public struct LPSPosition: Mappable {
    /// :nodoc:
    public init?(map: Map) {
    }
    /// :nodoc:
    public mutating func mapping(map: Map) {
        
        position <- (map["position"], Vector3Transformer())
        angleVector <- (map["angleVector"], Vector2Transformer())
        confidence <- map["confidence"]
    }
    /// :nodoc:
    public init(position: Vector3?, angleVector: Vector2?, confidence: Double?) {
        
        self.position = position
        self.angleVector = angleVector
        self.confidence = confidence
    }
    
    /// 3D base coordinate location of the entity.
    public var position: Vector3?
    /// 2D orientation of the entity.
    public var angleVector: Vector2?
    /// Jibo's confidence in his identification
    public var confidence: Double?
}

//MARK: Listening
/**
 What Jibo heard
 */
public struct SpeechInfo: Mappable {
    /// :nodoc:
    public init?(map: Map) {
    }
    /// :nodoc:
    public mutating func mapping(map: Map) {
        
        speech <- map["speech"]
        languageCode <- map["languageCode"]
    }
    /// :nodoc:
    public init(speech: String?, languageCode: String?) {

        self.speech = speech
        self.languageCode = languageCode
    }
    
    /// String of text Jibo parsed
    public var speech: String?
    /// Language of what Jibo heard. Currently only English is supported.
    public var languageCode: String?
}

/**
 Who was speaking
 */
public struct SpeakerId: Mappable {
    /// :nodoc:
    public init?(map: Map) {
    }
    /// :nodoc:
    public mutating func mapping(map: Map) {
        
        type <- (map["type"], EnumTransform<EntityType>())
        confidence <- map["confidence"]
    }
    /// :nodoc:
    public init(type: EntityType?, confidence: Double?) {
        
        self.type = type
        self.confidence = confidence
    }
    
    /// If the speaker is a loop member or not
    public var type: EntityType?
    /// Confidence in the ID of the person
    public var confidence: Double?
}

/**
 Info on the speaker of what Jibo heard
 */
public struct Speaker: Mappable {
    /// :nodoc:
    public init?(map: Map) {
    }
    /// :nodoc:
    public mutating func mapping(map: Map) {
        
        lpsPosition <- map["lpsPosition"]
        speakerID <- map["speakerID"]
    }
    /// :nodoc:
    public init(lpsPosition: LPSPosition?, speakerID: SpeakerId?) {
        
        self.lpsPosition = lpsPosition
        self.speakerID = speakerID
    }
    
    /// Where the speech came from
    public var lpsPosition: LPSPosition?
    /// Who the speech came from
    public var speakerID: SpeakerId?
}

/**
 Currently unsupported
 */
public struct HotWordInfo: Mappable {
    /// :nodoc:
    public init?(map: Map) {
    }
    /// :nodoc:
    public mutating func mapping(map: Map) {
        
        speaker <- map["speaker"]
    }
    ///  :nodoc:
    public init(speaker: Speaker) {
        
        self.speaker = speaker
    }
    /// :nodoc:
    public var speaker: Speaker?
}
//MARK: Extensions

/// I can't get these to doc.

/** This is an extension */
extension AssetsProtocol {
    /* This is a closure */
    public typealias FetchAssetClosure = ((FetchAssetInfo?, ErrorResponse?) -> ())
}

/// Display closures
extension DisplayProtocol {
    /** Display closure
     */
    public typealias DisplayClosure = ((DisplayInfo?, ErrorResponse?) -> ())
}

/**
 Config closures
 */
extension ConfigProtocol {
    /**
     Get Config closure
     */
    public typealias GetConfigClosure = ((GetConfigInfo?, ErrorResponse?) -> ())
    
    /** Set Config closure */
    public typealias SetConfigClosure = ((SetConfigInfo?, ErrorResponse?) -> ())
}

/// Subscribe closures
extension SubscribeProtocol {
    /** ScreenGesture closure */
    public typealias ScreenGestureClosure = ((ScreenGestureInfo?, ErrorResponse?) -> ())
    /** Motion closure */
    public typealias MotionClosure = ((MotionInfo?, ErrorResponse?) -> ())
    /** HeadTouch closure */
    public typealias HeadTouchClosure = ((HeadTouchInfo?, ErrorResponse?) -> ())
    /** TrackEntity closure */
    public typealias TrackedEntityClosure = ((TrackedEntityInfo?, ErrorResponse?) -> ())
}

/// Listen closures
extension ListenProtocol {
    /** Listen closure */
    public typealias ListenClosure = ((ListenInfo?, ErrorResponse?) -> ())
}

/// Expression closures
extension ExpressionProtocol {
    /** Look At closure */
    public typealias LookAtClosure = ((LookAtAchievedInfo?, ErrorResponse?) -> ())
    /** Say closure */
    public typealias SayClosure = ((SayCompletedInfo?, ErrorResponse?) -> ())
}

/// Capture closures
extension CaptureProtocol {
    /** Take Video closure */
    public typealias TakeVideoClosure = ((UIImage?, ErrorResponse?) -> ())
    /** Take Photo closure */
    public typealias TakePhotoClosure = ((TakePhotoInfo?, ErrorResponse?) -> ())
}

/**
 Closures for working with the robot
 */
extension CommandRequesterInterface {
    /**
     Generic closure
     */
    public typealias CallbackClosure = ((Any?, ErrorResponse?) -> ())
    
    /** Robot closure
     */
    public typealias RobotClosure = ((Robot?, ErrorResponse?) -> ())
    
    /** Robot List closure
     */
    public typealias RobotListClosure = (([RobotInfoProtocol]?, ErrorResponse?) -> ())
}
