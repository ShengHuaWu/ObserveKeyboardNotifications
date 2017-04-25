//
//  KeyboardPayload.swift
//  ObserveKeyboardNotifications
//
//  Created by ShengHua Wu on 25/04/2017.
//  Copyright © 2017 ShengHua Wu. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardPayload {
    let beginFrame: CGRect
    let endFrame: CGRect
    let curve: UIViewAnimationCurve
    let duration: TimeInterval
    let isLocal: Bool
}

extension KeyboardPayload {
    init(note: Notification) {
        let userInfo = note.userInfo
        beginFrame = userInfo?[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        curve = UIViewAnimationCurve(rawValue: userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        isLocal = userInfo?[UIKeyboardIsLocalUserInfoKey] as! Bool
    }
}
