//
//  ServiceFactory.swift
//  TestApp
//
//  Created by Walia, Raman on 12/22/16.
//  Copyright © 2016 Meher Enterprises. All rights reserved.
//

import Foundation

class ServiceFactory{
    static let sharedInstance = ServiceFactory()
    static var serverURL :String = ""
    
    private init(){

    }
    
    
    static func getInstance() -> ServiceFactory{
        if serverURL == "" {
            ServerDiscoveryService().discoverServer({ (serverIP) in
                serverURL = "http://"+serverIP+":3000/api"
            })
        }
        return sharedInstance
    }
    
    static func getRoombaService() -> RoombaService {
       return RoombaService(sURL: serverURL)
    }
    
    
}
