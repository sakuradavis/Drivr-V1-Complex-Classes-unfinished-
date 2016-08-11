//
//  ViewController.swift
//  Drivr2
//
//  Created by sakura davis on 8/8/16.
//  Copyright © 2016 SakuraDavis. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var trackOwnButton: UIButton!
    
    @IBOutlet weak var trackOthersButton: UIButton!
    
    @IBAction func trackOwnPressed(sender: UIButton) {
        performSegueWithIdentifier("homeToOwn", sender: sender)
    }
    @IBAction func trackOthersPressed(sender: UIButton) {
        performSegueWithIdentifier("homeToOthers", sender: sender)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenWidth = view.bounds.width
        if screenWidth == 320.0 {
            
        }
        else if screenWidth == 375.0 {
        }
        else if screenWidth == 414.0 {
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

