//
//  AlarmViewController.swift
//  Alarmadillo
//
//  Created by Tanner Quesenberry on 3/26/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import UIKit

class AlarmViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var name: UITextField!
    @IBOutlet var caption: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tapToSelectImage: UILabel!
    
    var alarm: Alarm!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = alarm.name
        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time
        
        if alarm.image.count > 0 {
            //if there is an image
            let imageFilename = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            imageView.image = UIImage(contentsOfFile: imageFilename.path)
            tapToSelectImage.isHidden = true
        }
        
    }
    
    //Update alarm data with user entered info
    func textFieldDidEndEditing(_ textField: UITextField) {
        alarm.name = name.text!
        alarm.caption = caption.text!
        title = alarm.name
    }
    
    //Get rid of keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Set alarm's time
    @IBAction func datePickerChanged(_ sender: Any) {
        alarm.time = datePicker.date
    }
    
    //Allow user to pick image when tap gesture recognizer is triggered
    @IBAction func imageViewTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        present(vc, animated: true)
    }
    
    //After image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //dismiss image picker
        dismiss(animated: true)
        
        //fetch picked image
        guard let image = info[.originalImage] as? UIImage else { return }
        let fm = FileManager()
        
        if alarm.image.count > 0 {
            //if alarm has image already, delete it
            do {
                let currentImage = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
                if fm.fileExists(atPath: currentImage.path) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
        }
        
        do {
            //generate a new filename for the image
            alarm.image = "\(UUID().uuidString).jpg"
            
            //write new image to documents directory
            let newPath = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            let jpeg = image.jpegData(compressionQuality: 0.8)
            try jpeg?.write(to: newPath)
        } catch {
            print("Failed to save new image")
        }
        
        //update user interface
        imageView.image = image
        tapToSelectImage.isHidden = true
    }

}
