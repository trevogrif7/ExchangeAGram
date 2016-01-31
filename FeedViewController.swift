//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Trevor Griffin on 1/27/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var feedArray: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        
        do {
            try feedArray = context.executeFetchRequest(request)

        } catch let error as NSError {
            // failure
            print("TEG ERROR: Fetch failed: \(error.localizedDescription)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) &&
            !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
                
                takePicture()
                
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) &&
              !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {

                openPhotoLibrary()
                
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) &&
              UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                
            let alertController = UIAlertController(title: "Please Select", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {UIAlertAction in self.openPhotoLibrary()})
            let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {UIAlertAction in self.takePicture()})
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
            alertController.addAction(libraryAction)
            alertController.addAction(cameraAction)
            alertController.addAction(cancelAction)
                
            self.presentViewController(alertController, animated: true, completion: nil)

        } else {
            let alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext)
        
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)

        feedItem.image = imageData
        feedItem.caption = "Trevor's Picture Caption"
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        feedArray.append(feedItem)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.collectionView.reloadData()
        
    }
    
    // UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCell
        
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        cell.imageView.image = UIImage(data: thisItem.image!)
        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        let filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    // Helper funcitons
    func takePicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        // Select Camera as the source
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.allowsEditing = false
        self.presentViewController(imagePickerController, animated: true, completion: nil)

    }
    
    func openPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        // Select PhotoLibrary as the source
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.allowsEditing = false
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }



}
