//
//  Drive.swift
//  Drivr
//
//  Created by sakura davis on 7/15/16.
//  Copyright © 2016 SakuraDavis. All rights reserved.
//

import Foundation
import Parse



// To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Drive : PFObject, PFSubclassing {
    
    @NSManaged var arrayLocations: [NSString]?
    @NSManaged var currentSpeed: NSNumber?
    @NSManaged var currentAcceleration: NSNumber?
    @NSManaged var uniqueNum: String?

    
    
    
    // init and initialize are purely boilerplate code - copy these two into any custom Parse class that you're creating.
    override init () {
        super.init()
        print("new drive built locally")
    }
    
    class func parseClassName() -> String! {
        return "Drive"
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
     
    func addLocationToArray (cllocation: CLLocation) {
        ParseHelper.addLocationToArrayOfDriveOnParse(self, cllocation: cllocation)
    }
    
    func initOnParse() {
        ParseHelper.initWithParameters(self)
    }
    
    func updateSpeed (speedToAdd: Double) {
        
        ParseHelper.updateSpeedOfDrive(self, speed: speedToAdd)

 
    }
    
    
    func updateAcceleration (accelerationToAdd: Double) {
        ParseHelper.updateAccelerationOfDrive(self, acceleration: accelerationToAdd)

    } 
    
    
    
    
}











