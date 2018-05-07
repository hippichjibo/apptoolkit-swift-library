//
//  ListenEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/** Information returned from listening */
public protocol ListenEntityProtocol {
    /// String of what Jibo heard
    var speech: String? { get set }
    /// Only US English supported
    var languageCode: String? { get set }
    /// ID of speaker, if available. Currently unsupported.
    var speaker: Speaker? { get set }
    /// Currently unsupported.
    var reason: String? { get set }
}
/// :nodoc:
class ListenEntity: ModelObject, ListenEntityProtocol {
    var speech: String?
    var languageCode: String?
    var speaker: Speaker?
    var reason: String?
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        speech    <- map["Speech"]
        languageCode    <- map["LanguageCode"]
        speaker    <- map["Speaker"]
        reason    <- map["Reason"]
    }
}

/// :nodoc:
class ListenEvent: BaseEvent {
    var listen: ListenEntity?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        listen <- map["Listen"]
    }
}

/// :nodoc:
enum ListenStopReason: String {
    case maxNoSpeech = "maxNoSpeech"
    case maxSpeech = "maxSpeech"
}

/// :nodoc:
class ListenStopEvent: BaseEvent {
    var stopReason: ListenStopReason?

    override func mapping(map: Map) {
        super.mapping(map: map)
        stopReason <- (map[ListenStopReasonID], EnumTransform<ListenStopReason>())
    }
    
    override var event: EventType {
        set {
            //no-op
        }
        get {
            return .listenStop
        }
    }
}

/// :nodoc:
class ListenResultEvent: BaseEvent {
    var languageCode: String?
    var speech: String = ""
    var nluResult: NLUResult?

    override func mapping(map: Map) {
        super.mapping(map: map)
        languageCode <- map["LanguageCode"]
        speech       <- map["Speech"]
    }
}

/// :nodoc:
class HotWordHeardEvent: BaseEvent {
    struct LPSPosition: Mappable {
        var position: Vector3?
        var angleVector: Vector2?
        var confidence: Double?

        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            position    <- map["Position"]
            angleVector <- map["AngleVector"]
            confidence  <- map["Confidence"]
        }
        
    }
    
    struct SpeakerId: Mappable {
        var type: EntityType?
        var confidence: Double?

        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            type        <- map["Type"]
            confidence  <- map["Confidence"]
        }
    }

    struct Speaker: Mappable {
        var lpsPosition: LPSPosition?
        var speakerID: SpeakerId?
        
        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            lpsPosition <- map["LPSPosition"]
            speakerID   <- map["SpeakerId"]
        }
    }
    var speaker: Speaker?

    override func mapping(map: Map) {
        super.mapping(map: map)

        speaker <- map["Speaker"]
    }
}
