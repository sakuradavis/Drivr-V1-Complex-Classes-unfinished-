//
//  ParseHelper.swift
//  Drivr2
//
//  Created by sakura davis on 8/8/16.
//  Copyright © 2016 SakuraDavis. All rights reserved.
//

import Foundation
import Parse

//We're going to introduce a ParseHelper.swift file that will contain most of our code that's responsible for talking to our Parse server. That way we can avoid bloated view controllers.

//We are going to wrap all of our helper methods into a class called ParseHelper (call ParseHelper.____)

class ParseHelper {

    //MARK: CONSTANTS
    //Parse[ClassName][FieldName].
    
    
    // Drive
    static let ParseDriveClass       = "Drive"
    static let ParseDriveUniqueNum      = "uniqueNum"
    static let ParseDriveSpeed      = "currentSpeed"
    static let ParseDriveAcceleration      = "currentAcceleration"
    static let ParseDriveLocations     = "arrayLocations"
    
    
    
    static func initWithParameters (drive: Drive) {
        drive.uniqueNum = String(Int(arc4random_uniform(999999999)))
        drive.currentSpeed = -1.0
        drive.currentAcceleration = -1.0
        drive.arrayLocations = []
        drive.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("error exists", String(error))
            }
            else {
                //if saves successfully,
                print("new drive saved to parse with id " + drive.uniqueNum!)
            }
        }
    }

    
    static func addLocationToArrayOfDriveOnParse(drive: Drive, cllocation: CLLocation) {
        //convert cllocation to string
        let coordString = String(cllocation.coordinate)
        let stringArr = coordString.componentsSeparatedByString(" ")
        var lat = stringArr[1]
        let latArr = lat.componentsSeparatedByString(",")
        lat = latArr[0]
        var long = stringArr[3]
        let longArr = long.componentsSeparatedByString(")")
        long = longArr[0]
        let coordinateStringToUpload = lat + "/" + long
        
        
        drive.arrayLocations?.append(coordinateStringToUpload)
        drive.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("error exists", String(error))
            }
            else {
                //if saves successfully
                //  print("no error - drive saved with speed")
            }
        }
    
    }
    
    
    static func updateSpeedOfDrive (drive: Drive, speed: Double) {
        drive.currentSpeed = speed
        drive.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("error exists", String(error))
            }
            else {
                //if saves successfully
              //  print("no error - drive saved with speed")
            }
        }
        
    }
    
    static func updateAccelerationOfDrive (drive: Drive, acceleration: Double) {
        drive.currentAcceleration = acceleration
        drive.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("error exists", String(error))
            }
            else {
               //print("success saving acceleration")
            }
        }
    }
    
    
    static func searchDrives(searchNum: String, completionBlock: PFQueryArrayResultBlock)
        -> PFQuery {
            let query = Drive.query()!.whereKey("uniqueNum", equalTo: searchNum)
            
            query.findObjectsInBackgroundWithBlock(completionBlock)
            
            return query
    }

    
    static func returnUpdatedDrive(driveNum: String, completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        let query = Drive.query()!.whereKey(ParseHelper.ParseDriveUniqueNum,
                                            matchesRegex: driveNum, modifiers: "i")
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        return query
    }
}