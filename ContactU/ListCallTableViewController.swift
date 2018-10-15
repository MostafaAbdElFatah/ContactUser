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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    func loadData(){
        
        yourContact.removeAllObjects()
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoItem")
            let results = try context.fetch(request)
            for contact in results as![NSManagedObject]{
                let dateid = contact.value(forKey: "dateID")    as! String
                let note  = contact.value(forKey: "note")       as! String
                let dueDate  = contact.value(forKey: "dueDate") as!  Date
                let singleContact:NSDictionary = ["dateid":dateid,"note":note,"duedate":dueDate]
                self.yourContact.add(singleContact)
            }
            let dateSort:NSSortDescriptor = NSSortDescriptor(key: "duedate", ascending: true)
            let sortedArray:Array = self.yourContact.sortedArray(using: [dateSort]) as Array
            self.yourContact = NSMutableArray(array: sortedArray)
            self.tableView.reloadData()
        }catch{
            print("error in fetching data")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.yourContact.count
    }
    
    
    func fetchdateid(dateid:String)-> Dictionary<String, Any>?{
        
        var contactDic:Dictionary<String, Any>?
        
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        request.predicate = NSPredicate(format: "dateID == '\(dateid)'")
        
        do{
            let results = try context.fetch(request) as! [NSManagedObject]
            if results.count > 0 {
                let firstname = results[0].value(forKey: "firstName") as! String
                let lastname  = results[0].value(forKey: "lastName")  as! String
                let email     = results[0].value(forKey: "email")     as! String
                let phone     = results[0].value(forKey: "phone")     as! String
                let dateCon   = results[0].value(forKey: "dateID")    as! String
                let imageCon  = results[0].value(forKey: "image")     as! Data
                contactDic = ["firstName":firstname,"lastName":lastname,"email":email
                    ,"phone":phone,"date":dateCon,"image":imageCon]
            }
            
        }catch{
            print("error in fetching data")
        }
        return contactDic
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt  indexPath: IndexPath) -> UITableViewCell {
        let cell:ListCallTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CallCell", for: indexPath) as! ListCallTableViewCell
        let singleContact:Dictionary<String, Any> = self.yourContact.object(at: indexPath.row) as! Dictionary<String, Any>
        
        let dataidContact = singleContact["dateid"]
        var contact:Dictionary<String, Any>? = fetchdateid(dateid: dataidContact as! String)
        let note    =  singleContact["note"] as! String
        let dueDate =  singleContact["duedate"] as! Date
        if contact != nil{
            self.ToDoItem.add(contact!)
            let firstname = contact!["firstName"] as! String
            let lastname  = contact!["lastName"] as! String
            let imageCon  = contact!["image"] as! Data
            cell.namelabel.text    = "\(String(describing: firstname)) \(String(describing: lastname))"
            // set image
            let imageContact:UIImage = UIImage(data: imageCon)!
            var imageFrameContact:CGRect = cell.imageContact.frame
            imageFrameContact.size = CGSize(width: 75, height: 75)
            cell.imageContact.frame = imageFrameContact
            cell.imageContact.image = imageContact
            
            cell.noteLabel.text  = note
            // set date
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd"
            let dateString:String = dateFormatter.string(from: dueDate)
            cell.dueDateLabel.text  = dateString
            // set btns event and data
            cell.Callbtn.tag = indexPath.row
            cell.Textbtn.tag = indexPath.row
            cell.mailbtn.tag = indexPath.row
            
            cell.Callbtn.addTarget(self, action: #selector(ListCallTableViewController.Call_btnClicked(_:)), for: UIControlEvents.touchUpInside)
            cell.Textbtn.addTarget(self, action: #selector(ListCallTableViewController.Text_btnClicked(_:)), for: UIControlEvents.touchUpInside)
            cell.mailbtn.addTarget(self, action: #selector(ListCallTableViewController.Mail_btnClicked(_:)), for: UIControlEvents.touchUpInside)
        }
        return cell
    }
    
    @objc func Call_btnClicked(_ sender:UIButton){
        let contactdic:Dictionary<String,Any> = self.ToDoItem.object(at: sender.tag) as! Dictionary<String,Any>
        guard let phoneNumber:String = contactdic["phone"] as? String
            , let number = URL(string: "tel://" + phoneNumber) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(number)
        } else {
            UIApplication.shared.openURL(number)
        }
    }
    
    @objc func Text_btnClicked(_ sender:UIButton){
        let contactdic:Dictionary<String,Any> = self.ToDoItem.object(at: sender.tag) as! Dictionary<String,Any>
        let phoneNumber:String = contactdic["phone"] as! String
        if MFMessageComposeViewController.canSendText(){
            let message = MFMessageComposeViewController()
            message.messageComposeDelegate = self
            message.recipients = ["\(phoneNumber)"]
            message.body = "message body"
            present(message, animated: true)
        }else {
            // show failure alert
            print("can't send message now")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue{
            case MessageComposeResult.sent.rawValue:
                print("Message sent..")
            case MessageComposeResult.cancelled.rawValue:
                print("Message cancelled..")
            case MessageComposeResult.failed.rawValue:
                print("Message failed..")
            default:
                print("no message Action.")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func Mail_btnClicked(_ sender:UIButton){
        let contactdic:Dictionary<String,Any> = self.ToDoItem.object(at: sender.tag) as! Dictionary<String,Any>
        let email:String = contactdic["email"] as! String
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients( ["\(email)"] )
            mail.setMessageBody("mail message body", isHTML: false)
            present(mail, animated: true)
        } else {
            // show failure alert
            print("can't send email now")
        }
    }
  
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue{
            case MFMailComposeResult.sent.rawValue:
                print("Maill sent..")
            case MFMailComposeResult.cancelled.rawValue:
                print("Maill cancelled..")
            case MFMailComposeResult.failed.rawValue:
                print("Maill failed..")
            default:
                print("no Mail Action.")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            if self.yourContact.count > 0 {
                let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let context:NSManagedObjectContext = appDeleg.managedObjectContext
                let contactdic:NSDictionary = self.yourContact.object(at: indexPath.row) as! NSDictionary
                let dateid:NSString = contactdic.object(forKey: "dateid") as! NSString
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoItem")
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
        ///
    }
    
  
}
