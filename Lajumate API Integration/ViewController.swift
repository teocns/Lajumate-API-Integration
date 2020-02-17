//
//  ViewController.swift
//  Lajumate API Integration
//
//  Created by Doru Constantin Teodorescu on 2/11/20.
//  Copyright © 2020 Doru Constantin Teodorescu. All rights reserved.
//

import UIKit
import Foundation

// In acest Proiect nu m-am folosit de BEST PRACTICES in multe locuri pentru a putea strange de timp, fiind realizat in doua zile fara experienta pe Swift
// De exemplu Error Handling, Validation, Data Integrity sunt incomplete.
// Se presupune ca API-ul ramane invariat si mereu functionant pentru functionarea corecta al proiectului
//
// Finalizez zicand ca aceasta este doar o demonstratie (incompleta) de ajungere
// la rezultatul dorit ( Simple Chat care implementeaza un API)

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var Table: UITableView!
    
    var items = [Conversation]()
    @IBOutlet weak var searchBox: UISearchBar!
    var filteredItems = [Conversation]()
    var selectedConversation : Conversation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Conversatii Lajumate.ro"
        Table.tableFooterView = UIView()
        Table.tableHeaderView = UIView()
       // self.Table.translatesAutoresizingMaskIntoConstraints = false

        //self.Table.registerClass(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        
        self.Table.dataSource = self
        self.Table.delegate = self
        
        self.initializeData()
        
        
    }
    
    func initializeData(){
        // Initializam obiectul API si verificam daca a fost generat token-ul cu success
        ApiObject.initialize(
            { (didInitialize: Bool) -> Void in
                
                
                if didInitialize {
                    print("Access Token Retrieved: "+String(didInitialize))
                    
                    // Luam Conversatiile in Preview
                    ApiObject.getConversations(
                        {
                            data -> Void in
                            //print (data["conversations"]!)
                            self.loadConversationsTable(data["conversations"] as! [AnyObject], isFromFilter: false)
                            
                        }
                    )
                }
                
            }
            
        )

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Table Conversatii
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print ("Total Rows: ")
        //print (self.items.count)
        
        if (self.filteredItems.count > 0 ){
            return self.filteredItems.count
        }
        else{
            return self.items.count
        }

    }
    
    // Table Conversatii - Cell Assignment
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath) as! ConversationCell
        
        var searchArray : [Conversation]? = nil
        if (self.filteredItems.count > 0 ){
            searchArray = self.filteredItems
        }
        else{
            searchArray = self.items
        }
        
        guard let itemData = searchArray![indexPath.row] as Conversation? else{
            return cell
        }
        cell.lastMessage.text = itemData.lastMessage
        cell.lastSent.text = itemData.dateTime
        
        print (itemData.id)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
      
    }

    
    // Table Conversatii - On Click
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        guard let conversation = try self.items[indexPath.row] as Conversation? else{
            return
        }
        self.selectedConversation = conversation
        
        self.performSegueWithIdentifier("segueToChat", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let dest =  segue.destinationViewController as? ChatViewController else{
            return
        }
        
        dest.conversation = self.selectedConversation
        dest.sender = self
    }

    private func loadConversationsTable(dataDict: [AnyObject], isFromFilter : Bool){
        print ("Loading conversations table")
        if isFromFilter{
            self.Table.reloadData()
            return
        }
        self.items = [Conversation]()
        
        for item in dataDict{
            
            self.items.append(
                Conversation(
                    date: item["date"] as! String,
                    lastMessage:item["lastMessage"] as! String,
                    id:item["id"] as! Int,
                    user: item["id"] as! Int,
                    dateTime: item["lastSent"] as! String
                )
            )
        }
        // not sure if this reassignment of datasource and delegate is proper
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            //self.Table.dataSource = self
            //self.Table.delegate = self
            self.Table.reloadData()
        }
        
        
        

    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        print ("Search invoked")
        
        if searchText.isEmpty{
            self.filteredItems.removeAll()
            self.loadConversationsTable([AnyObject](),isFromFilter:true)
            return
        }
        self.filteredItems = self.items.filter({$0.lastMessage.containsString(searchText.lowercaseString)})
        
        print ("Filtered \(self.filteredItems.count) item" )
        
        if (self.filteredItems.count > 0){
            self.loadConversationsTable([AnyObject](),isFromFilter:true)
        }
        
    }
}




