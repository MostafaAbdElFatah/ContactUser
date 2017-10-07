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
    func userDidSelectContact(contactDate:NSString)
}

class ContactsTableViewController: UITableViewController{
    
    var yourContact:NSMutableArray = NSMutableArray()
    var delegate:ContactSelectionDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    func loadData(){
        
        yourContact.removeAllObjects()
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        
        do{
            let request = NSFetchRequest(entityName: "Contact")
            let results = try context.executeFetchRequest(request)
            for contact in results{
                let firstname = contact.valueForKey("firstName") as! String
                let lastname  = contact.valueForKey("lastName") as! String
                let email  = contact.valueForKey("email") as! String
                let phone  = contact.valueForKey("phone") as! String
                let dateCon  = contact.valueForKey("dateID") as! String
                let imageCon  = contact.valueForKey("image") as! NSData
                let singleContact:NSDictionary = ["firstName":firstname,"lastName":lastname,"email":email,"phone":phone,"date":dateCon,"image":imageCon]
                self.yourContact.addObject(singleContact)
            }
            self.tableView.reloadData()
        }catch{
            print("error in fetching data")
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.yourContact.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ContactTableViewCell
        let singleContact:NSDictionary = self.yourContact.objectAtIndex(indexPath.row) as! NSDictionary
        let firstname = singleContact.objectForKey("firstName") as! String
        let lastname  = singleContact.objectForKey("lastName")  as! String
        let email     = singleContact.objectForKey("email")     as! String
        let phone     = singleContact.objectForKey("phone")     as! String
        let imageCon  = singleContact.objectForKey("image")     as! NSData
        cell.nameContact.text  = firstname + " " + lastname
        cell.phoneContact.text = phone
        cell.emailContact.text = email
        let imageContact:UIImage = UIImage(data: imageCon)!
        var imageFrameContact:CGRect = cell.imageContact.frame
        imageFrameContact.size = CGSizeMake(100, 90)
        cell.imageContact.frame = imageFrameContact
        cell.imageContact.image = imageContact
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        if (delegate  != nil){
            let contactDic:NSDictionary = self.yourContact.objectAtIndex(indexPath.row)
             as! NSDictionary
            delegate?.userDidSelectContact(contactDic.objectForKey("date") as! NSString)
            self.navigationController?.popViewControllerAnimated(true)
        }else
        {
            print("delegate id nil")
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            if self.yourContact.count > 0 {
                let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDeleg.managedObjectContext
                let contactdic:NSDictionary = self.yourContact.objectAtIndex(indexPath.row) as! NSDictionary
                let dateid:NSString = contactdic.objectForKey("date") as! NSString
                let request = NSFetchRequest(entityName: "Contact")
                request.predicate = NSPredicate(format: "dateID == '\(dateid)'")
                do{
                    let results = try context.executeFetchRequest(request)
                    context.deleteObject(results[0] as! NSManagedObject)
                    try context.save()
                    self.yourContact.removeAllObjects()
                    self.loadData()
                    tableView.reloadData()
                }catch{print("ERROR in Deleting")}
                
            }
        }
    }

   
}
