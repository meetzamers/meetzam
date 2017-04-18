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
        
        if let messageText = messages?[indexPath.item].text, let profileImageName = messages?[indexPath.item].contact?.profileImageName {
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!], context: nil)
            
            cell.messageTextView.frame = CGRect(x: 6 + 65, y: 2.6, width: estimatedFrame.width + 12, height: estimatedFrame.height + 18)
            cell.textBubbleView.frame = CGRect(x: 65, y: 0, width: estimatedFrame.width + 12 + 12, height: estimatedFrame.height + 18 + 5.2)
            
//            print(cell.textBubbleView.frame.height)
            
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
    
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.clear
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
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
