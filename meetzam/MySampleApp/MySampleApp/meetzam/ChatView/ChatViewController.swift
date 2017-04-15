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
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        collectionView?.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(ContactCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    // return number of sections in this collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // return cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
    }
    
    // resize cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

class ContactCell: BaseCell {
    
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
        namelabel.text = "Jack"
        namelabel.textAlignment = .left
        namelabel.sizeToFit()
        
        return namelabel
    }()
    
    let contactMsgLabel: UILabel = {
        let msglabel = UILabel()
        msglabel.frame = CGRect(x: 0, y: 36, width: UIScreen.main.bounds.width - 90, height: 19)
        msglabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        msglabel.text = "Message content testing here this is wayyyyyyyyyyyyy tooooo loong"
        msglabel.textColor = UIColor.gray
        msglabel.textAlignment = .left
        
        print("width: \(msglabel.frame.width) height:\(msglabel.frame.height)")
        
        msglabel.lineBreakMode = .byTruncatingTail
        
        return msglabel
    }()
    
    override func setupViews() {
        backgroundColor = UIColor.white
        
        contactProfileImageView.image = UIImage(named: "profile1")
        addSubview(contactProfileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
    }
    
    private func setupContainerView() {
        let cv = UIView()
//        cv.backgroundColor = UIColor.red
        cv.frame = CGRect(x: 80, y: 10, width: UIScreen.main.bounds.width - 90, height: 60)
        
        cv.addSubview(contactNameLabel)
        cv.addSubview(contactMsgLabel)
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
