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
        
        cell.imageView.image = filteredImageFromImage(thisFeedItem.image!, filter: filters[indexPath.row])
        
        return cell
    }

    
    // Helper funcs
    
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
}
