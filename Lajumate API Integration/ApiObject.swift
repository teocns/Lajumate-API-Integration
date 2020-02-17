//
//  ApiObject.swift
//  Lajumate API Integration
//
//  Created by Doru Constantin Teodorescu on 2/11/20.
//  Copyright © 2020 Doru Constantin Teodorescu. All rights reserved.
//

import Foundation

// In acest Proiect nu m-am folosit de BEST PRACTICES in multe locuri pentru a putea strange de timp, fiind realizat in doua zile fara experienta pe Swift
// De exemplu Error Handling, Validation, Data Integrity sunt incomplete.
// Se presupune ca API-ul ramane invariat si mereu functionant pentru functionarea corecta al proiectului
//
// Finalizez zicand ca aceasta este doar o demonstratie (incompleta) de ajungere
// la rezultatul dorit ( Simple Chat care implementeaza un API)

public class ApiObject{
    
    public static let ENDPOINT_RETRIEVE_CONVERSATIONS = "https://lajumate.ro/test/ios-18/conversations"
    public static let ENDPOINT_REQUEST_TOKEN = "https://lajumate.ro/test/ios-18/create-token"
    public static let ENDPOINT_RETRIEVE_CONVERSATION = "https://lajumate.ro/test/ios-18/conversation/"
    public static let ENDPOINT_POST_MESSAGE = "https://lajumate.ro/test/ios-18/send"
    public static let ENDPOINT_PUBLIC_KEY = "VXGNq3GcR73gNJ2FLN2cMZwHPPujy71yrveK0scORS7KzoXWVyjXjh6vzZ1spvzg"
    public static var ENDPOINT_ACCESS_TOKEN = ""
    
    public static var ENDPOINT_USER_ID = 1
    
    

    
    
    
    public static func initialize(resolve: (Bool) -> ()) -> Void{
        
        // Generam Access Token-ul
        
        func __parseResult(reqResult : NSDictionary) -> Void{
            if reqResult["token"] != nil{
                self.ENDPOINT_ACCESS_TOKEN = String(reqResult["token"]!)
                print (self.ENDPOINT_ACCESS_TOKEN)
                resolve(true)
            }
            else{
                resolve(false)
            }
        }
        
        if self.ENDPOINT_ACCESS_TOKEN.isEmpty{
            
            ApiObject.__post(
                ApiObject.ENDPOINT_REQUEST_TOKEN,
                postData: nil,
                resolve: __parseResult
            )
        }
        else{
            print("Recycling Access Token")
            resolve(true)
        }
        
        
        
        // Ar trebuii implementata logica unde verificam daca HTTP Response Body == "Expired token" si regeneram token-ul
    }

    
    public static func sendMessage(conversationId: Int, ad_id: Int, message: String, resolve: (NSDictionary) -> () ) -> Void{
        let postData = [
            "loggedIn":"1",
            "source":"ios",
            "version":"2.4",
            "conversation": String(conversationId),
            "ad_id": String(ad_id),
            "message":message
        ]
        
        let headers = [
            "Token":self.ENDPOINT_ACCESS_TOKEN
        ]
        
        
        self.__post(
            self.ENDPOINT_POST_MESSAGE,
            postData: postData,
            headers: headers,
            resolve: { data in resolve(data) }
        )
    }
    
    public static func getConversations( resolve: (NSDictionary) -> () ) -> Void{
        let postData = [
            "loggedIn":"1",
            "source":"ios",
            "version":"2.4"
        ]
    
        let headers = [
            "Token":self.ENDPOINT_ACCESS_TOKEN
        ]
        
  
        self.__post(
            self.ENDPOINT_RETRIEVE_CONVERSATIONS,
            postData: postData,
            headers: headers,
            resolve: { data in resolve(data) }
        )
    }
    
    
    public static func getConversation(id: Int, resolve : (NSDictionary) -> ()) ->Void{
        let postData = [
            "loggedIn":"1",
            "source":"ios",
            "version":"2.4"
        ]
        
        let headers = [
            "Token":self.ENDPOINT_ACCESS_TOKEN
        ]
        
        
        self.__post(
            self.ENDPOINT_RETRIEVE_CONVERSATION+String(id),
            postData: postData,
            headers: headers,
            resolve: { data in resolve(data) }
        )
    }
    
    
    
    
    private static func __convertToJSON(obj: AnyObject) -> NSData? {
        if NSJSONSerialization.isValidJSONObject(obj){
            return try! NSJSONSerialization.dataWithJSONObject(obj, options: .PrettyPrinted) ?? NSData()
        }
        return nil;
    }
    
    
    private static func __stringify(jsonData : AnyObject) -> String{
        
        do{
            return try String(data: (jsonData as? NSData)!, encoding: NSUTF8StringEncoding)!
        }
        catch{
            return ""
        }
       
        
    }
    
    private static func __dictToString(dic: AnyObject) -> [String:Any]?{
        do {
            
            if let theJSONData = try? NSJSONSerialization.dataWithJSONObject(dic, options: []){
                let theJSONText = String(data: theJSONData, encoding: NSUTF8StringEncoding )
                    print("JSON string = \(theJSONText!)")
            }
        } catch let error as NSError {
            print(error)
        }
        return nil

    }
    private static func __post(
        url_str: String,
        postData : AnyObject? = nil,
        headers : [String:String]? = nil,
        resolve: (NSDictionary) -> ()
        ) -> Void{
        
            
    
        
        // Cream request-ul
        
        let url = NSURL(string: url_str)!
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
   
      
            
        // Convertim Parametrul Dictionary in JSON, daca avem POST data
    
       
        if postData != nil {
            
            request.HTTPBody = self.__convertToJSON(postData!)

            
            
        }
        
            
        // Adaugam headerele
        
        request.addValue(ENDPOINT_PUBLIC_KEY, forHTTPHeaderField: "Public-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if headers != nil{
            for (key,value) in headers!{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
            
        let session = NSURLSession.sharedSession()
        
        
        // Performam POST async
 
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            

            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            // Printam raw response text
            //print(String(data:data, encoding: NSUTF8StringEncoding))
            
            guard let responseJson = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else{
                return
            }
        
            
            resolve(responseJson as! NSDictionary)
                
            return
            
            
        })
        task.resume()
        
        
    }
}