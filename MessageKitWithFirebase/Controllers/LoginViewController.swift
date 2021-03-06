//
//  LoginViewController.swift
//  MessageKitWithFirebase
//
//  Created by yonekan on 2019/05/01.
//  Copyright © 2019 yonekan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        let authentication = user.authentication
        // Googleのトークンを渡し、Firebaseクレデンシャルを取得する。
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)
        
        // Firebaseにログインする。
        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in
            
            if let err = error {
                print(err)
            } else {
                print("ログイン成功")
                
                let user = authDataResult?.user
                let userService = UserService()
                
                userService.register(user: user!, didRegisterCompletion: self.moveToChatVC)
                
            }
        }
    }
    
    
    /// チャット画面へ画面遷移する
    func moveToChatVC() {
        performSegue(withIdentifier: "toChatVC", sender: nil)
    }
}
