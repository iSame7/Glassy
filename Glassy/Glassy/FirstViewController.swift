//
//  FirstViewController.swift
//  Glassy
//
//  Created by Sameh Mabrouk on 7/5/15.
//  Copyright (c) 2015 smapps. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var button:UIButton = UIButton()
        button.frame=self.view.frame
        button.setTitle("Oen Glassy", forState: UIControlState.Normal)
        button.addTarget(self, action: Selector("goToViewController"), forControlEvents: UIControlEvents.TouchUpInside)
        button.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.view.addSubview(button)


    }

    func goToViewController(){

        self.navigationController?.pushViewController(ViewController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
