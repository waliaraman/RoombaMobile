//
//  ServerDiscoveryService.swift
//  TestApp
//
//  Created by Walia, Raman on 12/22/16.
//  Copyright © 2016 Meher Enterprises. All rights reserved.
//

import Foundation
import Darwin


class ServerDiscoveryService{
    
    func discoverServer(completeHandler : (serverIP : String) -> Void) -> String {
        let deviceIP = getIFAddresses();
        broadCastPing(deviceIP[0]) { (serverIP) in
            completeHandler(serverIP: serverIP)
        }
        return "";
    }

    
    func broadCastPing(ip:String, completeHandler : (serverIP : String) -> Void) -> String {
        let subnet : String = (ip as NSString).substringToIndex(ip.lastIndexOf(".")!)
        
        for i in 0...1{
            let ipAddress = subnet.stringByAppendingString((i as NSNumber).stringValue);
//            NSLog("Debug : Sending request for ip address " + ipAddress)
            sendPingToNetwork(ipAddress, completion: { (result) in
                completeHandler(serverIP: result);
            })
        }
        return ""
    }
    
    func sendPingToNetwork(ip:String,  completion: (result: String) -> Void) -> String {
        let url = "http://" + ip + ":3000/api/pingtodiscover"
        NSLog("Debug : IP address = " + url)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = 5
        urlconfig.timeoutIntervalForResource = 5
        let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                print (error.debugDescription)
                completion(result: "10.0.0.240")

            }
            
            if data != nil {
                completion(result: ip)
            }
        })
        task.resume()
        return ""
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr.memory.ifa_next }
                
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String.fromCString(hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
    
}

extension String {
    var length:Int {
        return self.characters.count
    }
    
    func indexOf(target: String) -> Int? {
        
        let range = (self as NSString).rangeOfString(target)
        
        guard range.toRange() != nil else {
            return nil
        }
        
        return range.location
        
    }
    func lastIndexOf(target: String) -> Int? {
        
        let range = (self as NSString).rangeOfString(target, options: NSStringCompareOptions.BackwardsSearch)
        
        guard range.toRange() != nil else {
            return nil
        }
        
        return range.location+1
        
    }
}
