//
//  ListCallTableViewController.swift
//  ContactU
//
//  Created by Mostafa on 7/19/17.
//  Copyright © 2017 Mostafa. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class ListCallTableViewController: UITableViewController , MFMessageComposeViewControllerDelegate , MFMailComposeViewControllerDelegate{
    
    
    var yourContact:NSMutableArray = NSMutableArray()
    var ToDoItem:NSMutableArray = NSMutableArray()
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
            let request = NSFetchRequest(entityName: "ToDoItem")
            let results = try context.executeFetchRequest(request)
            for contact in results{
                let dateid = contact.valueForKey("dateID")    as! NSString
                let note  = contact.valueForKey("note")       as! String
                let dueDate  = contact.valueForKey("dueDate") as! NSDate
                let singleContact:NSDictionary = ["dateid":dateid,"note":note,"duedate":dueDate]
                self.yourContact.addObject(singleContact)
            }
            let dateSort:NSSortDescriptor = NSSortDescriptor(key: "duedate", ascending: true)
            let sortedArray:NSArray = self.yourContact.sortedArrayUsingDescriptors([dateSort])
            self.yourContact = NSMutableArray(array: sortedArray)
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
    
    
    func fetchdateid(dateid:NSString)->NSDictionary?{
        
        var contactDic:NSDictionary? = nil
        
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest(entityName: "Contact")
        request.predicate = NSPredicate(format: "dateID == '\(dateid)'")
        
        do{
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                let firstname = results[0].valueForKey("firstName") as! String
                let lastname  = results[0].valueForKey("lastName")  as! String
                let email     = results[0].valueForKey("email")     as! String
                let phone     = results[0].valueForKey("phone")     as! String
                let dateCon   = results[0].valueForKey("dateID")    as! String
                let imageCon  = results[0].valueForKey("image")     as! NSData
                contactDic = ["firstName":firstname,"lastName":lastname,"email":email
                    ,"phone":phone,"date":dateCon,"image":imageCon]
            }
            
        }catch{
            print("error in fetching data")
        }
        return contactDic
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ListCallTableViewCell = tableView.dequeueReusableCellWithIdentifier("CallCell", forIndexPath: indexPath) as! ListCallTableViewCell
        let singleContact:NSDictionary = self.yourContact.objectAtIndex(indexPath.row) as! NSDictionary
        var contact:NSDictionary? = nil
        let dataidContact:NSString = singleContact.objectForKey("dateid") as! NSString
        contact = fetchdateid(dataidContact)
        let note    =  singleContact.objectForKey("note")       as! String
        let dueDate =  singleContact.objectForKey("duedate")    as! NSDate
        if contact != nil{
            self.ToDoItem.addObject(contact!)
            let firstname = contact!.objectForKey("firstName") as! String
            let lastname  = contact!.objectForKey("lastName")  as! String
            let imageCon  = contact!.objectForKey("image")     as! NSData
            cell.namelabel.text    = firstname + " " + lastname
            // set image
            let imageContact:UIImage = UIImage(data: imageCon)!
            var imageFrameContact:CGRect = cell.imageContact.frame
            imageFrameContact.size = CGSizeMake(75,75)
            cell.imageContact.frame = imageFrameContact
            cell.imageContact.image = imageContact
            
            cell.noteLabel.text    = note
            // set date
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM dd"
            let dateString:String = dateFormatter.stringFromDate(dueDate)
            cell.dueDateLabel.text  = dateString
            // set btns event and data
            cell.Callbtn.tag = indexPath.row
            cell.Textbtn.tag = indexPath.row
            cell.mailbtn.tag = indexPath.row
            
            cell.Callbtn.addTarget(self, action: "Call_btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.Textbtn.addTarget(self, action: "Text_btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.mailbtn.addTarget(self, action: "Mail_btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        return cell
    }
    
    func Call_btnClicked(sender:UIButton){
        let contactdic:NSDictionary = self.ToDoItem.objectAtIndex(sender.tag) as! NSDictionary
        let phoneNumber:NSString = contactdic.objectForKey("phone") as! NSString
        UIApplication.sharedApplication().openURL( NSURL(string: "telprompt://\(phoneNumber)")! )
    }
    
    func Text_btnClicked(sender:UIButton){
        let contactdic:NSDictionary = self.ToDoItem.objectAtIndex(sender.tag) as! NSDictionary
        let phoneNumber:NSString = contactdic.objectForKey("phone") as! NSString
        if MFMessageComposeViewController.canSendText(){
            let messageController:MFMessageComposeViewController = MFMessageComposeViewController()
            messageController.recipients = ["\(phoneNumber)"]
            messageController.messageComposeDelegate = self
            self.presentViewController(messageController, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue{
        case MessageComposeResultSent.rawValue:
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultCancelled.rawValue:
            controller.dismissViewControllerAnimated(true, completion: nil)
        default:
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func Mail_btnClicked(sender:UIButton){
        let contactdic:NSDictionary = self.ToDoItem.objectAtIndex(sender.tag) as! NSDictionary
        let email:NSString = contactdic.objectForKey("email") as! NSString
        if MFMailComposeViewController.canSendMail(){
            let mailController:MFMailComposeViewController = MFMailComposeViewController()
            mailController.setToRecipients( ["\(email)"] )
            mailController.mailComposeDelegate = self
            self.presentViewController(mailController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result.rawValue{
        case MFMailComposeResultSent.rawValue:
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSent.rawValue:
            controller.dismissViewControllerAnimated(true, completion: nil)
        default:
            controller.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            if self.yourContact.count > 0 {
                let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDeleg.managedObjectContext
                let contactdic:NSDictionary = self.yourContact.objectAtIndex(indexPath.row) as! NSDictionary
                let dateid:NSString = contactdic.objectForKey("dateid") as! NSString
                let request = NSFetchRequest(entityName: "ToDoItem")
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
