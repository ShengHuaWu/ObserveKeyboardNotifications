//
//  NotificationDescriptor.swift
//  ObserveKeyboardNotifications
//
//  Created by ShengHua Wu on 25/04/2017.
//  Copyright © 2017 ShengHua Wu. All rights reserved.
//

import Foundation

struct NotificationDescriptor<Payload> {
    let name: Notification.Name
    let convert: (Notification) -> Payload
}

extension NotificationCenter {
    func addObserver<Payload>(with descriptor: NotificationDescriptor<Payload>, block: @escaping (Payload) -> ()) {
        addObserver(forName: descriptor.name, object: nil, queue: nil) { (note) in
            block(descriptor.convert(note))
        }
    }
}
