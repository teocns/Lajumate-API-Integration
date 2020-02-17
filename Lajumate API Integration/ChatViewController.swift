//
//  ChatViewController.swift
//  Lajumate API Integration
//
//  Created by Doru Constantin Teodorescu on 2/12/20.
//  Copyright © 2020 Doru Constantin Teodorescu. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var endUserLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var conversation: Conversation? = nil
    
    var sender: AnyObject? = nil
    
    @IBOutlet weak var textInput: UITextField!
    
    var conversationDetailed: ConversationDetailed? = nil
    
    @IBOutlet weak var chatBoxContainer: UIView!
    
    
    // Cand apasam pe butonul Trimite
    @IBAction func onTouchDown(sender: AnyObject) {
        
        print ("Am fost clickat")
        if self.textInput.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3
        {
            // Daca text-ul este mai scurt de 3 litere, anuleaza
            return
        }
        print ("Trimit mesajul...")
        self.textInput.resignFirstResponder();
        ConversationDetailed.SendMessage(
            self.conversationDetailed!,
            message: textInput.text!,
            resolve: onMessageSent
        )
    }
    
    // Cand a fost trimis un mesaj din chat
    func onMessageSent(wasSent: Bool){
        
        if wasSent{
            self.loadConversation()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.tableHeaderView = UIView()
        self.tableView.separatorColor = UIColor.clearColor()

        self.title = "..." // se populeaza mai tarziu cu numele destinatarului
        
        
        loadConversation()
        //print(self.conversation?.lastMessage)
        
        
        
        

        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    
    
    // Event care se lanseaza cand dam submit la textField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3
        {
            // Daca text-ul este mai scurt de 3 litere, anuleaza
            return false;
        }
        textField.resignFirstResponder();
        ConversationDetailed.SendMessage(
            self.conversationDetailed!,
            message: textField.text!,
            resolve: onMessageSent
        )
            return true
        }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print ("Total Rows: ")
        //print (self.items.count)
        return 1
    }
    
    
    
    private func loadConversation() -> Void{
        if (self.conversation != nil) {
            ConversationDetailed.Get((self.conversation?.id)!, resolve: self.onChatLoaded)
        }
    }
    
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        
        cell.layer.cornerRadius = 5
        
        guard let itemData = self.conversationDetailed?.messageList[indexPath.section] as ConversationMessage? else{
            return cell
        }
        cell.message.text = itemData.message
        
        let senderName : String = itemData.sender == ApiObject.ENDPOINT_USER_ID ? "Tu" : (conversationDetailed?.endUser!.name)!
        
        cell.niceDate.text = "\(senderName), \(itemData.niceDate)"
        if itemData.sender == ApiObject.ENDPOINT_USER_ID {
            cell.backgroundColor = UIColor(rgb: 0x02e0c3)
            cell.message.textAlignment = .Right
            cell.niceDate.textAlignment = .Right
        }
        else{
            cell.backgroundColor = UIColor(rgb: 0x02bfa6)
            cell.message.textAlignment = .Left
            cell.niceDate.textAlignment = .Left

        }
       // if (itemData.message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        
        return cell
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height : CGFloat = self.tableView.rowHeight
        
        guard let itemData = self.conversationDetailed?.messageList[indexPath.section] as ConversationMessage? else{
            return height
        }
        return requiredHeight(itemData.message) + 30 // adaugam un pic de padding

    }
    
    func requiredHeight(text:String) -> CGFloat {
        
        // Stabilizam inaltimea la row-uri in baza la lungimea text-ului
        let font = UIFont(name: "Helvetica", size: 16.0)
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, 200, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return conversationDetailed?.messageList.count ?? 0
        
    }

    
    // Punem spacing prin sectiile din table
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 15
        return cellSpacingHeight
    }
    
    override func viewWillDisappear(animated: Bool) {

        if self.sender != nil  {
            guard let senderView = self.sender as? ViewController else{
                return
            }
            print ("Calling sender initializeData()")
            senderView.initializeData()
        }
    }
    
    private func onChatLoaded(cd : ConversationDetailed) -> Void{
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //self.Table.dataSource = self
            //self.Table.delegate = self
            self.conversationDetailed = cd
            let endUsr = self.conversationDetailed?.endUser?.name ?? ""
            self.title = endUsr
            
         
            //self.Table.dataSource = self
            //self.Table.delegate = self
            self.textInput.text = ""
            self.tableView.reloadData()
            
            // punem scroll point in table view la bottom max
            
            if self.tableView.contentSize.height > self.tableView.frame.size.height{
                let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
                self.tableView.setContentOffset(scrollPoint, animated: false)
            }
            
   
        }
        

        
        
      
    }
}
