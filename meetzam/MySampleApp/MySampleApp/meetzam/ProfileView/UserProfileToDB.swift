//
//  UserProfileToDB.swift
//  MySampleApp
//
//  Created by Rainy on 2017/2/26.
//  update:bug fixed related to movie count in saving edited profile
//  
//  add device in line: 104, 204, 278, 475, 619
//  testing method in line 426
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.10
//
import Foundation
import UIKit
import AWSDynamoDB
import AWSS3

import AWSMobileHubHelper

class UserProfileToDB: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var userId: String?
    var displayName: String?
    var bio: String?
    var age: String?
    var gender: String?
    var region: String?
    var email: String?
    var currentLikedMovie = Set<String>()
    var movieCount: NSNumber?
    var likedUsers = Set<String>()
    var matchedUsers = Set<String>()
    var device: String?
    
    class func dynamoDBTableName() -> String {
        
        return "meetzam-mobilehub-1569925313-UserProfile"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "userId"
    }
    
    
    // Ryan: check first time user ID
    func isUserIDinTable(_userId: String) -> Bool {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let mapper = AWSDynamoDBObjectMapper.default()
        var result: Bool = false
        var userIDInTable: Array = [String]()
        let scanExpression = AWSDynamoDBScanExpression()
        
        mapper.scan(UserProfileToDB.self, expression: scanExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let allUsers = task.result {
                for user in allUsers.items as! [UserProfileToDB] {
                    userIDInTable.append(user.userId!)
                }
            }
            if (userIDInTable.contains(_userId)) {
                print("found user in the table")
                result = true
            }
            
            return nil
        }).waitUntilFinished()

        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return result
    }
    
    
    // function to add/update user info into database
    // argument: dbName...
    //JUNPU: fixed busy waiting
    func insertProfile(_userId: String, _displayName: String, _bio: String, _age: String, _gender: String, _region: String, _email: String) {
        print("===== insertProfile =====")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let mapper = AWSDynamoDBObjectMapper.default()
        let userProfile = UserProfileToDB()
        //JUNPU: tixed this
        var result: Bool = false
        var userIDInTable: Array = [String]()
        let scanExpression = AWSDynamoDBScanExpression()
        mapper.scan(UserProfileToDB.self, expression: scanExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let allUsers = task.result {
                for user in allUsers.items as! [UserProfileToDB] {
                    userIDInTable.append(user.userId!)
                }
            }
            if (userIDInTable.contains(_userId)) {
                print("found user in the table")
                result = true
            }
            return nil
        }).continueWith(block: { (task:AWSTask<AnyObject>) -> Any? in
            if result == false {
                print("Error: Can not find the user in the table.")
                return nil
            }
            //JUNPU: nested promises
            print("now continue to insertProfile")
            mapper.load(UserProfileToDB.self, hashKey: _userId, rangeKey: nil).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
                if let error = task.error as? NSError {
                    print("InsertError: \(error)")
                } else if let user_profile_addTo = task.result as? UserProfileToDB {
                    userProfile?.currentLikedMovie=user_profile_addTo.currentLikedMovie
                    // if the user does not have any liked movies
                    if (user_profile_addTo.currentLikedMovie.count == 0)
                    {
                        userProfile?.currentLikedMovie.insert("mushroom13")
                    }
                    userProfile?.likedUsers = user_profile_addTo.likedUsers
                    if (user_profile_addTo.likedUsers.count == 0)
                    {
                        userProfile?.likedUsers.insert("mushroom13")
                    }
                    userProfile?.matchedUsers = user_profile_addTo.matchedUsers
                    if (user_profile_addTo.matchedUsers.count == 0)
                    {
                        userProfile?.matchedUsers.insert("mushroom13")
                    }
                    userProfile?.movieCount = user_profile_addTo.movieCount
                    userProfile?.userId=user_profile_addTo.userId
                    //mush
                    userProfile?.device=user_profile_addTo.device
                    
                    ////////////////////////////////////
                    userProfile?.userId  = _userId
                    userProfile?.displayName = _displayName
                    userProfile?.bio = _bio
                    userProfile?.age = _age
                    userProfile?.gender = _gender
                    userProfile?.region = _region
                    userProfile?.email = _email
                    mapper.save(userProfile!)
                    print("insertProfile SUCCESS")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return nil
            })
            return nil
        })
    }
    
    
    //JUNPU: func isInTable(userID: String) -> Bool is nolonger needed.
    
    
    func getProfileForEdit(key: String, user_profile: UserProfileToDB?, displayname: UITextField!, bio: UITextField!, age: UITextField!, gender: UITextField!, region: UITextField!, email: UITextField!){
        print("===== getProfileForEdit =====")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let mapper = AWSDynamoDBObjectMapper.default()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            } else if let user_profile = task.result as? UserProfileToDB {
                displayname.text = user_profile.displayName
                //print(displayname.text)
                bio.text = user_profile.bio
                //print(bio.text)
                age.text = user_profile.age
                //print(age.text)
                gender.text = user_profile.gender
                //print(gender.text)
                region.text = user_profile.region
                //print(region.text)
                email.text = user_profile.email
                //print(email.text)
                print("getProfileForEdit SUCCESS")
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
        
    }
    
    func getProfileForDisplay(key: String, user_profile: UserProfileToDB?, displayname: UILabel!, bio: UILabel!){
        print("===== getProfileForDisplay =====")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let mapper = AWSDynamoDBObjectMapper.default()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            } else if let user_profile = task.result as? UserProfileToDB {
                //print("     Getting fields in user_profile")
                displayname.text = user_profile.displayName
                //print(displayname.text)
                bio.text = user_profile.bio
                //print(bio.text)
                print("SUCCESS")
            }
            return nil
            
        }).continueWith(block: { _ in
            if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                if mainVC is MainViewController {
                    if let selectedVC = (mainVC as! MainViewController).selectedViewController {
                        if selectedVC is UINavigationController {
                            let finalVC = selectedVC as? UINavigationController
                            if finalVC?.visibleViewController is ProfileViewController {
                                (finalVC?.visibleViewController as! ProfileViewController).endAnimateWaiting()
                            }
                        }
                    }
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
        
    }
    //JUNPU: fixed busy waiting
    func insertToCurrentLikedMovie(key: String, movieTitle: String)
    {
        print("===== insertToCurrentLikedMovie =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let userProfile = UserProfileToDB()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                userProfile?.userId=key
//                print("     key is \(key)")
                userProfile?.displayName = user_profile_addTo.displayName
//                print("displayname is \(userProfile?.displayName)")
                userProfile?.bio = user_profile_addTo.bio
//                print("bio is \(userProfile?.bio)")
                userProfile?.age = user_profile_addTo.age
//                print("age is \(userProfile?.age)")
                userProfile?.gender = user_profile_addTo.gender
//                print("gender is \(userProfile?.gender)")
                userProfile?.region = user_profile_addTo.region
//                print("region is \(userProfile?.region)")
                userProfile?.device=user_profile_addTo.device
                
                userProfile?.currentLikedMovie = user_profile_addTo.currentLikedMovie
                if (user_profile_addTo.currentLikedMovie.count == 0)
                {
                    userProfile?.currentLikedMovie.insert("mushroom13")
                }
                userProfile?.likedUsers = user_profile_addTo.likedUsers
                if (user_profile_addTo.likedUsers.count == 0)
                {
                    userProfile?.likedUsers.insert("mushroom13")
                }
                userProfile?.matchedUsers = user_profile_addTo.matchedUsers
                if (user_profile_addTo.matchedUsers.count == 0)
                {
                    userProfile?.matchedUsers.insert("mushroom13")
                }
                for movie in (userProfile?.currentLikedMovie)! {
//                    print("\(movie)")
                }
                userProfile?.movieCount = user_profile_addTo.movieCount
                
                userProfile?.email = user_profile_addTo.email
//                print("email is \(userProfile?.email)")

                
                //////////////////////////////////////////////
                
                if (!((userProfile?.currentLikedMovie.contains(movieTitle))!))
                {
                    if (userProfile?.currentLikedMovie.count == 1 && (userProfile?.currentLikedMovie.contains("mushroom13"))!) {
                        //dummy exist
                        userProfile?.currentLikedMovie.removeAll()
                    }
                    userProfile?.currentLikedMovie.insert(movieTitle)
                    userProfile?.movieCount = userProfile?.currentLikedMovie.count as NSNumber?
                }
                for movie in (userProfile?.currentLikedMovie)! {
                    print("\(movie)")
                }
                mapper.save(userProfile!)
                print("insertToCurrentLikedMovie SUCCESS")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
    }
    
    //JUNPU: fixed busy waiting
    func deleteFromCurrentLikedMovie(key: String, movieTitle: String)
    {
        print("===== deleteFromCurrentLikedMovie =====")
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let userProfile = UserProfileToDB()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                userProfile?.userId=key
//                print("     key is \(key)")
                userProfile?.displayName = user_profile_addTo.displayName
//                print("displayname is \(userProfile?.displayName)")
                userProfile?.bio = user_profile_addTo.bio
//                print("bio is \(userProfile?.bio)")
                userProfile?.age = user_profile_addTo.age
//                print("age is \(userProfile?.age)")
                userProfile?.gender = user_profile_addTo.gender
//                print("gender is \(userProfile?.gender)")
                userProfile?.region = user_profile_addTo.region
//                print("region is \(userProfile?.region)")
                
                userProfile?.device=user_profile_addTo.device
                
                userProfile?.likedUsers = user_profile_addTo.likedUsers
                if (user_profile_addTo.likedUsers.count == 0)
                {
                    userProfile?.likedUsers.insert("mushroom13")
                }
                userProfile?.matchedUsers = user_profile_addTo.matchedUsers
                if (user_profile_addTo.matchedUsers.count == 0)
                {
                    userProfile?.matchedUsers.insert("mushroom13")
                }
                userProfile?.currentLikedMovie=user_profile_addTo.currentLikedMovie
//                print("BEFORE DELETION, currentLikedMovie are: \(userProfile?.currentLikedMovie.description)")
                userProfile?.movieCount = user_profile_addTo.movieCount
                userProfile?.email = user_profile_addTo.email
//                print("email is \(userProfile?.email)")
//                print("     all put")
                
                ///////////////////////
//                print("SHOULD BE AFTER LOAD: displayname is \(userProfile?.displayName)")
                if (!((userProfile?.currentLikedMovie.contains(movieTitle))!))
                {
                    print("error: delete a movie not in user's liked movie list")
                }
                else {
//                    print("removing movie")
                    _ = userProfile?.currentLikedMovie.remove(movieTitle)
                    userProfile?.movieCount = userProfile?.currentLikedMovie.count as NSNumber?
                    //dummy string since empty string set not allowed
                    if (userProfile?.currentLikedMovie.count == 0) {
                        userProfile?.currentLikedMovie.insert("mushroom13")
                    }
                }
                
//                print("AFTER DELETION, currentLikedMovie are: \(userProfile?.currentLikedMovie.description)")
                mapper.save(userProfile!)
                print("deleteFromCurrentLikedMovie SUCCESS")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
    }
    
    
    func getLikedMovies(userId: String, user_profile: UserProfileToDB) {
        print("===== getLikedMovies =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        mapper.load(UserProfileToDB.self, hashKey: userId, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            } else if let user_profile_temp = task.result as? UserProfileToDB {
//                print("get: HERE ARE THE LIKED MOVIES")
                if (user_profile_temp.currentLikedMovie.count != 0 && user_profile_temp.movieCount == 0) {
                    print("dummy detected")
                }
                else {
                    user_profile.currentLikedMovie = user_profile_temp.currentLikedMovie
                    print(user_profile.currentLikedMovie.description)
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
    }
    
    
    //JUNPU: async dependency in the code, busy waiting still exist
    //JUNPU: most of the latency comes from this function
    //JUNPU: working
    func getPotentialUserIDs(key: String) -> [String]
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("===== getPotentialUserIDs =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var currentLikedMovie = Set<String>()
        let userProfile = UserProfileToDB()
        var waiting = 0
        
        print("     before load!!")
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                if (user_profile_addTo.currentLikedMovie.count != 0 && user_profile_addTo.movieCount == 0) {
                    print("dummy detected")
                }
                else {
                    currentLikedMovie=user_profile_addTo.currentLikedMovie
                }
                userProfile?.displayName=user_profile_addTo.displayName
            }
            return nil
        }).waitUntilFinished()
        
//        waiting = 0
//        while (userProfile?.displayName == nil)
//        {
//            waiting = 1
//        }

        print("     next step")
        var matchedUserIDs: Array = [String]()
        var dummynum: Int = 0
        for movie in (currentLikedMovie) {
            //JUNPU: this loop produces lots of latency by busy waiting in a sequence
            dummynum = 0
            print("You Liked \(movie)")
            mapper.load(SingleMovie.self, hashKey: movie, rangeKey: nil).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
                if let error = task.error as? NSError {
                    print("InsertError: \(error)")
                } else if let single_movie = task.result as? SingleMovie {
                    // put all the matched user ids to matchedUserIDs array
                    for likedUsers in single_movie.currentLikedUser
                    {
                        // if the id is not the user him/herself, add it to list
                        if (likedUsers != key && !matchedUserIDs.contains(likedUsers))
                        {
                            matchedUserIDs.append(likedUsers)
                        }
                    }
                }
                dummynum = 6
                return nil
            }).waitUntilFinished()
//            while (dummynum != 6)
//            {
//                waiting = 1
//            }
        }
        print("getPotentialUserIDs SUCCESS")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return matchedUserIDs
    }
    
    //JUNPU: async dependency in the code, busy waiting still exist
    //JUNPU: Tried but did not fix. I'll come back to this
    func getUserProfileByIds(userIDs: [String]) -> [UserProfileToDB]
    {
        print("===== getUserProfileByIds =====")
        var matchedUserProfiles: Array = [UserProfileToDB]()
        let mapper = AWSDynamoDBObjectMapper.default()
        var dummynum: Int = 0
        
        for userID in userIDs
        {
            /*
            //test create chat room (create current->recipient & recipient->current pair of chat rooms)
            ChatRoomModel().createChatRoom(recipient: userID)
 
            //test get list of chatroom of current user
            let test_get = ChatRoomModel().getChatRoomList()
            print(test_get.description)
            
            //test sort by time stamp
            let sorted = ChatRoomModel().sortByTime(roomList: test_get)
            print(sorted.description)
            
            
            //test get chatroom id when specifying sender and recipient
            let test_getRoomId = ChatRoomModel().getChatRoomId(userId: AWSIdentityManager.default().identityId!, recipientId: userID)
            print(test_getRoomId)
 
            //test update latest activity time of chatroom
            let test_room = ChatRoomModel().getSingleChatRoom(userId: AWSIdentityManager.default().identityId!, recipientId: userID)
            //print(test_room.description);
            test_room.updateTimeStamp();
            */
            
            dummynum = 0
            print("userid is \(userID)")
            mapper.load(UserProfileToDB.self, hashKey: userID, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
                if let error = task.error as NSError? {
                    print("InsertError: \(error)")
                }
                else if let userProfile = task.result as? UserProfileToDB {
                    dummynum = 0
                    matchedUserProfiles.append(userProfile)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                dummynum = 6
                return nil
            }).waitUntilFinished()
//            var waiting = 0
//            while (dummynum != 6)
//            {
//                waiting = 1
//            }
        }
        print("getUserProfileByIds SUCCESS")
        return matchedUserProfiles
    }
    
    func getAllUserIDs() -> [String]
    {
        print("===== getAllUserIDs =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        var allUserIDs: Array = [String]()
        var dummynum: Int = 0
        mapper.scan(UserProfileToDB.self, expression: scanExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let user_profile = task.result {
                for item in user_profile.items as! [UserProfileToDB] {
                    allUserIDs.append(item.userId!)
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //self.tableView.reloadData()
            if let error = task.error as NSError? {
                print("Error: \(error)")
                
            }
            dummynum = 6
            return nil
        }).waitUntilFinished()
//        var wait = 0
//        while (dummynum != 6)
//        {
//            wait = 1
//        }
        return allUserIDs
    }
    
    //JUNPU: let it busy waiting for now
    func likeOneUser(key: String, likedUserID: String)
    {
        print("===== likeOneUser =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        let userProfile = UserProfileToDB()
        var dummynum: Int = 0
        
//        print("     before load!!")
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                userProfile?.userId=key
//                print("     key is \(key)")
                userProfile?.displayName = user_profile_addTo.displayName
//                print("displayname is \(userProfile?.displayName)")
                userProfile?.bio = user_profile_addTo.bio
//                print("bio is \(userProfile?.bio)")
                userProfile?.age = user_profile_addTo.age
//                print("age is \(userProfile?.age)")
                userProfile?.gender = user_profile_addTo.gender
//                print("gender is \(userProfile?.gender)")
                userProfile?.region = user_profile_addTo.region
//                print("region is \(userProfile?.region)")
                
                userProfile?.device=user_profile_addTo.device
                
                userProfile?.currentLikedMovie=user_profile_addTo.currentLikedMovie
                // if the user does not have any liked movies
                if (user_profile_addTo.currentLikedMovie.count == 0)
                {
                    userProfile?.currentLikedMovie.insert("mushroom13")
                }
                userProfile?.likedUsers = user_profile_addTo.likedUsers
                if (user_profile_addTo.likedUsers.count == 0)
                {
                    userProfile?.likedUsers.insert("mushroom13")
                }
                userProfile?.matchedUsers = user_profile_addTo.matchedUsers
                if (user_profile_addTo.matchedUsers.count == 0)
                {
                    userProfile?.matchedUsers.insert("mushroom13")
                }
                userProfile?.movieCount = user_profile_addTo.movieCount
                
                userProfile?.email = user_profile_addTo.email
        
            }
            dummynum = 6
            return nil
        }).waitUntilFinished()
        
//        var waiting = 0
//        while (dummynum != 6)
//        {
//            waiting = 1
//        }
        

//        print("SHOULD BE AFTER LOAD: displayname is \(userProfile?.displayName)")
        if (!((userProfile?.likedUsers.contains(likedUserID))!))
        {
            if (userProfile?.likedUsers.count == 1 && (userProfile?.likedUsers.contains("mushroom13"))!) {
                //dummy exist
                userProfile?.likedUsers.removeAll()
            }
            userProfile?.likedUsers.insert(likedUserID)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        mapper.save(userProfile!)
        print("likeOneUser SUCCESS")
    }
    
    
    //JUNPU: seems to fixed the busy waiting, more testing is required
    //JUNPU: Tried but did not fix. I'll come back to this
    func getLikedUserIDs(key: String) -> [String]
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("===== getLikedUserIDs =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var likedUserArr = Set<String>()
        var likedUserIDs: Array = [String]()
        var dummynum: Int = 0
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil).continueWith(executor: AWSExecutor.immediate(), block: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            }
            else if let user_profile = task.result as? UserProfileToDB {
                likedUserArr = user_profile.likedUsers
            }

            dummynum = 6
            return nil
        }).waitUntilFinished()
        
//        var waiting = 0
//        while (dummynum == 0)
//        {
//            waiting = 1
//        }
        for user in likedUserArr
        {
            likedUserIDs.append(user)
        }
    
        print(likedUserIDs)
        print("getLikedUserIDs SUCCESS")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return likedUserIDs
    }
    
    func getMatchedUserIDs(key: String) -> [String]
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("===== getMatchedUserIDs =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var matchedUserArr = Set<String>()
        var matchedUserIDs: Array = [String]()
        var dummynum: Int = 0
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil).continueWith(executor: AWSExecutor.immediate(), block: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            }
            else if let user_profile = task.result as? UserProfileToDB {
                matchedUserArr = user_profile.matchedUsers
            }
            
            dummynum = 6
            return nil
        }).waitUntilFinished()
        
//        var waiting = 0
//        while (dummynum == 0)
//        {
//            waiting = 1
//        }
        for user in matchedUserArr
        {
            matchedUserIDs.append(user)
        }
        
        print(matchedUserIDs)
        print("getMatchedUserIDs SUCCESS")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return matchedUserIDs
    }
    
    // Call this twice!
    // 1st: (your id, other's id)
    // 2nd: (other's id, your id)
    // if both true, then there is a match
    //JUNPU: async dependency in the code, busy waiting still exist
    func findIsMatched(key: String, userID: String) -> Bool
    {
        print("===== findIsMatched =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var result: Bool = false
        var dummynum: Int = 0
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            } else if let user_profile = task.result as? UserProfileToDB {
                if (user_profile.likedUsers.contains(userID))
                {
                    result = true
                }
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            dummynum = 6
            return nil
        }).waitUntilFinished()
        
//        var waiting = 0
//        while (dummynum == 0)
//        {
//            waiting = 1
//        }
        print("findIsMatched SUCCESS. result = \(result)")
        return result
    }
    
    //JUNPU: fixed busy waiting
    func insertToMatchedUser(key: String, userID: String)
    {
        print("===== insertToMatchedUser =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        let userProfile = UserProfileToDB()
        
//        print("     before load!!")
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                userProfile?.userId=key
//                print("     key is \(key)")
                userProfile?.displayName = user_profile_addTo.displayName
//                print("displayname is \(userProfile?.displayName)")
                userProfile?.bio = user_profile_addTo.bio
//                print("bio is \(userProfile?.bio)")
                userProfile?.age = user_profile_addTo.age
//                print("age is \(userProfile?.age)")
                userProfile?.gender = user_profile_addTo.gender
//                print("gender is \(userProfile?.gender)")
                userProfile?.region = user_profile_addTo.region
//                print("region is \(userProfile?.region)")
                
                userProfile?.device=user_profile_addTo.device
                
                userProfile?.currentLikedMovie = user_profile_addTo.currentLikedMovie
                if (user_profile_addTo.currentLikedMovie.count == 0)
                {
                    userProfile?.currentLikedMovie.insert("mushroom13")
                }
                userProfile?.likedUsers = user_profile_addTo.likedUsers
                if (user_profile_addTo.likedUsers.count == 0)
                {
                    userProfile?.likedUsers.insert("mushroom13")
                }
                userProfile?.matchedUsers = user_profile_addTo.matchedUsers
                if (user_profile_addTo.matchedUsers.count == 0)
                {
                    userProfile?.matchedUsers.insert("mushroom13")
                }
                for movie in (userProfile?.currentLikedMovie)! {
                    print("\(movie)")
                }
                userProfile?.movieCount = user_profile_addTo.movieCount
                userProfile?.email = user_profile_addTo.email
                
                ///////////////////////////////////
//                print("SHOULD BE AFTER LOAD: displayname is \(userProfile?.displayName)")
                if (!((userProfile?.matchedUsers.contains(userID))!))
                {
                    if (userProfile?.matchedUsers.count != 0 && (userProfile?.matchedUsers.contains("mushroom13"))!) {
                        //dummy exist
                        print("dummy here")
                        userProfile?.matchedUsers.removeAll()
                    }
                    userProfile?.matchedUsers.insert(userID)
                }
                mapper.save(userProfile!)
                print("insertToMatchedUser SECCESS")
                
            
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })

    }
    
    func deleteFromMatch(key: String, matchId: String)
    {
        //delete chatroom
        let room1 = ChatRoomModel().getChatRoomId(userId: key, recipientId: matchId)
        let room2 = ChatRoomModel().getChatRoomId(userId: key, recipientId: matchId)
        ChatRoomModel().deleteRoom(roomId: room1)
        ChatRoomModel().deleteRoom(roomId: room2)
        //ConversationModel().delete
        print("===== deleteFromMatch =====")
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let userProfile = UserProfileToDB()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("loadError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                userProfile?.userId=key
                userProfile?.displayName = user_profile_addTo.displayName
                userProfile?.bio = user_profile_addTo.bio
                userProfile?.age = user_profile_addTo.age
                userProfile?.gender = user_profile_addTo.gender
                userProfile?.region = user_profile_addTo.region
                userProfile?.device=user_profile_addTo.device
                userProfile?.likedUsers = user_profile_addTo.likedUsers
                if (user_profile_addTo.likedUsers.count == 0)
                {
                    userProfile?.likedUsers.insert("mushroom13")
                }
                userProfile?.matchedUsers = user_profile_addTo.matchedUsers
                if (user_profile_addTo.matchedUsers.count == 0)
                {
                    userProfile?.matchedUsers.insert("mushroom13")
                }
                userProfile?.currentLikedMovie=user_profile_addTo.currentLikedMovie
                userProfile?.movieCount = user_profile_addTo.movieCount
                userProfile?.email = user_profile_addTo.email

                if (!((userProfile?.matchedUsers.contains(matchId))!))
                {
                    print("error: delete a user not in user's matched list")
                }
                else {
                    _ = userProfile?.likedUsers.remove(matchId)
                    //userProfile?.movieCount = userProfile?.currentLikedMovie.count as NSNumber?
                    //dummy string since empty string set not allowed
                    if (userProfile?.matchedUsers.count == 0) {
                        userProfile?.currentLikedMovie.insert("mushroom13")
                    }
                }

                mapper.save(userProfile!)
                print("deleteFrom match SUCCESS")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
    }

    func downloadUserIcon(userID: String) -> URL
    {
        print("===== downloadUserIcon =====")
        let transferManager = AWSS3TransferManager.default()
//        print("downloading pic for \(userID)")
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(userID)
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = "testprofile-meetzam"
        downloadRequest?.key = userID + ".jpeg"
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("download Error: \(error)")
                return nil
            } else {
                print("downloadUserIcon SUCCESS")
            }
            return nil
        })
        return downloadingFileURL // possible error, downloadingFileURL dependent on async operation, this return statement might returnning null.
    }
 
    //mushroom
    func getDeviceArn() -> String? {
        
        let pushManager = AWSPushManager()
        
        if let _endpointARN = pushManager.endpointARN {
            // pushManager.enabled = true
            return _endpointARN
        }else{
            print("failed to get endpoint arn")
            pushManager.registerForPushNotifications()
        }
        return nil
    }
    
    
}
