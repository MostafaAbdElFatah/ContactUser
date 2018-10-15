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
    
    
    var pickedDate:Date = Date()
    var dateid:String?
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var imageContact: UIImageView!
    @IBOutlet weak var notelabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameLabel.text = "Your"
        self.lastNameLabel.text  = "Contact"
    }

    @IBAction func DatePickerVaueChange(_ sender: UIDatePicker) {
        self.pickedDate = sender.date as Date
    }
    
    func userDidSelectContact(contactDate: String) {
        self.dateid = contactDate
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        request.predicate = NSPredicate(format: "dateID == '\(contactDate)'")
        
        do{
            let results = try context.fetch(request) as! [NSManagedObject]
            if results.count > 0 {
                self.firstNameLabel.text = results[0].value(forKey: "firstName") as? String
                self.lastNameLabel.text  = results[0].value(forKey: "lastName") as? String
                let imageCon  = results[0].value(forKey: "image") as! Data
                let imageContact:UIImage = UIImage(data: imageCon)!
                var imageFrameContact:CGRect = self.imageContact.frame
                imageFrameContact.size = CGSize(width: 100, height: 85)
                self.imageContact.frame = imageFrameContact
                self.imageContact.image = imageContact
            }
            
        }catch{
            print("error in fetching data")
        }

    }
    
    @IBAction func Done_btnClicked(_ sender: UIBarButtonItem) {
        if self.firstNameLabel.text == "" || self.lastNameLabel.text == "" || self.notelabel.text == ""{
            
            let useralter = UIAlertController(title: "Please Fill Whole text Field", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            useralter.addAction(OkAction)
            self.present(useralter, animated:true, completion: nil)
            
        }else if self.dateid == nil{
            
            let useralter = UIAlertController(title: "Please Select Contact", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let OkAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            useralter.addAction(OkAction)
            self.present(useralter, animated:true, completion: nil)

        }else{
            let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDeleg.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName:  "ToDoItem", in: context)
            let newContact = NSManagedObject(entity: entity!, insertInto: context)
            newContact.setValue(self.dateid,forKey: "dateID")
            newContact.setValue(self.notelabel.text, forKey: "note")
            newContact.setValue(self.pickedDate, forKey: "dueDate")
            do{
                try context.save()
            }catch{
                print("error in saving data")
            }
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSegue"{
            let viewController:ContactsTableViewController = segue.destination as! ContactsTableViewController
            viewController.delegate = self
        }
    }
  
}

