//
//  ChatLogController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 4/17/17.
//
//

import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellID = "cellID"
    // ============================================================
    var contact: Contact? {
        didSet {
            navigationItem.title = contact?.name
            
            messages = contact?.messages?.allObjects as? [Message]
            
            // sort messages for all contacts in order
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
            
        }
    }
    
    var messages: [Message]?
    // ============================================================
    // input views
    var bottomConstraint: NSLayoutConstraint?
    
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
    
    // ============================================================
    // view helper functions
    func handleSend() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let msg = ChatViewController.createMessagewithText(text: inputTextField.text!, contact: contact!, minutesAgo: 0, context: context!, issender: true)
        
        print("sender send text: " + inputTextField.text!)
        
        do {
            try context?.save()
            messages?.append(msg)
            
            let item = messages!.count - 1
            let insertionIndexPath = IndexPath.init(item: item, section: 0)
            collectionView?.insertItems(at: [insertionIndexPath])
            let cell = collectionView?.cellForItem(at: insertionIndexPath) as! ChatLogMessageCell
            cell.textBubbleTailRev.alpha = 0.85
            cell.textBubbleTail.alpha = 0
            collectionView?.scrollToItem(at: insertionIndexPath, at: .bottom, animated: true)
            inputTextField.text = nil
            
        } catch let err {
            print(err)
        }
        
    }
    
    func handleKeyboardNoti(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: {(completed) in
                if isKeyboardShowing {
                    let indexpath = IndexPath.init(row: self.messages!.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
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
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    // update the each chat cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatLogMessageCell
        cell.messageTextView.text = messages?[indexPath.item].text
        
        if let msg = messages?[indexPath.item], let messageText = msg.text, let profileImageName = msg.contact?.profileImageName {
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!], context: nil)
            
            if (!msg.isSender) {
                cell.messageTextView.frame = CGRect(x: 6 + 72.5, y: 2.6, width: estimatedFrame.width + 10, height: estimatedFrame.height + 18)
                cell.textBubbleView.frame = CGRect(x: 72.5, y: 0, width: estimatedFrame.width + 12 + 10, height: estimatedFrame.height + 18 + 5.2)
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
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 12 - 10 - 10 - 15, y: 0, width: estimatedFrame.width + 12 + 12, height: estimatedFrame.height + 18 + 5.2)
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
        if let messageText = messages?[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 18)
        }
        
        return CGSize(width: view.frame.width, height: 45)
    }
    
    // add an edge on the top of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
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
