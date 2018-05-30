//
//  EventType.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

//MARK: Events
/// Enum of events
public enum EventType: String {
    case undefined  = ""

    // MARK: - Async events
    /// async event
    case asyncStart         = "onStart"
    /// async event
    case asyncStop          = "onStop"
    /// async event
    case asyncError         = "onError"

    // MARK: - Expression events
    /// Jibo looked at the spot he was told to look at
    case lookAtAchieved     = "onLookAtAchieved"
    /// Jibo lost the face he was trying to look at
    case trackEntityLost    = "onTrackEntityLost"

    // MARK: - Media events
    /// URL to video is ready to stream
    case videoReady         = "onVideoReady"
    /// Emitted when a photo is taken
    case takePhoto          = "onTakePhoto"
    
    // MARK: - Display events
    /// View state has changed
    case viewStateChange    = "onViewStateChange"
    /// Jibo's screen was tapped
    case onScreenTap        = "onTap"
    /// Jibo's screen was swiped
    case onScreenSwipe      = "onSwipe"
    
    // MARK: - Perception events
    /// Face detection was updated
    case trackUpdate        = "onEntityUpdate"
    /// Face was lost
    case trackLost          = "onEntityLost"
    /// New face found
    case trackGained        = "onEntityGained"
    /// Jibo detected movement.
    case motionDetected     = "onMotionDetected"
    /// Jibo received a head touch.
    case headTouched        = "onHeadTouch"
    
    // MARK: - Listen events
    /// Jibo heard "Hey Jibo." 
    case onHotWordHeard     = "onHotWordHeard"
    /// Jibo got a result back from listening
    case listenResult       = "onListenResult"
    /// Jibo stopped listening
    case listenStop         = "onListenStop"

    // MARK: - Asset events
    /// The asset is ready to display
    case assetReady         = "onAssetReady"
    /// The asset could not be fetched
    case assetFailed        = "onAssetFailed"

    // MARK: - Config events
    /// A configuration option changed.
    case onConfig           = "onConfig"

}
