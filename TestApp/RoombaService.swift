//
//  RoombaService.swift
//  TestApp
//
//  Created by Walia, Raman on 12/24/16.
//  Copyright © 2016 Meher Enterprises. All rights reserved.
//

import Foundation

class RoombaService {
    
    var taskURL : String
    
    init(sURL : String ){
        taskURL = sURL.stringByAppendingString( "/roomba")
    }
    
    func sendCommand(command:String,  completion: (result: String) -> Void){
        NSLog("Debug : Firing URL = " + taskURL)
        
        let request = NSMutableURLRequest(URL: NSURL(string: taskURL)!)
        request.HTTPMethod = "POST"
        let postString = "action=".stringByAppendingString(command)
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "ContentType")
        
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = 5
        urlconfig.timeoutIntervalForResource = 5
        let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                print (error.debugDescription)
            }
            if data != nil {
                let res = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                print(res)
            }
            completion(result: "ok")
        })
        task.resume()
   
    }
    
}