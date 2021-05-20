//
//  ViewController.swift
//  TechProject
//
//  Created by Zhalgas Yegizgarin on 8/20/19.
//  Copyright © 2019 Zhalgas Yegizgarin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    


}

