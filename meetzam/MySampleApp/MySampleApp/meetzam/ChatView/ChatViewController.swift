//
//  ChatViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit
import CoreData

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    private let cellID = "cellID"
//    var messages: [Message]?
    var setUPtimes = 0
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Contact")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "lastMessage.date", ascending: false)]
        fetchRequest.predicate = NSPredicate.init(format: "lastMessage != nil")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let frc = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var blockOperations = [BlockOperation]()
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("didchange")
        self.collectionView?.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: nil)
//        { (completed) in }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        print("controller")
        
        if type == .insert {
            blockOperations.append(BlockOperation.init(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
        
        else if type == .move {
            DispatchQueue.main.async {
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
                    }, completion: { (finished: Bool) -> Void in
                })
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellID)
        
        setupData()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Chat will Appear")
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.collectionView?.reloadData()
    }
    
    // return number of sections in this collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    // return cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageCell
        let contact = fetchedResultsController.object(at: indexPath) as! Contact
        cell.message = contact.lastMessage
        
        return cell
    }
    
    // resize cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    // resize the cell spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // to chat log (the real chat room)
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        
        let contact = fetchedResultsController.object(at: indexPath) as! Contact
        controller.contact = contact
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
}

class MessageCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(white: 0.5, alpha: 0.5) : UIColor.clear
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(white: 0.5, alpha: 0.5) : UIColor.clear
        }
    }
    
    var message: Message? {
        didSet {
            contactNameLabel.text = message?.contact?.name
            contactNameLabel.sizeToFit()
            if let current_img_name = self.message?.contact?.profileImageName {
                if FileManager.default.fileExists(atPath: current_img_name) {
                    let profileURL = URL(fileURLWithPath: current_img_name)
                    self.contactProfileImageView.image = UIImage(contentsOfFile: profileURL.path)!
                }
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
        iv.frame = CGRect(x: 10, y: 7.5, width: 55, height: 55)
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.frame = CGRect(x: 10, y: 69.5, width: UIScreen.main.bounds.width, height: 0.5)
        
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
        backgroundColor = UIColor.clear
        
        addSubview(contactProfileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
    }
    
    private func setupContainerView() {
        let cv = UIView()
        cv.frame = CGRect(x: 75, y: 5, width: UIScreen.main.bounds.width - 95, height: 60)
        
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
