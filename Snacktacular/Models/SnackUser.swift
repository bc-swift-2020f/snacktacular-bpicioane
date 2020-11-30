//
//  SnackUser.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/30/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import Foundation
import Firebase

class SnackUser {
    
    var email: String
    var displayName: String
    var photoURL: String
    var userSince: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["email": email, "displayName": displayName, "photoURL": photoURL, "userSince": timeIntervalDate]
    }
    
    init(email: String, displayName: String, photoURL: String, userSince: Date, documentID: String) {
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.userSince = userSince
        self.documentID = documentID
    }
    
    convenience init(user: User) {
        let email = user.email ?? ""
        let displayName = user.displayName ?? ""
        let photoURL = user.photoURL != nil ? "\(user.photoURL!)" : ""
        self.init(email: email, displayName: displayName, photoURL: photoURL, userSince: Date(), documentID: user.uid)
    }
    
    convenience init(dict: [String: Any]) {
        let email = dict["email"] as! String? ?? ""
        let displayName = dict["displayName"] as! String? ?? ""
        let photoURL = dict["photoURL"] as! String? ?? ""
        let timeIntervalDate = dict["userSince"] as! TimeInterval? ?? TimeInterval()
        let userSince = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(email: email, displayName: displayName, photoURL: photoURL, userSince: userSince, documentID: "")
    }
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(documentID)
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("L. Couldn't access doc.")
                return completion(false)
            }
            guard document?.exists == false else {
                print("The doc already exists.")
                return completion(true)
            }
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(self.documentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("L. Couldn't save doc.")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
}