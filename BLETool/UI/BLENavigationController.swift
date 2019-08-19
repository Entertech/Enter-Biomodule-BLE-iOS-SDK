//
//  BLENavigationController.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit

class BLENavigationController: UINavigationController {

    @IBAction func handleLongPressed(_ sender: UILongPressGestureRecognizer) {
        self.performSegue(withIdentifier: "presentFileList", sender: self)
    }
}
