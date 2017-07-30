//
//  NotificationDescriptor.swift
//  ObserveKeyboardNotifications
//
//  Created by ShengHua Wu on 25/04/2017.
//  Copyright © 2017 ShengHua Wu. All rights reserved.
//

import Foundation
import UIKit

struct NotificationDescriptor<Payload> {
    let name: Notification.Name
    let convert: (Notification) -> Payload
}

final class NotificationToken {
    private let token: NSObjectProtocol
    private let notificationCenter: NotificationCenter
    
    init(token: NSObjectProtocol, notificationCenter: NotificationCenter) {
        self.token = token
        self.notificationCenter = notificationCenter
    }
    
    deinit {
        notificationCenter.removeObserver(token)
    }
}

extension NotificationCenter {
    func addObserver<Payload>(with descriptor: NotificationDescriptor<Payload>, block: @escaping (Payload) -> ()) -> NotificationToken {
        let token = addObserver(forName: descriptor.name, object: nil, queue: nil) { (note) in
            block(descriptor.convert(note))
        }
        
        return NotificationToken(token: token, notificationCenter: self)
    }
}

extension UIViewController {
    static let keyboardWillShow = NotificationDescriptor(name: Notification.Name.UIKeyboardWillShow, convert: KeyboardPayload.init)
    static let keyboardWillHide = NotificationDescriptor(name: Notification.Name.UIKeyboardWillHide, convert: KeyboardPayload.init)
}
