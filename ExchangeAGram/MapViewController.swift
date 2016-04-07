//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Trevor Griffin on 2/29/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext
        
        var itemArray: [FeedItem]
        
        do {
            itemArray = try context.executeFetchRequest(request) as! [FeedItem]
  
        } catch let error as NSError {
            
            itemArray = []
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        if itemArray.count > 0 {
            for item in itemArray {
                let location = CLLocationCoordinate2D(latitude: Double(item.latitude!), longitude: Double(item.longitude!))
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(location, span)
                mapView.setRegion(region, animated: true)
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = item.caption
                mapView.addAnnotation(annotation)
            }
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
