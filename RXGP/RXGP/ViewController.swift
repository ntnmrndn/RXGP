//
//  ViewController.swift
//  RXGP
//
//  Created by Antoine Marandon on 22/11/2014.
//
//


import UIKit
import CoreLocation

class ViewController: UIViewController,  CLLocationManagerDelegate  {
    let locationManager = CLLocationManager()
    var dateFormater = NSDateFormatter()
    var previouslySavedLocation : CLLocation?
    let outputFile = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask , true).first as String).stringByAppendingPathComponent("locations.json")
    override func viewDidLoad() {
        super.viewDidLoad()
        //        NSFileManager().createFileAtPath(outputFile, contents: nil, attributes: nil)
        dateFormater.dateFormat = "dd-MM-yyyy HH:mm"
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        self.view.backgroundColor = UIColor.brownColor()
    }

    func updateViewForLastLocation(location: CLLocation) {
        let locationTime = -location.timestamp.timeIntervalSinceNow
        var alpha : CGFloat
        if (locationTime < 60) { // 1 min
            alpha = 1
        } else if (locationTime < 60 * 5) {
            alpha = 0.9
        } else if (locationTime < 60 * 30) {
            alpha = 0.8
        } else if (locationTime < 60 * 60 * 2) {
            alpha = 0.75;
        } else if (locationTime < 60 * 60 * 8) {
            alpha = 0.5
        } else if (locationTime < 60 * 60 * 24) {
            alpha = 0.25
        } else  {
            alpha = 0.15
        }
        println("\(location.timestamp.timeIntervalSinceNow)")
        println("\(location.coordinate.latitude) : \(location.coordinate.longitude) - \(location.altitude) +-  \(location.horizontalAccuracy) : \(location.horizontalAccuracy) ")
        if location.horizontalAccuracy > 1_000_000 { // 1000km
            self.view.backgroundColor = UIColor(red: 1, green:0, blue: 0, alpha: alpha)
        } else if (location.horizontalAccuracy > 100_000) {
        } else if (location.horizontalAccuracy > 50_000) { //50 km
            self.view.backgroundColor = UIColor(red: 1, green: 70/255, blue: 0, alpha: alpha)
        } else if (location.horizontalAccuracy > 10_000) { // 10 km
            self.view.backgroundColor = UIColor(red: 1, green: 125/255, blue: 0, alpha: alpha)
        } else if (location.horizontalAccuracy > 1_000) { // 1 km
            self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: alpha)
        } else if (location.horizontalAccuracy > 500) { // 500m
            self.view.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: alpha)
        } else if (location.horizontalAccuracy > 100) { // 100 m
            self.view.backgroundColor = UIColor(red: 0, green: 1, blue: 0.5, alpha: alpha)
        } else { // best
            self.view.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: alpha)
        }
    }


    func shouldSaveLocation(location: CLLocation) -> Bool {
        if (location.horizontalAccuracy > 100_000) { // over 100 km  ...
            return false;
        }
        if (self.previouslySavedLocation == nil) {
            return true;
        }
        if (previouslySavedLocation!.horizontalAccuracy - location.horizontalAccuracy > 0) { // we lost accuracy
            let previousTimestamp = previouslySavedLocation?.timestamp
            return location.timestamp.timeIntervalSinceDate(previousTimestamp!) > 60 * 30
        }
        if (self.previouslySavedLocation!.horizontalAccuracy - location.horizontalAccuracy > 0) { //accuracy improved
            return previouslySavedLocation?.distanceFromLocation(location) > 50; // over 50m difference == we save
        } else {
            return false;
        }
    }

    func appendDataToExportFile(data: NSData) {
        NSFileManager().createFileAtPath(outputFile, contents: nil, attributes: nil)
        var fileHandler: AnyObject! = NSFileHandle(forUpdatingAtPath: outputFile)

        fileHandler.seekToEndOfFile()
        fileHandler.writeData(data)
        fileHandler.closeFile()
    }

    func saveLocation(location: CLLocation) {
        previouslySavedLocation = location;
        var flashView = UIView(frame: self.view.frame);
        flashView.backgroundColor = UIColor.whiteColor();
        self.view.window?.addSubview(flashView);
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            flashView.alpha = 0
            }) { (Bool) -> Void in
                flashView.removeFromSuperview()
        }
        let jsonObject: AnyObject = [
            "time" : dateFormater.stringFromDate(location.timestamp),
            "latitude" : location.coordinate.latitude,
            "longitude" : location.coordinate.longitude,
            "altidude" : location.altitude,
            "accuracy" : location.horizontalAccuracy,
        ]
        let data = NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions(0), error: nil)
        appendDataToExportFile(data!)
    }


    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location : CLLocation = locations.last as CLLocation!
        self.updateViewForLastLocation(location)
        if (self.shouldSaveLocation(location)) {
            saveLocation(location)
        }
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.view.backgroundColor = UIColor.blueColor()
    }
    
}


