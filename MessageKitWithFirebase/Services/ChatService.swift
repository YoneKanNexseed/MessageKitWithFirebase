//
//  ChatService.swift
//  MessageKitWithFirebase
//
//  Created by yonekan on 2019/05/03.
//  Copyright © 2019 yonekan. All rights reserved.
//

import Foundation
import Firebase

class ChatService {
    
    func getMessages(didFindMessages: @escaping (_ messageList: [Message]) -> Void) {
        let db = Firestore.firestore()
        db.collection("messages").order(by: "sentDate").getDocuments { (querySnapshot, error) in
            
            var messageList: [Message] = []
            
            for document in querySnapshot!.documents {
                guard
                    let uid = document.get("uid") as? String,
                    let name = document.get("name") as? String,
                    let photoUrl = document.get("photoUrl") as? String,
                    let text = document.get("text") as? String,
                    let sentTimestamp = document.get("sentDate") as? Timestamp
                    
                    else {
                        print("error")
                        return
                }
                
                let chatUser: ChatUser = ChatUser(uid: uid, name: name, photoUrl: photoUrl)
                let message: Message = Message(user: chatUser, text: text, messageId: document.documentID, sentDate: sentTimestamp.dateValue())
                
                messageList.append(message)
            }
            
            didFindMessages(messageList)
        }
    }
    
    func messageListener(didFindMessages: @escaping (_ messageList: [Message]) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        let listener = db.collection("messages").order(by: "sentDate").addSnapshotListener { (querySnapshot, error) in
            var messageList: [Message] = []
            for document in querySnapshot!.documents {
                
                guard
                    let uid = document.get("uid") as? String,
                    let name = document.get("name") as? String,
                    let photoUrl = document.get("photoUrl") as? String,
                    let text = document.get("text") as? String,
                    let sentTimestamp = document.get("sentDate") as? Timestamp
                    
                    else {
                        print("error")
                        return
                }
                
                let chatUser: ChatUser = ChatUser(uid: uid, name: name, photoUrl: photoUrl)
                let message: Message = Message(user: chatUser, text: text, messageId: document.documentID, sentDate: sentTimestamp.dateValue())
                
                messageList.append(message)
            }
            
            didFindMessages(messageList)
        }
        
        return listener
    }
}
