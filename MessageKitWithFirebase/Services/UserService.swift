//
//  UserService.swift
//  MessageKitWithFirebase
//
//  Created by yonekan on 2019/05/03.
//  Copyright © 2019 yonekan. All rights reserved.
//

import Foundation
import Firebase

class UserService {
 
    func register(user: User, didRegisterCompletion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(user.uid)
        
        userDoc.getDocument(completion: { (documentSnapshot, error) in
            
            if !documentSnapshot!.exists {
                userDoc.setData([
                    "displayName": user.displayName as Any,
                    "photoUrl": user.photoURL?.absoluteString as Any
                ])
            }
            
            didRegisterCompletion()
        })
    }
}
