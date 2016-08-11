//
//  OwnMonitorViewController.swift
//  Drivr2
//
//  Created by sakura davis on 8/8/16.
//  Copyright © 2016 SakuraDavis. All rights reserved.
//

import UIKit
import CoreFoundation
import CoreLocation
import MapKit
import Parse
import CoreMotion

class OwnDriveViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!

    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var trackingNumberLabel: UILabel!
    
    let motionmanager = CMMotionManager()
    var manager:CLLocationManager!
    
    //keep track of recorded data so we know when we can calculate acceleration
    var myLocations:[CLLocation] = []
    var mySpeeds:[Double] = []
    var myAccelerations: [Double] = []
    var myTimesRecorded: [CFAbsoluteTime] = []
    
    let newDrive = Drive()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        newDrive.initOnParse()
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 0.5
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup our Map View
        theMap.delegate = self
        theMap.mapType = MKMapType.Satellite
        theMap.showsUserLocation = true
        
        let screenWidth = view.bounds.width
        print(String(screenWidth))
        if screenWidth == 320.0 {
            self.speedLabel.font = speedLabel.font.fontWithSize(78)
            self.accelerationLabel.font = accelerationLabel.font.fontWithSize(78)
            self.trackingNumberLabel.font = speedLabel.font.fontWithSize(20)
            print("adjusted for 5")

        }
        else if screenWidth == 375.0 {
            self.speedLabel.font = speedLabel.font.fontWithSize(98)
            self.accelerationLabel.font = accelerationLabel.font.fontWithSize(98)
            self.trackingNumberLabel.font = speedLabel.font.fontWithSize(25)
            print("adjusted for 6")
            
            
        }
        else if screenWidth == 414.0 {
            self.speedLabel.font = speedLabel.font.fontWithSize(120)
            self.accelerationLabel.font = accelerationLabel.font.fontWithSize(120)
            self.trackingNumberLabel.font = speedLabel.font.fontWithSize(25)
            print("adjusted for 6plus")
            
        }
        

        
    }

    
    
    //
    //
    //
    //TIMER FUNCTIONS
    //
    //
    //
    
    private var start_: NSTimeInterval = 0.0;
    private var end_: NSTimeInterval = 0.0;
    
    func start() {
        start_ = NSDate().timeIntervalSince1970;
    }
    
    func stop() {
        end_ = NSDate().timeIntervalSince1970;
    }
    
    func durationSeconds() -> NSTimeInterval {
        return end_ - start_;
    }
    
    //
    //
    //
    //UNIT CONVERSION FUNCTIONS
    //
    //
    //
    
    func convertFromMetersPerSecToMph(metersPerSec: Double) -> Double{
        var metersperhour = metersPerSec * 3600
        var mph = metersperhour * 0.000621371
        return mph
    }
    
    //
    //
    //
    //ROUNDING FUNCTIONS
    //
    //
    //
    
    //round to one decimal point
    func roundToDecimal(num: Double) -> Double{
        var roundedNum = Double(round(10*num)/10)
        return roundedNum
    }
    
    //round dec to int if over 100
    func roundToInt(num: Double) -> Int{
        var int = Int(num)
        return int
    }
    
    //
    //
    //
    //NUMBER TO STRING CONVERSION FUNCTIONS
    //
    //
    //
    
    //double to string
    func doubleToShortString(num: Double) -> String {
        var roundedNum = roundToDecimal(num)
        var numString = String(roundedNum)
        return numString
    }
    
    //double to int to string
    func doubleToIntToShortString(num: Double) -> String {
        var roundedNum = roundToInt(num)
        var numString = String(roundedNum)
        return numString
    }
//    
//    func calculateAverageSpeedToShortString(speeds: [Double]) -> String {
//        //CALCULATE AVG SPEED FROM LIST
//        var sumspeeds = 0.0
//        for i in speeds {
//            sumspeeds = sumspeeds + i
//        }
//        var numSpeeds = mySpeeds.count
//        var numSpeedsDouble = Double(numSpeeds)
//        var avgspeed = sumspeeds / numSpeedsDouble
//        //AVG SPEED STRING
//        if avgspeed == 0.0{
//            var averageSpeedString = "0"
//            return averageSpeedString
//        }
//        else if avgspeed >= 100.0 {
//            var averageSpeedString = doubleToIntToShortString(avgspeed)
//            return averageSpeedString
//            
//        }
//        else {
//            var averageSpeedString = doubleToShortString(avgspeed)
//            return averageSpeedString
//        }
//        
//    }
    
    
    //
    //
    //
    //CALCULATION FUNCTIONS
    //
    //
    //
    
    func calculateAcceleration(vf: Double, vi: Double, timePassed: NSTimeInterval) -> Double {
        var accelerationInMphPerS = (vf - vi) / timePassed
        return accelerationInMphPerS
        
    }
    
    
    //
    //
    //
    //UI  UPDATE FUNCTIONS
    //
    //
    //
    func updateSpeedLabel (mph: Double ) {
        if mph >= 100 {
            var mphString = doubleToIntToShortString(mph)
            speedLabel.text =  mphString
        }
        else {
            var mphString = doubleToShortString(mph)
            speedLabel.text =  mphString
        }
    }
    
    func updateAccelerationLabel (mphs: Double ) {
        if mphs >= 100 {
            var mphsString = doubleToIntToShortString(mphs)
            accelerationLabel.text =  mphsString
        }
        else {
            var mphsString = doubleToShortString(mphs)
            accelerationLabel.text =  mphsString
        }
    }
    
    
    //
    //
    //
    //PROTOCOL TO FOLLOW FOR EVERY LOCATION UPDATE
    //
    //
    //
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        //RECORD NEW LOCATION
        myLocations.append(locations[0])
        newDrive.addLocationToArray(locations[0])

        //SET TRACKING NUMBER LABEL
        let num = newDrive.uniqueNum
        if let num = num {
            trackingNumberLabel.text = "Tracking Number: " + num
        }
        
        //KNOW IF SPEED EXISTS
        var speedExists : Bool
        if (locations[0].speed > 0) {
            speedExists = true
        }
        else {
            speedExists = false
        }
        
        
        
        //IF THIS IS THE FIRST SPEED RECORDING
        if mySpeeds.count==0{
            //START THE TIMER UNTIL THE NEXT RECORDING
            start()
            //IF THE SPEED IS NOT 0, convert to mph, save it to the local array, update the drive's speed property, and update the speed label. Also, acceleration is equal to speed so also update that.
            if speedExists == true {
                var mps = locations[0].speed
                var mph = convertFromMetersPerSecToMph(mps)
                mySpeeds.append(mph)
                newDrive.updateSpeed(mph)
                updateSpeedLabel(mph)
                myAccelerations.append(mph)
                newDrive.updateAcceleration(mph)
                updateAccelerationLabel(mph)
                
                
            }
            //IF SPEED IS 0, ADD 0 TO LIST, UPDATE SPEED TO 0 AND SET SPEED/ACC LABEL TO 0
            else{
                mySpeeds.append(0.0)
                newDrive.updateSpeed(0.0)
                speedLabel.text = "0.0"
                myAccelerations.append(0.0)
                newDrive.updateAcceleration(0.0)
                accelerationLabel.text = "0.0"
            }
        }
        //ELSE (THERE WAS A SPEED RECORDING BEFORE THIS ONE) STOP THE TIMER, MEASURE ACCELERATION AND UPDATE ALL INFO!
        else {
            stop()
            //IF SPEED IS NOT 0, CONVERT IT, SAVE IT TO LOCAL ARRAY, UPDATE SPEED OF DRIVE, AND UPDATE SPEED LABEL
            //THEN, CALCULATE ACCELERATION
            if speedExists == true {
                var mph = convertFromMetersPerSecToMph(locations[0].speed)
                mySpeeds.append(mph)
                newDrive.updateSpeed(mph)
                updateSpeedLabel(mph)
                var currentspeedindex = mySpeeds.count-1
                var prevspeedindex = currentspeedindex - 1
                var currentspeed = mySpeeds[currentspeedindex]
                var prevspeed = mySpeeds[prevspeedindex]
                var changeintime = durationSeconds()
                var acceleration = calculateAcceleration(currentspeed, vi: prevspeed, timePassed: changeintime)
                //IF ACCELERATION EXISTS, CONVERT IT, SAVE TO LOCAL ARRAY, UPDATE ACC OF DRIVE, AND UPDATE LABEL
                if acceleration != 0.0 {
                    myAccelerations.append(acceleration)
                    newDrive.updateAcceleration(acceleration)
                    updateAccelerationLabel(acceleration)
                }
                //ELSE (IF ACCELERATION WAS 0), ADD 0 TO ARRAY AND UPDATE ACC/ACCLABEL TO 0.0
                else {
                    myAccelerations.append(0.0)
                    newDrive.updateAcceleration(0.0)
                    accelerationLabel.text = "0.0"
                }
                
                
            }
            //ELSE (IF THE SPEED WAS 0), ADD 0 TO ARRAY, UPDATE SPEED TO 0 AND UPDATE LABEL TO 0. CALCULATE ACC WITH 0 AS VF.
            else{
                mySpeeds.append(0.0)
                newDrive.updateSpeed(0.0)
                speedLabel.text = "0.0"
                var indexofpreviousspeed = mySpeeds.count-2
                var previousspeed = mySpeeds[indexofpreviousspeed]
                var changeintime = durationSeconds()
                var acceleration = calculateAcceleration(0.0, vi: previousspeed, timePassed: changeintime)
                //IF ACCELERATION EXISTS, CONVERT IT, SAVE TO LOCAL ARRAY, UPDATE ACC OF DRIVE, AND UPDATE LABEL
                if acceleration != 0.0{
                    myAccelerations.append(acceleration)
                    newDrive.updateAcceleration(acceleration)
                    updateAccelerationLabel(acceleration)

                }
                //ELSE (IF ACCELERATION WAS 0), ADD 0 TO ARRAY AND UPDATE ACC/ACCLABEL TO 0.0
                else {
                    myAccelerations.append(0.0)
                    newDrive.updateAcceleration(0.0)
                    accelerationLabel.text = "0.0"
                }
            }
            start()
            //START TIMER AGAIN
            
        }
        
        //UPDATING MAP
        let spanX = 0.007
        let spanY = 0.007
        var newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion, animated: true)
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            theMap.addOverlay(polyline)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        manager.stopUpdatingLocation()
        if motionmanager.accelerometerAvailable {
            motionmanager.stopAccelerometerUpdates()
        }

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 

}
