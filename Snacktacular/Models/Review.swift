//
//  Review.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/8/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import Foundation
import Firebase

class Review {
    
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var reviewUserEmail: String
    var date: Date
    var documentID: String

    var dictionary: [String : Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title" : title, "text" : text, "rating" : rating, "reviewUserID" : reviewUserID, "reviewUserEmail" : reviewUserEmail, "date" : timeIntervalDate]
    }
    
    init(title: String, text: String, rating: Int, reviewUserID: String, reviewUserEmail: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.reviewUserEmail = reviewUserEmail
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        let reviewUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(title: "", text: "", rating: 0, reviewUserID: reviewUserID, reviewUserEmail: reviewUserEmail, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String : Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let reviewUserEmail = dictionary["reviewUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(title: title, text: text, rating: rating, reviewUserID: reviewUserID, reviewUserEmail: reviewUserEmail, date: date, documentID: documentID)
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let dataToSave: [String : Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("L. error making doc. \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("W. added document \(self.documentID) to spot: \(spot.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        } else {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("L. error updating doc. \(error!.localizedDescription)")
                    return completion(false)
                }
                print("W. updated document \(self.documentID) in spot: \(spot.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete { (error) in
            if let error = error {
                print("L. couldn't delete review documentID: \(self.documentID), error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("W. successfully deleted document \(self.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
    }
}
