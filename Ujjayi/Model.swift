//
//  Model.swift
//  test-211211-ujjayi
//
//  Created by Aleksandr Borisov on 11.12.2021.
//

import Foundation

struct Pranayama: Codable {
    var inhale: Int
    var innerHold: Int
    var exhale: Int
    var outerHold: Int
    var cycles: Int
}

struct Preset: Codable {
    var name: String
    var pranayama: Pranayama
}

enum Phase: CaseIterable {
    case inhale
    case innerHold
    case exhale
    case outerHold
    case paused
    
    var title: String {
        switch self {
        case .inhale:
            return Const.inhale
        case .exhale:
            return Const.exhale
        case .innerHold, .outerHold:
            return Const.hold
        case .paused:
            return Const.paused
        }
    }
    
//    var minValue: Int {
//        switch self {
//        case .innerHold, .outerHold:
//            return 0
//        default:
//            return 1
//        }
//    }
    
    var scaleAnimationValue: Double {
        switch self {
        case .inhale, .innerHold:
            return 1
        case .exhale, .outerHold:
            return 0.751
        default:
            return 0.75
        }
    }
    
    var hueAnimationValue: Double {
        switch self {
        case .inhale, .innerHold:
            return 360
        case .exhale, .outerHold:
            return 0.001
        default:
            return 0
        }
    }
    
}

enum TimerState {
    case stopped, paused, started
}
