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
    
    var contact: Contact? {
        didSet {
            navigationItem.title = contact?.name
            
            messages = contact?.messages?.allObjects as? [Message]
            
            // sort messages for all contacts in order
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
            
        }
    }
    
    var messages: [Message]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.init(red: 244/255, green: 242/255, blue: 237/255, alpha: 1)
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.alwaysBounceVertical = true
        
    }
    
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
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
}

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.frame = CGRect(x: 5, y: 5, width: UIScreen.main.bounds.width - 10, height: 30)
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        textView.isEditable = false
        
        return textView
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.init(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        
        addSubview(messageTextView)
        
    }
    
}
