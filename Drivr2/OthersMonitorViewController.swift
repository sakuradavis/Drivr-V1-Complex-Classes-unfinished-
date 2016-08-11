//
//  OthersMonitorViewController.swift
//  Drivr2
//
//  Created by sakura davis on 8/8/16.
//  Copyright © 2016 SakuraDavis. All rights reserved.


import UIKit
import CoreFoundation
import CoreLocation
import MapKit
import Parse
import CoreMotion

typealias PFQueryArrayResult = ([PFObject]?, NSError?) -> Void


class OthersMonitorViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var trackingNumberLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var speedLabel: UILabel!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var thereShouldBeATimer : Bool = false
    var locationToCompareTo: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        errorLabel.text = ""
        trackingNumberLabel.text = ""
        speedLabel.text = ""
        accelerationLabel.text = ""

        
        //Setup our Map View
        theMap.delegate = self
        theMap.mapType = MKMapType.Satellite
        thereShouldBeATimer = false
        
        let screenWidth = view.bounds.width
        print(String(screenWidth))
        if screenWidth == 320.0 {
            self.speedLabel.font = speedLabel.font.fontWithSize(24)
            self.accelerationLabel.font = accelerationLabel.font.fontWithSize(24)
            self.trackingNumberLabel.font = speedLabel.font.fontWithSize(25)
            print("adjusted for 5")
            
        }
        else if screenWidth == 375.0 {
            
            self.speedLabel.font = speedLabel.font.fontWithSize(24)
            self.accelerationLabel.font = accelerationLabel.font.fontWithSize(24)
            self.trackingNumberLabel.font = speedLabel.font.fontWithSize(24)
            print("adjusted for 6")

            
            
        }
        else if screenWidth == 414.0 {
            
            self.speedLabel.font = speedLabel.font.fontWithSize(25)
            self.accelerationLabel.font = accelerationLabel.font.fontWithSize(25)
            self.trackingNumberLabel.font = speedLabel.font.fontWithSize(25)
            print("adjusted for 6plus")

            
        }
        
    }
    
    
    //
    //
    //
    //MARK: INITIALIZING A SEARCH
    //
    //
    //
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        thereShouldBeATimer = false
        locationToCompareTo = ""
        let text = searchBar.text
        //IF THE INPUT TEXTFIELD HAS CONTENT
        if let text = text {
            //ATTEMPT A SEARCH WITH THE CONTENT!
            print("about to search")
            searchForDrive(text)
            
        }
        self.view.endEditing(true)
    }
    
    
    
    func searchForDrive(search: String) {
        //CHECK PARSE FOR THAT DRIVE AND RETURN QUERIED RESULTS
        thereShouldBeATimer = false
        ParseHelper.searchDrives(search, completionBlock: actionAfterSearch)
    }
    
    
    //
    //
    //
    //MARK: AFTER SEARCH RESULTS: UPDATE UI TO REFLECT IF DRIVE EXISTS OR NOT.
    //
    //
    //
    
    
    func actionAfterSearch(results: [PFObject]?, error: NSError?) {
        
        //if error is not nill, and exists,
        if error != nil {
            errorLabel.text = "Error: There was an error while searching for that drive."
            //alert
        }
            //if error IS nil, our query was a success! lets see results
        else {
            let length = results?.count
            //IF RESULTS DONT EXIST
            if length == 0 {
                thereShouldBeATimer = false
                errorLabel.text = "Error: No such drive."
                emptyLabels()
                
            }
                //results do exist

            else {
                errorLabel.text = "Found drive: Trying to fetch live data now..."
                let resultObj = results![0]
                if let drive = resultObj as? Drive {
                    //Cast PFObject result to a Drive
                    let driveID = drive.uniqueNum
                    //Update UI with that drive
                    thereShouldBeATimer = true
                    updateMonitorContinuously(driveID!)
                }
                else{
                        print("result not drive?!")
                }
            }            
        }
        
    }
    
    
    //
    //
    //
    //MARK: FETCHING UPDATED DATA FOR EXISTING DRIVE
    //
    //
    //
    
    
    func updateMonitorContinuously(drive: String) {
        //every five seconds, get new data!
        let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.updateDrive), userInfo: drive, repeats: true)
    }
    
    
    
    func updateDrive(timer: NSTimer) {
        if thereShouldBeATimer == true {
            var drive = timer.userInfo as! String
            //get query containing updated drive
            ParseHelper.returnUpdatedDrive(drive, completionBlock: actionAfterGettingUpdatedDrive)
            
        }
        else {
            timer.invalidate()
        }
        
       
    }
    
    //
    //
    //
    //MARK: CALL UI UPDATE FUNCTIONS DEPENDING UPON WHETHER THE DRIVE IS ACTIVE OR NOT
    //
    //
    //
    
    
    func actionAfterGettingUpdatedDrive(results: [PFObject]?, error: NSError?) {
        
        //Get the updated drive
        let obj = results![0]
        
        if let drive = obj as? Drive {
            
            //Get the current data
            errorLabel.text = ""
            let number = drive.uniqueNum
            let currentSpeed = Double(drive.currentSpeed!)
            let currentAcc = Double(drive.currentAcceleration!)
            var arrayLocations : [String] = []
            for nsstring in drive.arrayLocations!{
                let string = String(nsstring)
                arrayLocations.append(string)
            }
            
            let currentLocation = arrayLocations.last
            
           // if this is the first fetch, update the UI normally and set compareString
            if locationToCompareTo == "" {
                updateUILabels(number!, mph: currentSpeed, acceleration: currentAcc)
                updateMap(arrayLocations)
                locationToCompareTo = currentLocation!
            }
            //if this is not the first fetch, check the strings match. if the strings match, update labels but also error warning. if the strings are different, just update ui labels, no error
            else if locationToCompareTo != "" {
                if locationToCompareTo == currentLocation {
                    updateUILabels(number!, mph: currentSpeed, acceleration: currentAcc)
                    updateMap(arrayLocations)
                    errorLabel.text = "Warning: This drive may not be in session currently."
                }
                else if locationToCompareTo != currentLocation {
                    updateUILabels(number!, mph: currentSpeed, acceleration: currentAcc)
                    updateMap(arrayLocations)
                    errorLabel.text = ""
                }
            }
            
            
        }
        
    }
    
    //
    //
    //
    //MARK: NUMBER FUNCTIONS FOR UI LABELS
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
    //
    //
    //MARK: UPDATING UI LABELS
    //
    //
    //
    
    func emptyLabels() {
        speedLabel.text = "Speed: "
        accelerationLabel.text = "Acceleration: "
        trackingNumberLabel.text = "Tracking Number: "
        
    }
    

    func updateUILabels(num: String, mph: Double, acceleration: Double) {
        
        searchBar.text = ""
        trackingNumberLabel.text = "Tracking Number: " + num
        
        //PRINT SPEED, rounding appropriately
        if mph >= 100 {
            var mphString = doubleToIntToShortString(mph)
            speedLabel.text = "Speed: " + mphString + " mph"
        }
        else {
            var mphString = doubleToShortString(mph)
            speedLabel.text = "Speed: " + mphString + " mph"
        }
       
        //PRINT ACCELERATION, rounding appropriately
        if acceleration >= 100 || acceleration <= -100 {
            var accString = doubleToIntToShortString(acceleration)
            accelerationLabel.text = "Acceleration: " + accString + "mph/s"
            
        }
        else {
            var accString = doubleToShortString(acceleration)
            accelerationLabel.text = "Acceleration: " + accString + "mph/s"
            
        }
    }
    
    
    //
    //
    //
    //MARK: CONVERTING STRINGS TO LOCATIONS
    //
    //
    //
    
    func convertStringsToLocations(arrayStrings: [String]) -> [CLLocation] {
        //create empty array of cllocations
        var arrayLocations = [CLLocation]()
        
        for string in arrayStrings {
            //for every string, get lat/long and save as strings
            let arrayOfLatLongStrings = string.componentsSeparatedByString("/")
            let latString = arrayOfLatLongStrings[0]
            let longString = arrayOfLatLongStrings[1]
            //then cast lat long as doubles
            let lat = Double(latString)
            let long = Double(longString)
            //make new cllocation from the lat/long
            let newLocation = CLLocation(latitude: lat!, longitude: long!)
            //add to array
            arrayLocations.append(newLocation)
        }
        return arrayLocations
    }
    
    //
    //
    //
    //MARK: UPDATING THE MAP
    //
    //
    //
    
    func updateMap(locations: [String]) {
        //convert arraystrings to array cllocations!
        let arrayLocations = convertStringsToLocations(locations)
        let currentLocation : CLLocation = arrayLocations.last!
        
        let spanX = 0.007
        let spanY = 0.007
        var newRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion, animated: true)
        
        if (arrayLocations.count > 1){
            var sourceIndex = arrayLocations.count - 1
            var destinationIndex = arrayLocations.count - 2
            
            let c1 = arrayLocations[sourceIndex].coordinate
            let c2 = arrayLocations[destinationIndex].coordinate
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
 
}
