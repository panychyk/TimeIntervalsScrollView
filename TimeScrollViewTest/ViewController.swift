//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var scrollView: CTimeScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = self.view as! CTimeScrollView
        scrollView.timeIntervals = .mins15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

