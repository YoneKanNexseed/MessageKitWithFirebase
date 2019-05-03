//
//  ChatViewController.swift
//  MessageKitWithFirebase
//
//  Created by yonekan on 2019/05/01.
//  Copyright © 2019 yonekan. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import MessageInputBar
import Alamofire
import AlamofireImage

class ChatViewController: MessagesViewController {

    var messageList: [Message] = []
    
    let imageCache = AutoPurgingImageCache()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
    
    var listener: ListenerRegistration!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
//        maintainPositionOnKeyboardFrameChanged = true
        
        let chatService = ChatService()
        chatService.getMessages { (messageList) in
            self.messageList = []
            self.messageList = messageList
            self.messagesCollectionView.reloadData()
        }
        
        listener = chatService.messageListener(didFindMessages: { (messageList) in
            self.messageList = []
            self.messageList = messageList
            self.messagesCollectionView.reloadData()
        })
        
        messagesCollectionView.backgroundColor = UIColor(red: 114/255, green: 148/255, blue: 194/255, alpha: 1)
        
        messagesCollectionView.handleTapGesture(<#T##gesture: UIGestureRecognizer##UIGestureRecognizer#>)
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    // 送信者（自分）
    func currentSender() -> Sender {
        let user = Auth.auth().currentUser
        return Sender(id: user!.uid, displayName: user!.displayName!)
    }
    
    // メッセージの種類
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // メッセージの件数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let user = Auth.auth().currentUser
        if message.sender.id != user?.uid {
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージの設定
extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

        let url = messageList[indexPath.section].user.photoUrl
        
        let urlRequest = URLRequest(url: URL(string: url)!)

        if let image = imageCache.image(for: urlRequest) {
            let avatar = Avatar(image: image, initials: message.sender.displayName)
            avatarView.set(avatar: avatar)
            print("cache")
            return
        }
        
        Alamofire.request(urlRequest).responseImage { response in
            guard let image = response.result.value else { return }
            self.imageCache.add(image, for: urlRequest)
            let avatar = Avatar(image: image, initials: message.sender.displayName)
            avatarView.set(avatar: avatar)
            print("download")
        }
    
    }

}

// メッセージラベルの設定
extension ChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

// メッセージセルの設定
extension ChatViewController: MessageCellDelegate {
    
}

// メッセージ入力バーに関する設定・処理
extension ChatViewController: MessageInputBarDelegate {
    
    // 送信ボタン押下時の処理
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        db.collection("messages").addDocument(data: [
            "uid": user?.uid as Any,
            "name": user?.displayName as Any,
            "photoUrl": user?.photoURL?.absoluteString as Any,
            "text": text,
            "sentDate": Date()
        ])
        
        inputBar.inputTextView.text = ""
    }
}
