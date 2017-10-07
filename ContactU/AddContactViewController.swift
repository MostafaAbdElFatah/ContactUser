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
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "ChooseImage:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.imageCon.addGestureRecognizer(tapGestureRecognizer)
        self.imageCon.userInteractionEnabled = true
    }
    
    @IBAction func Done_addContact(sender: UIBarButtonItem) {
        if self.firstName.text == "" || self.lastName.text == "" || self.emailCon.text == "" || self.phoneCon.text == ""{
            
            let useralter = UIAlertController(title: "Please Fill Whole Date", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            useralter.addAction(OkAction)
            self.presentViewController(useralter, animated:true, completion: nil)
            
        }else{
            let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDeleg.managedObjectContext
            let newContact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context)
            newContact.setValue(self.firstName.text,forKey: "firstName")
            newContact.setValue(self.lastName.text, forKey: "lastName")
            newContact.setValue(self.emailCon.text, forKey: "email")
            newContact.setValue(self.phoneCon.text, forKey: "phone")
            newContact.setValue("\(NSDate())", forKey: "dateID")
            let contactimage:NSData = UIImagePNGRepresentation(self.imageCon.image!)!
            newContact.setValue(contactimage , forKey: "image")
            do{
                try context.save()
            }catch{
                print("error in saving data")
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func ChooseImage(recognizer:UITapGestureRecognizer){
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imageinfo:NSDictionary = info as NSDictionary
        let pickedImage:UIImage = imageinfo.objectForKey(UIImagePickerControllerOriginalImage) as! UIImage
        let smallPicture = scaleImageWith(pickedImage, newSize:CGSizeMake(100,100))
        var sizeOfImageView:CGRect = self.imageCon.frame
        sizeOfImageView.size = smallPicture.size
        self.imageCon.frame = sizeOfImageView
        self.imageCon.image = smallPicture
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scaleImageWith(image:UIImage,newSize:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}
