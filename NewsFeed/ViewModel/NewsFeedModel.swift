//
//  NewsFeedModel.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/3/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import CoreData
class NewsModel {
    private let fetcher: Fetching
    
    init(fetcher: Fetching, dictionary: [String: AnyObject], context:NSManagedObjectContext) {
        self.fetcher = fetcher
        
        self.context =  context
        
        self._id = dictionary["_id"] as? Int16 ?? -1
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.postedAt = dictionary["postedAt"] as? String ?? ""
        self.message = dictionary["message"] as? String ?? ""
        datePostDate()
        saveCoreData()
        
        var user = self.news?.whichUser
        
        let dataUser = dictionary["user"]
        if  user == nil{
            
            user = UserNewsFeed(context:self.context!)
            self.news?.whichUser = user
            
        }
        if dataUser != nil {
            user?.imageUrl =  dataUser?["imageURL"] as? String ?? ""
            user?.fullName = dataUser?["fullName"] as? String ?? ""
            user?.dob = dataUser?["dob"] as? String ?? ""
            
            user?.mobileNo = dataUser?["mobileNo"] as? String ?? ""
            self.news?.whichUser = user
            saveCoreData()
        }
        
        
        
        
        
    }
    var imageDataNews:Data? =  nil
    var imageDataProfile:Data? = nil
    
    var news:NewsFeed?
    var context:NSManagedObjectContext?
    
    var _id:Int16? {
        willSet {
            self.news?.newsFeedServerID = newValue!
        }
        didSet {
            self.news?.newsFeedServerID = oldValue!
        }
    }
    init(_ newsFeed:NewsFeed, context:NSManagedObjectContext,fetcher:Fetching) {
        self.news = newsFeed
        
        self._id =  self.news?.newsFeedServerID
        self.comments =  self.news?.comments
        self.likes =  self.news?.likes
        self.imageURL = self.news?.imageURL
        self.message  = self.news?.message
        self.postedAt =  self.news?.postedAt
        self.context = context
        self.fetcher = fetcher
    }
    
    var comments: Int16? {
        willSet {
            self.news?.comments =  newValue!
            
        }
        didSet {
            if Int(oldValue!) == 0 {
                //                getCommentFromServer()
            }
        }
    }
    var likes: Int16? {
        willSet {
            self.news?.likes =  newValue!
        }
        didSet {
            if Int(oldValue!) == 0 {
                //                getLikesFromServer()
            }
        }
    }
    func getCommentFromServer(){
        if comments == 0 {
            let stringQuery = "\(Constant.RootServer)\(_id!)/commentCount"
            
            fetcher.fetch(withQueryString: stringQuery, completion: { (dictionary) in
                self.createNewsFeed()
                self.comments =  (dictionary["data"] as? Int16) ?? 0
                self.saveCoreData()
                
            })
        }
        
    }
    func getLikesFromServer(){
        if likes == 0 {
            let stringQuery = "\(Constant.RootServer)\(_id!)/likeCount"
            fetcher.fetch(withQueryString: stringQuery, completion: { (dictionary) in
                self.createNewsFeed()
                self.likes =  (dictionary["data"] as? Int16) ?? 0
                self.saveCoreData()
                
            })
        }
        
    }
    var imageURL: String?{
        willSet{
            self.news?.imageURL =  newValue ?? ""
        }
    }
    
    var message: String?{
        willSet {
            self.news?.message = newValue ?? ""
        }
    }
    
    var postedAt: String?
    func createNewsFeed(){
        if news == nil {
            news = NewsFeed(context:self.context!)
        }
        news?.newsFeedServerID = self._id!
        news?.comments = self.comments ?? 0
        news?.likes = self.likes ?? 0
        news?.imageURL = self.imageURL
        news?.postedAt = self.postedAt
        news?.message =  self.message
        datePostDate()
    }
    func datePostDate(){
        let noaaDate = self.postedAt
        let format="yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = format
        let newreadableDate = dateFmt.date(from: noaaDate!)
        self.news?.postDate = newreadableDate! as NSDate
    }
    func saveCoreData(){
        do {
            try context?.save()
        } catch   {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    func save(){
        createNewsFeed()
        saveCoreData()
    }
}
protocol NewsFeedProtocol {
    
    func checkServer(completion: @escaping () -> Void)
}
class NewsFeedModel : NewsFeedProtocol {
    func getNewsModel(index: Int) -> NewsModel {
        return items[index]
    }
    private var items : [NewsModel] = [NewsModel]()
    var context:NSManagedObjectContext?
    var fetchController:NSFetchedResultsController<NewsFeed>?
    private let fetcher: Fetching
    init(fetcher: Fetching,fetchController:NSFetchedResultsController<NewsFeed>?){
        self.fetcher = fetcher
        self.fetchController =  fetchController
        self.context = fetchController?.managedObjectContext
        for aNewsFeed in (self.fetchController?.fetchedObjects)! {
            let newsModel:NewsModel = NewsModel.init(aNewsFeed, context:self.context!,fetcher:fetcher)
            
            self.items.append(newsModel)
        }
        
    }
    func checkArrayHaveID(_ id:Int16) -> (isFound :Bool,newsModel:NewsModel?){
        guard  id >= 0 else{
            return (false,nil)
        }
        
        if let i = self.items.index(where: { $0._id == id }) {
            
            return (true,self.items[i])
        }        else {
            //  not
            
            return (false,nil)
        }
    }
    
        
    func checkServer(completion: @escaping () -> Void){
        fetcher.fetch(withQueryString: Constant.RootServer) { (dictionary) in
            guard let data = dictionary["data"] else {
                completion()
                return
            }
            for aData in data as! [[String:AnyObject]] {
                let id: Int16 = aData["_id"] as! Int16
                
                
                let check = self.checkArrayHaveID(id)
                let alreadyInList = check.isFound
                var newsModel:NewsModel? = check.newsModel
                if alreadyInList == false{
                    
                    newsModel =  NewsModel.init(fetcher: self.fetcher,  dictionary: aData, context: self.context!)
                    
                    newsModel?.save()
                    if let newsModel =  newsModel {
                        self.items.append(newsModel)
                    }
                }else{
                    
                }
                var user = newsModel?.news?.whichUser
                if user == nil {
                    user = UserNewsFeed(context:self.context!)
                    newsModel?.news?.whichUser = user
                }
                let dataUser:[String:AnyObject]? = aData["user"] as? [String : AnyObject]
                if dataUser != nil {
                    
                    user?.imageUrl =  (dataUser?["imageURL"] as? String) ?? ""
                    user?.fullName = (dataUser?["fullName"] as? String) ?? ""
                    user?.dob = dataUser?["dob"] as? String ?? ""
                    user?.mobileNo = dataUser?["mobileNo"] as? String ?? ""
                }
                
                newsModel?.imageURL = aData["imageURL"] as? String ?? ""
                newsModel?.postedAt = aData["postedAt"] as? String ?? ""
                newsModel?.message = aData["message"] as? String ?? ""
                newsModel?.datePostDate()
                newsModel?.save()
                newsModel?.getCommentFromServer()
                newsModel?.getLikesFromServer()
                
            }
            completion()
            
        }
    }
    
}
