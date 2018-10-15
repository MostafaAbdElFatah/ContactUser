//
//  AddContactViewController.swift
//  ContactU
//
//  Created by Mostafa on 7/19/17.
//  Copyright © 2017 Mostafa. All rights reserved.
//

import UIKit
import CoreData

class AddContactViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailCon: UITextField!
    @IBOutlet weak var phoneCon: UITextField!
    @IBOutlet weak var imageCon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddContactViewController.ChooseImage(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.imageCon.addGestureRecognizer(tapGestureRecognizer)
        self.imageCon.isUserInteractionEnabled = true
    }
    
    @IBAction func Done_addContact(_ sender: UIBarButtonItem) {
        if self.firstName.text == "" || self.lastName.text == "" || self.emailCon.text == "" || self.phoneCon.text == ""{
            
            let useralter = UIAlertController(title: "Please Fill Whole Date", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            useralter.addAction(OkAction)
            self.present(useralter, animated:true, completion: nil)
            
        }else{
            let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDeleg.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Contact", in: context)
            let newContact = NSManagedObject(entity: entity!, insertInto: context)
            newContact.setValue(self.firstName.text,forKey: "firstName")
            newContact.setValue(self.lastName.text, forKey: "lastName")
            newContact.setValue(self.emailCon.text, forKey: "email")
            newContact.setValue(self.phoneCon.text, forKey: "phone")
            newContact.setValue("\(NSDate())", forKey: "dateID")
            let contactimage:Data = UIImagePNGRepresentation(self.imageCon.image!)!
            newContact.setValue(contactimage , forKey: "image")
            do{
                try context.save()
            }catch{
                print("error in saving data")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func ChooseImage(_ recognizer:UITapGestureRecognizer){
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageinfo:NSDictionary = info as NSDictionary
        let pickedImage:UIImage = imageinfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        let smallPicture = scaleImageWith(image: pickedImage, newSize:CGSize(width: 100,height: 100))
        var sizeOfImageView:CGRect = self.imageCon.frame
        sizeOfImageView.size = smallPicture.size
        self.imageCon.frame = sizeOfImageView
        self.imageCon.image = smallPicture
        picker.dismiss(animated: true, completion: nil)
    }
    
    func scaleImageWith(image:UIImage,newSize:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
