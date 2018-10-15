//
//  ContactTableViewController.swift
//  ContactU
//
//  Created by Mostafa on 7/19/17.
//  Copyright © 2017 Mostafa. All rights reserved.
//

import UIKit
import CoreData

protocol ContactSelectionDelegate{
    func userDidSelectContact(contactDate:String)
}

class ContactsTableViewController: UITableViewController{
    
    var yourContact:NSMutableArray = NSMutableArray()
    var delegate:ContactSelectionDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    func loadData(){
        
        yourContact.removeAllObjects()
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
            let results = try context.fetch(request)
            for contact in results as! [NSManagedObject]{
                let firstname = contact.value(forKey: "firstName") as! String
                let lastname  = contact.value(forKey: "lastName") as! String
                let email  = contact.value(forKey: "email") as! String
                let phone  = contact.value(forKey: "phone") as! String
                let dateCon  = contact.value(forKey: "dateID") as! String
                let imageCon  = contact.value(forKey: "image") as! NSData
                let singleContact:NSDictionary = ["firstName":firstname,"lastName":lastname,"email":email,"phone":phone,"date":dateCon,"image":imageCon]
                self.yourContact.add(singleContact)
            }
            self.tableView.reloadData()
        }catch{
            print("error in fetching data")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.yourContact.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ContactTableViewCell
        let singleContact:NSDictionary = self.yourContact.object(at: indexPath.row) as! NSDictionary
        let firstname = singleContact.object(forKey: "firstName") as! String
        let lastname  = singleContact.object(forKey: "lastName")  as! String
        let email     = singleContact.object(forKey: "email")     as! String
        let phone     = singleContact.object(forKey: "phone")     as! String
        let imageCon  = singleContact.object(forKey: "image")     as! Data
        cell.nameContact.text  = firstname + " " + lastname
        cell.phoneContact.text = phone
        cell.emailContact.text = email
        let imageContact:UIImage = UIImage(data: imageCon)!
        var imageFrameContact:CGRect = cell.imageContact.frame
        imageFrameContact.size = CGSize(width: 100, height: 90)
        cell.imageContact.frame = imageFrameContact
        cell.imageContact.image = imageContact
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        if (delegate  != nil){
            let contactDic:NSDictionary = self.yourContact.object(at: indexPath.row)
             as! NSDictionary
            delegate?.userDidSelectContact(contactDate: contactDic.object(forKey: "date") as! String )
            self.navigationController?.popViewController(animated: true)
        }else
        {
            print("delegate id nil")
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if self.yourContact.count > 0 {
                let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let context:NSManagedObjectContext = appDeleg.managedObjectContext
                let contactdic:NSDictionary = self.yourContact.object(at: indexPath.row) as! NSDictionary
                let dateid:String = contactdic.object(forKey: "date") as! String
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
                request.predicate = NSPredicate(format: "dateID == '\(dateid)'")
                do{
                    let results = try context.fetch(request) as! [NSManagedObject]
                    context.delete(results[0])
                    try context.save()
                    self.yourContact.removeAllObjects()
                    self.loadData()
                    tableView.reloadData()
                }catch{print("ERROR in Deleting")}
                
            }
        }
    }
    

   
}
