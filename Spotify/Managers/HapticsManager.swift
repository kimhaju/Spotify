//
//  HapticsManager.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import Foundation
import UIKit

//->진동? 조절
final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {
        
    }
    
    //->전부 적용안하고 일부만 적용하는 이유
    // 나머지는 직접 필요한곳에 적용하고 빼고 하기 위해서
    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generaotor = UINotificationFeedbackGenerator()
            generaotor.prepare()
            generaotor.notificationOccurred(type)
        }
    }
}
