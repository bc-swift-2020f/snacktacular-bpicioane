//
//  Photo.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/14/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import UIKit
import Firebase

class Photo {
    
    var image: UIImage
    var description: String
    var photoUserID: String
    var photoUserEmail: String
    var date: Date
    var photoURL: String
    var documentID: String
    
    var dictionary: [String : Any] {
           let timeIntervalDate = date.timeIntervalSince1970
           return ["description" : description, "photoUserID" : photoUserID, "photoUserEmail" : photoUserEmail, "date" : timeIntervalDate, "photoURL" : photoURL]
       }
    
    init(image: UIImage, description: String, photoUserID: String, photoUserEmail: String, date: Date, photoURL: String, documentID: String) {
        self.image = image
        self.description = description
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.date = date
        self.photoURL = photoURL
        self.documentID = documentID
    }
       
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(image: UIImage(), description: "", photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: Date(), photoURL: "", documentID: "")
    }
       
    convenience init(dictionary: [String : Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        self.init(image: UIImage(), description: description, photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: date, photoURL: photoURL, documentID: "")
       }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        // convert photo.image to data type
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("L. couldn't convert photo.image to data.")
            return
        }
        // create metadata
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        // create filename if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        //create storage ref
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        //create upload task
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetadata) { (metadata, error) in
            if let error = error {
                print("L. upload for ref \(uploadMetadata) failed. \(error.localizedDescription)")
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            print("upload to firebase storage successful")
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("L. couldn't create image url. \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("L. this should never happen. ")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                let dataToSave = self.dictionary
                let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("L. error updating doc. \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("W. updated document \(self.documentID) in spot: \(spot.documentID)")
                    completion(true)
                }
            }
        }
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("L. upload for file \(self.documentID) to firebase storage failed in spot \(spot.documentID). \(error.localizedDescription)")
            }
            completion(false)
        }
        
        
    }
    
    func loadImage(spot: Spot, completion: @escaping (Bool) -> ()) {
        guard spot.documentID != "" else {
            print("L. didn't pass a valid spot into photo image")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("L. an error occured when reading data from file ref: \(storageRef). error: \(error.localizedDescription)")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("photos").document(documentID).delete { (error) in
            if let error = error {
                print("L. couldn't delete photo documentID: \(self.documentID), error: \(error.localizedDescription)")
                completion(false)
            } else {
                self.deleteImage(spot: spot)
                print("W. successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
    
    private func deleteImage(spot: Spot) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        storageRef.delete { error in
            if let error = error {
                print("L. couldn't delete photo error: \(error.localizedDescription)")
            } else {
                print("photo deleted")
            }
        }
    }
    
    
}
