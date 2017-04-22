//
//  ChatLogController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 4/17/17.
//
//

import UIKit
import CoreData
import AWSMobileHubHelper

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    private let cellID = "cellID"
    // ============================================================
    var contact: Contact? {
        didSet {
            navigationItem.title = contact?.name
        }
    }
    
    // ============================================================
    // input views
    var bottomConstraint: NSLayoutConstraint?
    var keyboardHeight: CGFloat = 0
    
    lazy var fetchResultController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "contact.name = %@", self.contact!.name!)
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let fc = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        
        return fc
    }()
    
    var blockOperations = [BlockOperation]()
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: { (completed) in
            let lastItem = (self.fetchResultController.sections?[0].numberOfObjects)! - 1
            let indexPath = IndexPath.init(row: lastItem, section: 0)
            
            let cell = self.collectionView?.cellForItem(at: indexPath) as! ChatLogMessageCell
            cell.textBubbleTailRev.alpha = 0.85
            cell.textBubbleTail.alpha = 0
            
            let contentH = (self.collectionView?.contentSize.height)!
            let orgH = (self.collectionView?.frame.size.height)! - self.keyboardHeight - 110
            if (contentH > orgH) {
                self.collectionView?.setContentOffset(CGPoint(x: CGFloat(0), y: CGFloat((self.collectionView?.contentSize.height)! - (self.collectionView?.frame.size.height)! + self.keyboardHeight) + 46), animated: true)
            }
            else {
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
            
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation.init(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
    }()
    
    let inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a message..."
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        
        return tf
    }()
    
    lazy var inputSendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor.init(red: 0/255, green: 137/255, blue: 249/255, alpha: 1), for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        return sendButton
    }()
    // ============================================================
    // viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // perform fetch
        do {
            try fetchResultController.performFetch()
            print(fetchResultController.sections?[0].numberOfObjects)
            
        } catch let err {
            print(err)
        }
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simul))
        
        self.tabBarController?.tabBar.isHidden = true
        
        collectionView?.backgroundColor = UIColor.init(red: 242/255, green: 240/255, blue: 234/255, alpha: 1)
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellID)
        
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(45)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComp()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNoti), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNoti), name: .UIKeyboardWillHide, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        
    }
    
    func notificationMsg(new_Contact: Contact, text: String) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        
        ChatViewController.createMessagewithText(text: text, contact: new_Contact, minutesAgo: Date.init(timeIntervalSinceNow: 0), context: context!)
        
        do {
            try context?.save()
        } catch let err {
            print(err)
        }
    }
    
    func simul() {
        let cv = ChatViewController()
        cv.incomingData()
    }
    
    // ============================================================
    // view helper functions
    func handleSend() {
        if (inputTextField.text != "") {
            let delegate = UIApplication.shared.delegate as? AppDelegate
            let context = delegate?.persistentContainer.viewContext
            ChatViewController.createMessagewithText(text: inputTextField.text!, contact: contact!, minutesAgo: Date.init(timeIntervalSinceNow: 0), context: context!, issender: true)
            
            let myID = AWSIdentityManager.default().identityId
            let msg = fetchResultController.fetchedObjects?.first as! Message
            let yourID = msg.contact?.userID
            
            // backend send message
            let chatRoomID = ChatRoomModel().getChatRoomId(userId: myID!, recipientId: yourID!)
            ConversationModel().addConversation(_userId: myID!, _chatRoomId: chatRoomID, _message: inputTextField.text!)
            API().sendMessage(userId: yourID!, message: inputTextField.text!)
            
            print("sender send text: " + inputTextField.text!)
            
            do {
                try context?.save()
                inputTextField.text = nil
//                let msgArray = contact?.messages?.allObjects as! [Message]
//                let lastIndex = msgArray.count - 1
//                contact?.lastMessage = msgArray[lastIndex]
                
            } catch let err {
                print(err)
            }

        }
    }
    
    func handleKeyboardNoti(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            keyboardHeight = keyboardFrame.height
            
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: {(completed) in
                if isKeyboardShowing {
                    let contentH = (self.collectionView?.contentSize.height)!
                    let orgH = (self.collectionView?.frame.size.height)! - keyboardFrame.height - 110
                    
                    if (contentH > orgH) {
                        self.collectionView?.setContentOffset(CGPoint(x: CGFloat(0), y: CGFloat((self.collectionView?.contentSize.height)! - (self.collectionView?.frame.size.height)! + keyboardFrame.height) + 50), animated: true)
                    }
                }
            })
        }
        
    }
    
    private func setupInputComp() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.init(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(inputSendButton)
        messageInputContainerView.addSubview(topDividerView)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-10-[v0][v1(60)]|", views: inputTextField, inputSendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputSendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topDividerView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topDividerView)
    }
    // ============================================================
    // collction view stuff:
    // update the number of messages in this chat log
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchResultController.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    
    // update the each chat cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatLogMessageCell
        let msg = fetchResultController.object(at: indexPath) as! Message
        cell.messageTextView.text = msg.text
        
        if let messageText = msg.text, let profileImageName = msg.contact?.profileImageName {
            if FileManager.default.fileExists(atPath: profileImageName) {
                let profileURL = URL(fileURLWithPath: profileImageName)
                cell.profileImageView.image = UIImage(contentsOfFile: profileURL.path)!
            }
            
            let size = CGSize(width: 250, height: 1000)
            let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!], context: nil)
            
            if (!msg.isSender) {
                cell.messageTextView.frame = CGRect(x: 6 + 72.5, y: 2.6, width: estimatedFrame.width + 10, height: estimatedFrame.height + 18)
                cell.textBubbleView.frame = CGRect(x: 72.5, y: 0, width: estimatedFrame.width + 10 + 10, height: estimatedFrame.height + 18 + 5.2)
                cell.textBubbleTail.frame = CGRect(x: 56, y: 30, width: 15, height: 15)
                
                cell.profileImageView.isHidden = false
                cell.textBubbleView.backgroundColor = UIColor.init(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                cell.textBubbleTail.alpha = 0.85
                cell.textBubbleTailRev.alpha = 0
            }
            else {
                // sender's message
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 10 - 6 - 10 - 15, y: 2.6, width: estimatedFrame.width + 12, height: estimatedFrame.height + 18)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 10 - 10 - 10 - 15, y: 0, width: estimatedFrame.width + 10 + 10, height: estimatedFrame.height + 18 + 5.2)
                cell.textBubbleTailRev.frame = CGRect(x: view.frame.width - 21, y: 30, width: 15, height: 15)
                
                cell.profileImageView.isHidden = true
                cell.textBubbleView.backgroundColor = UIColor.init(red: 13/255, green: 195/255, blue: 117/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
                cell.textBubbleTailRev.alpha = 0.85
                cell.textBubbleTail.alpha = 0
            }
            
        }

        return cell
    }
    
    // update the size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let msg = fetchResultController.object(at: indexPath) as! Message
        if let messageText = msg.text {
            let size = CGSize(width: 250, height: 1000)
            let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 18)
        }
        
        return CGSize(width: view.frame.width, height: 45)
    }
    
    // add an edge on the top of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 0, 15, 0)
    }
    
    // resize the cell spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    // ============================================================
    
}

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        textView.isEditable = false
        
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 3
        iv.layer.masksToBounds = true
        
        return iv

    }()
    
    let textBubbleTail: UIImageView = {
        let tail = UIImageView()
        tail.image = UIImage(named: "ChatTail")
        tail.contentMode = .scaleAspectFill
        tail.alpha = 0
        
        return tail
    }()
    
    let textBubbleTailRev: UIImageView = {
        let tail = UIImageView()
        tail.image = UIImage(named: "ChatTailRev")
        tail.contentMode = .scaleAspectFill
        tail.alpha = 0
        
        return tail
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.clear
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addSubview(textBubbleTail)
        addSubview(textBubbleTailRev)
        
        addConstraintsWithFormat(format: "H:|-10-[v0(45)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:|[v0(45)]", views: profileImageView)
        
    }
    
}

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDictionary))
        
    }
    
}
