//
//  ListNewsFeedController.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/4/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import UIKit
import CoreData
class NewsCell : UICollectionViewCell {
    
    @IBOutlet weak var imageviewNews: UIImageView!
    @IBOutlet weak var imageviewLike: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var imageviewComment: UIImageView!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageviewProfile: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        imageviewProfile.layer.cornerRadius = imageviewProfile.frame.height/2
    }
    
}
class ListNewsFeedController : UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fectching :Fetching = Fetching()
    var newsModel : NewsFeedModel?
    let refreshControl:UIRefreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        newsModel = NewsFeedModel.init(fetcher: self.fectching, fetchController: self.fetchedResultsController)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl =  refreshControl
        let attributes = [NSForegroundColorAttributeName: UIColor.black]
        let attributedTitle = NSAttributedString(string: "Refreshing News Feed", attributes: attributes)
        refreshControl.attributedTitle =  attributedTitle
        refreshControl.beginRefreshing()
        
        
        newsModel?.checkServer(completion: completion)
        NotificationCenter.default.addObserver(self, selector: #selector(onBackground), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    
    
    
    func onBackground(notification : NSNotification) {
        
        newsModel?.checkServer(completion: completion)
        
    }
    
    @objc private func didPullToRefresh() {
        newsModel?.checkServer(completion: completion)
    }
    
    private func completion() {
        
        refreshControl.endRefreshing()
    }
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath)
        configureCell(cell as! NewsCell, withEvent: self.fetchedResultsController.fetchedObjects?[indexPath.row],index:indexPath)
        
        return cell
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CellNews", for: indexPath) as UIView
        return view as! UICollectionReusableView
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
    }
   
    func configureCell(_ cell: NewsCell, withEvent newsFeed: NewsFeed?,index:IndexPath) {
        print(newsFeed?.whichUser as Any)
        cell.labelUsername.text =  newsFeed?.whichUser?.fullName
        cell.labelTime.text =  newsFeed?.postDate?.dateDiff() ?? newsFeed?.postedAt
        cell.labelLike.text =  "\(newsFeed?.likes.description ?? "0") likes"
        cell.labelComment.text =  "\(newsFeed?.comments.description ?? "0") comments"
        cell.labelMessage.text =  newsFeed?.message
        let aNewsModel = newsModel?.getNewsModel(index: index.row)
        if aNewsModel?.imageDataProfile == nil{
            cell.imageviewProfile.loadImageURL(URL(string:(newsFeed?.whichUser?.imageUrl)!), placeholderImage: "user") { (success, data, image) in
                if(success){
                    aNewsModel?.imageDataProfile = data
                }
                cell.imageviewProfile.image = image
            }
        }else{
            cell.imageviewProfile.image = UIImage(data:(aNewsModel?.imageDataProfile)!)
        }
        
        if aNewsModel?.imageDataNews == nil{
            cell.imageviewNews.loadImageURL(URL(string:(newsFeed?.imageURL)!), placeholderImage: "news") { (success, data, image) in
                
                
                if(success){
                    aNewsModel?.imageDataNews = data
                }
                
                cell.imageviewNews.image = image
                
            }
        }else{
            cell.imageviewNews.image = UIImage(data:(aNewsModel?.imageDataNews)!)
        }
        
        
        
          }

    //    NSFetch
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    
    
    var fetchedResultsController: NSFetchedResultsController<NewsFeed> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<NewsFeed> = NewsFeed.fetchRequest()
        
        
        fetchRequest.fetchBatchSize = 20
        
        
        let sortDescriptor = NSSortDescriptor(key: "newsFeedServerID", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName:nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<NewsFeed>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
     
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            collectionView.insertSections(IndexSet(integer: sectionIndex))
        case .delete:
            collectionView.deleteSections(IndexSet(integer: sectionIndex))
        default:
            return
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            
            collectionView.reloadItems(at: [indexPath!])
            
        case .move:
           
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
}
