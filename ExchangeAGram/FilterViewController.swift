//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Trevor Griffin on 1/29/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    let kIntensity = 0.7
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    let tmp = NSTemporaryDirectory()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        self.view.addSubview(collectionView)
        
        filters = photoFilters()        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FilterCell
        
//        if cell.imageView.image == nil {
            cell.imageView.image = placeHolderImage
            let filterQueue:dispatch_queue_t = dispatch_queue_create("filter_queue", nil)
            dispatch_async(filterQueue, { () -> Void in
//                let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail!, filter: self.filters[indexPath.row])
                let filterImage = self.getCachedImage(Int(self.thisFeedItem.imageID!), indexPath.row)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
            
//        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
 
        createUIAlertController(indexPath)
        
    }
    
    // UIAlert Helper Functions
    func createUIAlertController (indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        let textField = alert.textFields![0]
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
        
            self.shareToFacebook(indexPath)
            
            let text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text!)
        }
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            let text = textField.text

            self.saveFilterToCoreData(indexPath, caption: text!)
        }
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
        }
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Helper funcs
    
    func saveFilterToCoreData (indexPath: NSIndexPath, caption: String) {
    
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image!, filter: self.filters[indexPath.row])
        
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        
        self.thisFeedItem.image = imageData
        
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        
        self.thisFeedItem.thumbNail = thumbNailData
        
        self.thisFeedItem.caption = caption
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func shareToFacebook (indexPath: NSIndexPath) {
        
        // Insert code to share picture to facebook
        // See example: http://www.brianjcoleman.com/tutorial-how-to-share-in-facebook-sdk-4-0-for-swift/

    }
    
    func photoFilters () -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        
        let photoEffect = CIFilter(name: "CIPhotoEffectInstant")
        
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls!.setValue(0.5, forKey: kCIInputSaturationKey)
        let sepia = CIFilter(name: "CISepiaTone")
        sepia!.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp!.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp!.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")

        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite!.setValue(sepia!.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette!.setValue(composite!.outputImage, forKey: kCIInputImageKey)
        vignette!.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette!.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)

        
        // The color clamp filter is not working for some reason 2-3-2016
        return [blur!, instant!, noir!, transfer!, unsharpen!, monochrome!, photoEffect!, colorControls!, sepia!, /*colorClamp!,*/ composite!, vignette!]
        
    }
    
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage!
        
        let extent = filteredImage.extent
        let cgImage:CGImage = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage
    }
    
    func cacheImage(imageNumber: Int, _ filterNumber: Int) {
        let fileName = "\(imageNumber)_\(filterNumber)"
        let uniquePath = NSURL.fileURLWithPathComponents([tmp, fileName])

        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath!.path!) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[filterNumber]
            let image = filteredImageFromImage(data!, filter: filter)
            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(uniquePath!.path!, atomically: true)
        }
    }
    
    func getCachedImage (imageNumber: Int, _ filterNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)_\(filterNumber)"
        let uniquePath = NSURL.fileURLWithPathComponents([tmp, fileName])
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath!.path!) {
            image = UIImage(contentsOfFile: uniquePath!.path!)!
        } else {
            self.cacheImage(imageNumber, filterNumber)
            image = UIImage(contentsOfFile: uniquePath!.path!)!
        }
        return image
    }

}
