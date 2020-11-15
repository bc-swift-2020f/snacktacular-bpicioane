//
//  PhotoViewController.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/14/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PhotoViewController: UIViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    var spot: Spot!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else {
            print("L. no spot passed.")
            return
        }
        if photo == nil {
            photo = Photo()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        postedByLabel.text = "by: \(photo.photoUserEmail)"
        dateLabel.text = "on: \(dateFormatter.string(from: photo.date))"
        descriptionTextView.text = photo.description
        photoImageView.image = photo.image
        
        
        if photo.documentID == "" {
            addBordersToEditableObjects()
        } else {
            if photo.photoUserID == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                self.navigationController?.setToolbarHidden(false, animated: true)
            } else {
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted by: \(photo.photoUserEmail)"
                descriptionTextView.isEditable = false
                descriptionTextView.backgroundColor = .white
            }
        }
    }
    
    func updateFromInterface() {
        photo.description = descriptionTextView.text!
        photo.image = photoImageView.image!
    }
    
    func addBordersToEditableObjects() {
        descriptionTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        photo.saveData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("L. can't unwind segue because of photo saving error.")
            }
        }
    }
    
}
