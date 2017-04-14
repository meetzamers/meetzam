//
//  ContactsViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//  Monika Qi Meng
//

import UIKit
import AWSMobileHubHelper

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var displayNames: [String]!
    var profilePics: [UIImage]!
    
    @IBOutlet weak var contactTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
    
        loadContact()

    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //let matchedUserIDs = UserProfileToDB().getMatchedUserIDs(key: AWSIdentityManager.default().identityId!)
        //return matchedUserIDs.count;
        
        return profilePics.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell

        cell.profilePicture.image = profilePics[indexPath.row]
        cell.displayName.text = displayNames[indexPath.row]
        cell.displayName.font = UIFont(name: "HelveticaNeue-Light", size: 22)

        return cell
        
    }
    
    func loadContact() {
        displayNames = [String]()
        profilePics = [UIImage]()

        let matchedUserIDs = UserProfileToDB().getMatchedUserIDs(key: AWSIdentityManager.default().identityId!)
        let matchedUsers = UserProfileToDB().getMatchedUserProfiles(userIDs: matchedUserIDs)
        
        for matchedUser in matchedUsers
        {
            //add names to displayNames
            displayNames.append(matchedUser.displayName!)
            
            loadProfile(userId: matchedUser.userId!)
            
        }
        
        //delete later
        displayNames = ["user1", "user2", "user3","user1", "user2","user1", "user2","user1", "user2","user1"]
        profilePics = [#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie"),#imageLiteral(resourceName: "emptyMovie")]
        
    }
    
    func loadProfile(userId: String) {
        let URLString = UserProfileToDB().downloadUserIcon(userID: userId).path
        print("the local directory is \(URLString)")
        if FileManager.default.fileExists(atPath: URLString) {
            print("The file exists!! \(userId)")
            let profileURL = URL(fileURLWithPath: URLString)
            profilePics.append(UIImage(contentsOfFile: profileURL.path)!)
        } else {
            profilePics.append(#imageLiteral(resourceName: "emptyMovie"))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showProfile" {
            return
        }
    
        let indexPaths = self.contactTable!.indexPathForSelectedRow!
        let indexPath = indexPaths[1]
        print("the index Paths is \(indexPaths)")
        let vc = segue.destination as! ContactProfile
        
        // load everything in profile page!
        vc.displayName.text = displayNames[indexPath]
        
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            self.profilePics.remove(at:indexPath.row)
            self.displayNames.remove(at:indexPath.row)
            
            //call DB function to delete the contact
            // XXXXXX
            
            contactTable.reloadData()
        }
    }
    
    

    
}
