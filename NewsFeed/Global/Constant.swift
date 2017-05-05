//
//  Constant.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/4/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit
class Constant {
    static let RootServer = "http://thedemoapp.herokuapp.com/post/"
    
}
extension URLResponse {
    func isHTTPResponseValid() -> Bool {
        guard let response = self as? HTTPURLResponse else {
            return false
        }
        
        return (response.statusCode >= 200 && response.statusCode <= 299)
    }
}

extension UIImageView {
    func loadImageURL(_ url: URL?,placeholderImage:String,completionHandler:  @escaping (Bool,Data?,UIImage?) -> Swift.Void) {
        
        var imageComplete:UIImage = UIImage(named: placeholderImage)!
        
        guard let url = url else {
            completionHandler(false,nil,nil)
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if let response = response, let data = data, response.isHTTPResponseValid() {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    if UIImage(data: data) == nil {
                        
                        completionHandler(false,nil,imageComplete)
                    } else {
                        
                        imageComplete = UIImage(data: data)!
                        completionHandler(true,data,imageComplete)
                    }
                })
            }else{
                completionHandler(false,nil,imageComplete)
            }
        }) .resume()
    }
    
}

extension NSDate {
    func dateDiff() -> String? {
        
        
        
        
        let todayDate: NSDate = NSDate()
        var ti: Double = self.timeIntervalSince(todayDate as Date)
        ti = ti * -1
        if ti < 1 {
            return "now"
        }
        else if ti < 60 {
            return "less than a minute ago"
        }
        else if ti < 3600 {
            let diff: Int = Int(round(ti / 60))
            return "\(diff) minutes ago"
        }
        else if ti < 86400 {
            let diff: Int = Int(round(ti / 60 / 60))
            return "\(diff) hours ago"
        }
        else if ti < 2629743 {
            let diff: Int = Int(round(ti / 60 / 60 / 24))
            return "\(diff) days ago"
        }
        else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy"
//            dateFormatter.locale = Locale.init(identifier: "en_SG")
            let stringDate = dateFormatter.string(from: self as Date)
            return stringDate
        }
   
    
    }
    
    
}
