//
//  Message.swift
//  MessageKitWithFirebase
//
//  Created by yonekan on 2019/05/01.
//  Copyright © 2019 yonekan. All rights reserved.
//

import Foundation
import MessageKit

struct Message {
    let user: ChatUser
    let text: String
    let messageId: String
    let sentDate: Date
}

extension Message: MessageType {
    
    var sender: Sender {
        return Sender(id: user.uid, displayName: user.name)
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}
