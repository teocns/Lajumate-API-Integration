//
//  ConversationDetailed.swift
//  Lajumate API Integration
//
//  Created by Doru Constantin Teodorescu on 2/12/20.
//  Copyright © 2020 Doru Constantin Teodorescu. All rights reserved.
//

import Foundation



class ConversationDetailed{
    var messageList: [ConversationMessage] = []
    var latestMessageIsLocal : Bool = false
    var latestMessage : String = ""
    var read : Int  = 0
    var ad_id : Int = 0
    var id : Int = 0
    var endUser: ConversationUser?
    
    init(localUserId : Int, rawData: NSDictionary){
        
        let arr = rawData["messageList"] as! NSArray
        // Serializam proprietatiile obiectului
        self.id = rawData["conversation"]?["id"] as! Int
        self.ad_id = rawData["conversation"]?["ad_id"] as! Int
        //print (self.id)
        //print (self.ad_id)
        // Serializam lista de mesaje
        self.messageList = []
        for rawItem in arr{
            let item = rawItem as! NSDictionary
            self.messageList.append(
                ConversationMessage(
                    id:item["id"] as! Int,
                    sender:item["sender"] as! Int,
                    message:item["message"] as! String,
                    createdAt:item["created_at"] as! String,
                    niceDate:item["nice_date"] as! String
                    
                )
            )
        }
        
        self.endUser = nil
        //Luam informatiile despre user
        let users = rawData["users"] as! NSDictionary
        for (_, rawUser) in users{
            
            let user = rawUser as! NSDictionary
            
            
            if (user["id"] as! Int != localUserId)
            {
                self.endUser = ConversationUser(
                    id: user["id"] as! Int,
                    name: user["name"] as! String,
                    photo: user["photo"] as! String
                )
            }
        }
        // Inchidem cu ultimele variabile
        
        self.latestMessageIsLocal = rawData["conversation"]?["latest_message_by"] as! Int == localUserId
        
        self.latestMessage = rawData["conversation"]?["latest_message"] as! String
        self.read = rawData["conversation"]?["read"] as! Int
        
    }
    
    
    static func Get(conversationId: Int, resolve: (ConversationDetailed) -> ()) -> Void{
        
        
        ApiObject.getConversation(conversationId, resolve: {
            (data: NSDictionary) -> () in
            resolve(
                // 1 trebuie schimbat cu Userul care cere conversatia
                ConversationDetailed(localUserId: 1,rawData: data)
            )
            
        })
    }
    
    
    static func SendMessage(conversation: ConversationDetailed, message:String, resolve: (Bool) -> ()){
        if message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3{
            resolve(false) // Mesaj-ul este prea scurt
        }
    
        ApiObject.sendMessage(
            conversation.id,
            ad_id: conversation.ad_id,
            message: message,
            resolve: { data  in
                if data["status"] as! String? == "done"{
                    resolve(true)
                }
                else{
                    resolve(false)
                }

            }
        )
    }
}



struct ConversationMessage{
    var id : Int
    var sender : Int
    var message: String
    var createdAt: String
    var niceDate: String
}