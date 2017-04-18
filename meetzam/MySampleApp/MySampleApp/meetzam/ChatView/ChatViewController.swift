//
//  ChatViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let cellID = "cellID"
    var messages: [Message]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellID)
        
        setupData()
    }
    
    // return number of sections in this collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    // return cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageCell
        
        if let msg = messages?[indexPath.item] {
            cell.message = msg
        }
        
        return cell
    }
    
    // resize cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    // resize the cell spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // to chat log (the real chat room)
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        controller.contact = messages?[indexPath.item].contact
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
}

class MessageCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.init(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.6) : UIColor.white
        }
    }
    
    var message: Message? {
        didSet {
            contactNameLabel.text = message?.contact?.name
            contactNameLabel.sizeToFit()
            if let current_img_name = message?.contact?.profileImageName {
                contactProfileImageView.image = UIImage(named: current_img_name)
            }
            
            contactMsgLabel.text = message?.text
            if let msg_date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                let elapsedTimeinSec = NSDate().timeIntervalSince(msg_date as Date)
                
                // if the time is greater than a day(24 hrs) or a week, change date format
                if (elapsedTimeinSec > (60*60*24*7)) {
                    dateFormatter.dateFormat = "MM/dd/yy"
                }
                else if (elapsedTimeinSec > (60*60*24)) {
                    dateFormatter.dateFormat = "EEE"
                }
                
                timeLabel.text = dateFormatter.string(from: msg_date as Date)
            }
            
        }
    }
    
    let contactProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.frame = CGRect(x: 10, y: 79, width: UIScreen.main.bounds.width, height: 1)
        
        return view
    }()
    
    let contactNameLabel: UILabel = {
        let namelabel = UILabel()
        namelabel.frame = CGRect(x: 0, y: 5, width: 100, height: 25)
        namelabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        namelabel.textAlignment = .left
//        namelabel.sizeToFit()
        
        return namelabel
    }()
    
    let contactMsgLabel: UILabel = {
        let msglabel = UILabel()
        msglabel.frame = CGRect(x: 0, y: 36, width: UIScreen.main.bounds.width - 90, height: 19)
        msglabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        msglabel.textColor = UIColor.gray
        msglabel.textAlignment = .left
        msglabel.lineBreakMode = .byTruncatingTail
        
        return msglabel
    }()
    
    let timeLabel: UILabel = {
        let tlabel = UILabel()
        tlabel.frame = CGRect(x: UIScreen.main.bounds.width - 160, y: 5, width: 70, height: 18)
        tlabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        tlabel.textColor = UIColor.gray
        tlabel.textAlignment = .right
        
        return tlabel
    }()
    
    override func setupViews() {
        backgroundColor = UIColor.white
        
        addSubview(contactProfileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
    }
    
    private func setupContainerView() {
        let cv = UIView()
        cv.frame = CGRect(x: 80, y: 10, width: UIScreen.main.bounds.width - 90, height: 60)
        
        cv.addSubview(contactNameLabel)
        cv.addSubview(contactMsgLabel)
        cv.addSubview(timeLabel)
        addSubview(cv)
    }
    
}

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
//        backgroundColor = UIColor.blue
    }
}
