//
//  ViewController.swift
//  Glassy
//
//  Created by Sameh Mabrouk on 6/27/15.
//  Copyright (c) 2015 smapps. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewAccessibilityDelegate {

    var glassScrollView:GlassyScrollView!
    var glassScrollView1:GlassyScrollView!
    var glassScrollView2:GlassyScrollView!
    var glassScrollView3:GlassyScrollView!

    var page:CGFloat!

    var viewScroller:UIScrollView!


    override func viewDidLoad() {
        super.viewDidLoad()

        page=0

        //showing white status
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        //background
        self.view.backgroundColor = UIColor.blackColor()

        let blackSideBarWidth:CGFloat=2

        viewScroller=UIScrollView(frame: CGRectMake(0, 0, self.view.frame.size.width + 2*blackSideBarWidth, self.view.frame.size.height))
        viewScroller.pagingEnabled=true
        viewScroller.delegate=self
        viewScroller.showsHorizontalScrollIndicator=false
        self.view.addSubview(viewScroller)

        glassScrollView1=GlassyScrollView(frame: self.view.frame, backgroundImage: UIImage(named: "New York")!, blurredImage: nil, viewDistanceFromBottom: 120, foregroundView: customView())

        glassScrollView2=GlassyScrollView(frame: self.view.frame, backgroundImage: UIImage(named: "New York2")!, blurredImage: nil, viewDistanceFromBottom: 120, foregroundView: customView())

        glassScrollView3=GlassyScrollView(frame: self.view.frame, backgroundImage: UIImage(named: "Cairo")!, blurredImage: nil, viewDistanceFromBottom: 120, foregroundView: customView())

        viewScroller.addSubview(glassScrollView1)
        viewScroller.addSubview(glassScrollView2)
        viewScroller.addSubview(glassScrollView3)

        viewScroller.contentSize=CGSizeMake(3 * viewScroller.frame.size.width, self.view.frame.size.height)

        glassScrollView1.setViewFrame(self.view.frame)
        glassScrollView2.setViewFrame(self.view.frame)
        glassScrollView3.setViewFrame(self.view.frame)

        glassScrollView2.setViewFrame(CGRectOffset(glassScrollView2.bounds, viewScroller.frame.size.width, 0))
        glassScrollView3.setViewFrame(CGRectOffset(glassScrollView3.bounds, 2*viewScroller.frame.size.width, 0))

        viewScroller.contentOffset = CGPointMake(page * viewScroller.frame.size.width, viewScroller.contentOffset.y)



    }

    override func viewWillAppear(animated: Bool) {

    }

    override func viewWillLayoutSubviews() {
    }

    func customView() -> UIView{

        let view:UIView = UIView(frame: CGRectMake(0, 0, 320, 705))

        let label:UILabel = UILabel(frame: CGRectMake(5, 5, 310, 120))
        label.text = arc4random_uniform(20).description + "℉"
        label.textColor = UIColor.whiteColor()
        label.font=UIFont(name: "HelveticaNeue-UltraLight", size: 120)
        label.shadowColor=UIColor.blackColor()
        label.shadowOffset=CGSizeMake(1, 1)
        view.addSubview(label)

        let area1:UIView = UIView(frame: CGRectMake(5, 140, 310, 125))
        area1.layer.cornerRadius=3
        area1.backgroundColor=UIColor(white: 0, alpha: 0.15)
        view.addSubview(area1)

        let area2:UIView = UIView(frame: CGRectMake(5, 270, 310, 300))
        area2.layer.cornerRadius=3
        area2.backgroundColor=UIColor(white: 0, alpha: 0.15)
        view.addSubview(area2)

        let area3:UIView = UIView(frame: CGRectMake(5, 575, 310, 125))
        area3.layer.cornerRadius=3
        area3.backgroundColor=UIColor(white: 0, alpha: 0.15)
        view.addSubview(area3)

        return view
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let ratio:CGFloat = scrollView.contentOffset.x/scrollView.frame.size.width
        page=ratio

        if ratio > -1 && ratio < 1 {

            glassScrollView1.scrollHorizontalRatio(-ratio)
        }
        if ratio > 0 && ratio < 2 {

            glassScrollView2.scrollHorizontalRatio(-ratio + 1)
        }
        if ratio > 1 && ratio < 3 {

            glassScrollView3.scrollHorizontalRatio(-ratio + 2)
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {

        let glass:GlassyScrollView = currentGlassyScrollView()

        //this is just a demonstration without optimization
        glassScrollView1.scrollVerticallyToOffset(glass.foregroundScrollView.contentOffset.y)
        glassScrollView2.scrollVerticallyToOffset(glass.foregroundScrollView.contentOffset.y)
        glassScrollView3.scrollVerticallyToOffset(glass.foregroundScrollView.contentOffset.y)
    }

    func currentGlassyScrollView() ->GlassyScrollView{

        var glass:GlassyScrollView=glassScrollView1

        switch page{
        case 0:
            glass = glassScrollView1
        case 1:
            glass = glassScrollView2
        case 2:
            glass = glassScrollView3
        default:
            break
            
        }
        return glass
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
