//
//  Fetching.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/4/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit
protocol FetchingProtocol {
    func fetch(withQueryString queryString: String, completion: @escaping (NSDictionary) -> Void)
    
}
class Fetching: FetchingProtocol {
    func fetch(withQueryString queryString: String, completion: @escaping (NSDictionary) -> Void) {
        
        let encoded = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: encoded)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard data != nil else{
                return
            }
            do {
                let object = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                
                completion(object!)
                
            } catch {
                print(error)
            }
            
        }) .resume()
    }
        
}
