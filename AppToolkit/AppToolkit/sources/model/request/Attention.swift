//
//  Attention.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

//MARK: Attention

/** Enum of attention modes */
public enum AttentionMode: String {
    case off = "OFF"
    case idle = "IDLE"
    case disengage = "DISENGAGE"
    case engaged = "ENGAGED"
    case speaking = "SPEAKING"
    case fixated = "FIXATED"
    case attractable = "ATTRACTABLE"
    case menu = "MENU"
    case command = "COMMAND"
}
