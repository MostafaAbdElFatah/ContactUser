//
//  ViewController.swift
//  ContactU
//
//  Created by Mostafa on 7/19/17.
//  Copyright © 2017 Mostafa. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController,ContactSelectionDelegate {
    
    
    var pickedDate:NSDate = NSDate()
    var dateid:NSString?  = nil
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var imageContact: UIImageView!
    @IBOutlet weak var notelabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameLabel.text = "Your"
        self.lastNameLabel.text  = "Contact"
    }

    @IBAction func DatePickerVaueChange(sender: UIDatePicker) {
        self.pickedDate = sender.date
    }
    
    func userDidSelectContact(contactDate: NSString) {
        self.dateid = contactDate
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest(entityName: "Contact")
        request.predicate = NSPredicate(format: "dateID == '\(contactDate)'")
        
        do{
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                self.firstNameLabel.text = results[0].valueForKey("firstName") as? String
                self.lastNameLabel.text  = results[0].valueForKey("lastName") as? String
                let imageCon  = results[0].valueForKey("image") as! NSData
                let imageContact:UIImage = UIImage(data: imageCon)!
                var imageFrameContact:CGRect = self.imageContact.frame
                imageFrameContact.size = CGSizeMake(100, 85)
                self.imageContact.frame = imageFrameContact
                self.imageContact.image = imageContact
            }
            
        }catch{
            print("error in fetching data")
        }

    }
    
    @IBAction func Done_btnClicked(sender: UIBarButtonItem) {
        if self.firstNameLabel.text == "" || self.lastNameLabel.text == "" || self.notelabel.text == ""{
            
            let useralter = UIAlertController(title: "Please Fill Whole text Field", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            useralter.addAction(OkAction)
            self.presentViewController(useralter, animated:true, completion: nil)
            
        }else if self.dateid == nil{
            
            let useralter = UIAlertController(title: "Please Select Contact", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            useralter.addAction(OkAction)
            self.presentViewController(useralter, animated:true, completion: nil)

        }else{
            let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDeleg.managedObjectContext
            let newContact = NSEntityDescription.insertNewObjectForEntityForName("ToDoItem", inManagedObjectContext: context)
            newContact.setValue(self.dateid,forKey: "dateID")
            newContact.setValue(self.notelabel.text, forKey: "note")
            newContact.setValue(self.pickedDate, forKey: "dueDate")
            do{
                try context.save()
            }catch{
                print("error in saving data")
            }
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "contactSegue"{
            let viewController:ContactsTableViewController = segue.destinationViewController as! ContactsTableViewController
            viewController.delegate = self
        }
    }
    
}

