//
//  GlassyScrollView.swift
//  Glassy
//
//  Created by Sameh Mabrouk on 6/27/15.
//  Copyright (c) 2015 smapps. All rights reserved.
//

import UIKit

//Default Blur Settings.
let blurRadious:CGFloat = 14.0
let blurTintColor:UIColor = UIColor(white: 0, alpha: 0.3)
let blurDeltaFactor:CGFloat = 1.4

//How much the background move when scrolling.
let maxBackgroundMovementVerticle:CGFloat = 30
let maxBackgroundMovementHorizontal:CGFloat = 150

//the value of the fading space on the top between the view and navigation bar
let topFadingHeightHalf:CGFloat = 10



@objc protocol GlassyScrollViewDelegate:NSObjectProtocol{

    optional func floraView(floraView: AnyObject, numberOfRowsInSection section: Int) -> Int

    //use this to configure your foregroundView when the frame of the whole view changed
    optional func glassyScrollView(glassyScrollView: GlassyScrollView, didChangedToFrame fram: CGRect)

    //make custom blur without messing with default settings
    optional func glassyScrollView(glassyScrollView: GlassyScrollView, blurForImage image: UIImage) -> UIImage
}
class GlassyScrollView: UIView, UIScrollViewDelegate {

    private var backgroundImage: UIImage!

    //Default blurred is provided.
    private var blurredBackgroundImage: UIImage!

    //The view that will contain all the info
    private var foregroundView: UIView!

    //Shadow layers.
    private var topShadowLayer:CALayer!
    private var botShadowLayer:CALayer!

    //Masking
    private var foregroundContainerView:UIView!
    private var topMaskImageView:UIImageView!

    private var backgroundScrollView:UIScrollView!

    var foregroundScrollView:UIScrollView!

    //How much view is showed up from the bottom.
    var viewDistanceFromBottom:CGFloat!
    //set this only when using navigation bar of sorts.
    let topLayoutGuideLength:CGFloat = 0.0

    var constraitView:UIView!
    var backgroundImageView:UIImageView!
    var blurredBackgroundImageView:UIImageView!


    //delegate.
    var delegate:GlassyScrollViewDelegate!



    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, backgroundImage:UIImage, blurredImage:UIImage?, viewDistanceFromBottom:CGFloat, foregroundView:UIView) {

        super.init(frame: frame)
        
        self.backgroundImage = backgroundImage

        if blurredImage != NSNull(){

//          self.blurredBackgroundImage = blurredImage
            self.blurredBackgroundImage = backgroundImage.applyBlurWithRadius(blurRadious, tintColor: blurTintColor, saturationDeltaFactor: blurDeltaFactor, maskImage: nil)

        }
        else{

            //Check if delegate conform to protocol or not.
            if self.delegate.respondsToSelector(Selector("glassyScrollView:blurForImage:")){
                self.blurredBackgroundImage = self.delegate.glassyScrollView!(self, blurForImage: self.backgroundImage)
            }
            else{

                //implement live blurring effect.
                self.blurredBackgroundImage = backgroundImage.applyBlurWithRadius(blurRadious, tintColor: blurTintColor, saturationDeltaFactor: blurDeltaFactor, maskImage: nil)

            }
        }
        self.viewDistanceFromBottom = viewDistanceFromBottom
        self.foregroundView = foregroundView

        //Autoresize
        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth

        //Create Views
        self.createBackgroundView()
        self.createForegroundView()
//        self.createTopShadow()
        self.createBottomShadow()
    }

    func initWithFrame(){

    }

    // MARK: - Public Methods
    func scrollHorizontalRatio(ratio:CGFloat){
        
        // when the view scroll horizontally, this works the parallax magic
        backgroundScrollView.contentOffset = CGPointMake(maxBackgroundMovementHorizontal+ratio*maxBackgroundMovementHorizontal, backgroundScrollView.contentOffset.y)
    }

    func scrollVerticallyToOffset(offsetY:CGFloat){

        foregroundScrollView.contentOffset=CGPointMake(foregroundScrollView.contentOffset.x, offsetY)
    }

    // MARK: - Setters
    func setViewFrame(frame:CGRect){


        super.frame = frame

        //work background
        let bounds:CGRect = CGRectOffset(frame, -frame.origin.x, -frame.origin.y)
        backgroundScrollView.frame=bounds
        backgroundScrollView.contentSize = CGSizeMake(bounds.size.width + 2*maxBackgroundMovementHorizontal, self.bounds.size.height+maxBackgroundMovementVerticle)
        backgroundScrollView.contentOffset=CGPointMake(maxBackgroundMovementHorizontal, 0)

        constraitView.frame = CGRectMake(0, 0, bounds.size.width + 2*maxBackgroundMovementHorizontal, bounds.size.height+maxBackgroundMovementVerticle)

        //foreground
        foregroundContainerView.frame = bounds
        foregroundScrollView.frame=bounds
        foregroundView.frame = CGRectOffset(foregroundView.bounds, (foregroundScrollView.frame.size.width - foregroundView.bounds.size.width)/2, foregroundScrollView.frame.size.height - foregroundScrollView.contentInset.top - viewDistanceFromBottom)
        foregroundScrollView.contentSize=CGSizeMake(bounds.size.width, foregroundView.frame.origin.y + foregroundView.bounds.size.height)

        //Shadows
//        topShadowLayer.frame=CGRectMake(0, 0, bounds.size.width, foregroundScrollView.contentInset.top + topFadingHeightHalf)
        botShadowLayer.frame=CGRectMake(0, bounds.size.height - viewDistanceFromBottom, bounds.size.width, bounds.size.height)

//        if self.delegate.respondsToSelector(Selector("glassyScrollView:didChangedToFrame:")){
//            delegate.glassyScrollView!(self, didChangedToFrame: frame)
//        }

    }

    func setTopLayoutGuideLength(topLayoutGuideLength:CGFloat){

        if topLayoutGuideLength==0 {
            return
        }

        //set inset
        foregroundScrollView.contentInset = UIEdgeInsetsMake(topLayoutGuideLength, 0, 0, 0)

        //reposition
        foregroundView.frame = CGRectOffset(foregroundView.bounds, (foregroundScrollView.frame.size.width - foregroundView.bounds.size.width)/2, foregroundScrollView.frame.size.height - foregroundScrollView.contentInset.top - viewDistanceFromBottom)

        //resize contentSize
        foregroundScrollView.contentSize = CGSizeMake(self.frame.size.width, foregroundView.frame.origin.y + foregroundView.frame.size.height)

        //reset the offset
        if foregroundScrollView.contentOffset.y == 0{
            foregroundScrollView.contentOffset = CGPointMake(0, -foregroundScrollView.contentInset.top)
        }

        //adding new mask
        foregroundContainerView.layer.mask = createTopMaskWithSize(CGSizeMake(foregroundContainerView.frame.size.width, foregroundContainerView.frame.size.height), startFadAtTop: foregroundScrollView.contentInset.top - topFadingHeightHalf, endAtBottom: foregroundScrollView.contentInset.top + topFadingHeightHalf, topColor: UIColor(white: 1.0, alpha: 0.0), botColor: UIColor(white: 1.0, alpha: 1.0))

        //recreate shadow
        createTopShadow()

    }

    func setViewDistanceFromBottom(vDistanceFromBottom:CGFloat){

        viewDistanceFromBottom = vDistanceFromBottom

        foregroundView.frame = CGRectOffset(foregroundView.bounds, (foregroundScrollView.frame.size.width - foregroundView.bounds.size.width)/2, foregroundScrollView.frame.size.height - foregroundScrollView.contentInset.top - viewDistanceFromBottom)

        foregroundScrollView.contentSize = CGSizeMake(self.frame.size.width, foregroundView.frame.origin.y + foregroundView.frame.size.height)

        //shadows
        botShadowLayer.frame = CGRectOffset(botShadowLayer.bounds, 0, self.frame.size.height - viewDistanceFromBottom)


    }

    func setBackgroundImage(backgroundImg:UIImage, overWriteBlur:Bool, animated:Bool, interval:NSTimeInterval){

        backgroundImage = backgroundImg
        if overWriteBlur{

            blurredBackgroundImage = backgroundImg.applyBlurWithRadius(blurRadious, tintColor: blurTintColor, saturationDeltaFactor: blurDeltaFactor, maskImage: nil)
        }

        if animated{

            let previousBackgroundImageView:UIImageView = backgroundImageView
            let previousBlurredBackgroundImageView:UIImageView = blurredBackgroundImageView

            createBackgroundImageView()

            backgroundImageView.alpha = 0
            blurredBackgroundImageView.alpha=0

            // blur needs to get animated first if the background is blurred
            if previousBlurredBackgroundImageView.alpha == 1{

                UIView.animateWithDuration(interval, animations: { () -> Void in
                    self.blurredBackgroundImageView.alpha=previousBlurredBackgroundImageView.alpha
                    }, completion: { (Bool) -> Void in

                        self.backgroundImageView.alpha=previousBackgroundImageView.alpha
                        previousBackgroundImageView.removeFromSuperview()
                        previousBlurredBackgroundImageView.removeFromSuperview()

                })
            }
            else{


                UIView.animateWithDuration(interval, animations: { () -> Void in
                    self.backgroundImageView.alpha=self.backgroundImageView.alpha
                    self.blurredBackgroundImageView.alpha=previousBlurredBackgroundImageView.alpha

                    }, completion: { (Bool) -> Void in
                        previousBackgroundImageView.removeFromSuperview()
                        previousBlurredBackgroundImageView.removeFromSuperview()

                })
            }

        }

        else{
            backgroundImageView.image=backgroundImage
            blurredBackgroundImageView.image=blurredBackgroundImage
        }
    }

    func blurBackground(shouldBlur:Bool){
        if shouldBlur{
            blurredBackgroundImageView.alpha = 1
        }
        else{
            blurredBackgroundImageView.alpha = 0
        }


    }

    // MARK: - Views creation
    // MARK: - ScrollViews
    func createBackgroundView(){

        self.backgroundScrollView = UIScrollView(frame: self.frame)
        self.backgroundScrollView.userInteractionEnabled=true
        self.backgroundScrollView.contentSize = CGSize(width: self.frame.size.width + (2*maxBackgroundMovementHorizontal), height: self.frame.size.height+maxBackgroundMovementVerticle)

        self.backgroundScrollView.contentOffset = CGPointMake(maxBackgroundMovementHorizontal, 0)
        self.addSubview(self.backgroundScrollView)

        self.constraitView = UIView(frame: CGRectMake(0, 0, self.frame.size.width + (2*maxBackgroundMovementHorizontal), self.frame.size.height+maxBackgroundMovementVerticle))
        self.backgroundScrollView.addSubview(self.constraitView)

        self.createBackgroundImageView()

    }

    func createBackgroundImageView(){

        self.backgroundImageView = UIImageView(image: self.backgroundImage)
        self.backgroundImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.constraitView.addSubview(self.backgroundImageView)

        self.blurredBackgroundImageView = UIImageView(image: self.blurredBackgroundImage)
        self.blurredBackgroundImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.blurredBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.blurredBackgroundImageView.alpha=0
        self.constraitView.addSubview(self.blurredBackgroundImageView)

        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(backgroundImageView, forKey: "backgroundImageView")

        self.constraitView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundImageView]|", options: nil, metrics: nil, views: viewBindingsDict as [NSObject : AnyObject]))
        self.constraitView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundImageView]|", options: nil, metrics: nil, views: viewBindingsDict as [NSObject : AnyObject]))

        var blurredViewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        blurredViewBindingsDict.setValue(blurredBackgroundImageView, forKey: "blurredBackgroundImageView")

        self.constraitView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurredBackgroundImageView]|", options: nil, metrics: nil, views: blurredViewBindingsDict as [NSObject : AnyObject]))
        self.constraitView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurredBackgroundImageView]|", options: nil, metrics: nil, views: blurredViewBindingsDict as [NSObject : AnyObject]))
    }

    func createForegroundView(){

        self.foregroundContainerView = UIView(frame: self.frame)
        self.addSubview(self.foregroundContainerView)

        self.foregroundScrollView=UIScrollView(frame: self.frame)
        self.foregroundScrollView.delegate=self
        self.foregroundScrollView.showsVerticalScrollIndicator=false
        self.foregroundScrollView.showsHorizontalScrollIndicator=false
        self.foregroundContainerView.addSubview(self.foregroundScrollView)

        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("foregroundTapped:"))
        foregroundScrollView.addGestureRecognizer(tapRecognizer)

        foregroundView.frame = CGRectOffset(foregroundView.bounds, (foregroundScrollView.frame.size.width - foregroundView.frame.size.width)/2, foregroundScrollView.frame.size.height - viewDistanceFromBottom)
        foregroundScrollView.addSubview(foregroundView)

        foregroundScrollView.contentSize = CGSizeMake(self.frame.size.width, foregroundView.frame.origin.y + foregroundView.frame.size.height)
    }

    // MARK: - Shadow and mask layer
    func createTopMaskWithSize(size:CGSize, startFadAtTop:CGFloat, endAtBottom:CGFloat, topColor:UIColor, botColor:UIColor) -> CALayer{

        let top = startFadAtTop / size.height
        let bottom = endAtBottom / size.height

        let maskLayer:CAGradientLayer = CAGradientLayer()
        maskLayer.anchorPoint = CGPointZero
        maskLayer.startPoint = CGPointMake(0.5, 0.0)
        maskLayer.endPoint = CGPointMake(0.5, 1.0)

        maskLayer.colors = NSArray(arrayLiteral: topColor.CGColor, topColor.CGColor, botColor.CGColor, botColor.CGColor) as [AnyObject]

        maskLayer.locations = NSArray(arrayLiteral: 0.0, top, bottom, 1.0) as [AnyObject]
        maskLayer.frame = CGRectMake(0, 0, size.width, size.height)

        return maskLayer
    }

    func createTopShadow(){

        topShadowLayer = self.createTopMaskWithSize(CGSizeMake(foregroundContainerView.frame.size.width, foregroundScrollView.contentInset.top + topFadingHeightHalf), startFadAtTop:foregroundScrollView.contentInset.top + topFadingHeightHalf , endAtBottom: foregroundScrollView.contentInset.top + topFadingHeightHalf, topColor: UIColor(white: 0, alpha: 0.15), botColor: UIColor(white: 0, alpha: 0))
        self.layer.insertSublayer(topShadowLayer, below: foregroundContainerView.layer)
    }

    func createBottomShadow(){

        botShadowLayer = self.createTopMaskWithSize(CGSizeMake(self.frame.size.width, viewDistanceFromBottom), startFadAtTop:0 , endAtBottom: viewDistanceFromBottom, topColor: UIColor(white: 0, alpha: 0), botColor: UIColor(white: 0, alpha: 0.8))
        self.layer.insertSublayer(botShadowLayer, below: foregroundContainerView.layer)
    }

    // MARK: - foregroundScrollView Tap Action
    func foregroundTapped(tapRecognizer:UITapGestureRecognizer){

        let tappedPoint:CGPoint = tapRecognizer.locationInView(foregroundScrollView)

        if tappedPoint.y < foregroundScrollView.frame.size.height{

            var ratio:CGFloat!
            if foregroundScrollView.contentOffset.y == foregroundScrollView.contentInset.top{

                ratio=1
            }
            else{

                ratio=0
            }

            foregroundScrollView.setContentOffset(CGPointMake(0, ratio * foregroundView.frame.origin.y - foregroundScrollView.contentInset.top), animated: true)
        }
    }

    // MARK: - Delegate
    // MARK: - UIScrollView
    func scrollViewDidScroll(scrollView: UIScrollView) {

        //translate into ratio to height
        var ratio:CGFloat = (scrollView.contentOffset.y + foregroundScrollView.contentInset.top)/(foregroundScrollView.frame.size.height - foregroundScrollView.contentInset.top - viewDistanceFromBottom)

        if ratio < 0{
            ratio = 0
        }
        if ratio > 1{

            ratio=1
        }

        //set background scroll
        backgroundScrollView.contentOffset = CGPointMake(maxBackgroundMovementHorizontal, ratio * maxBackgroundMovementVerticle)

        //set alpha
        blurredBackgroundImageView.alpha = ratio
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var ratio =  (targetContentOffset.memory.y + foregroundScrollView.contentInset.top) / (foregroundScrollView.frame.size.height - foregroundScrollView.contentInset.top - viewDistanceFromBottom)
        
        if ratio > 0 && ratio < 1{
            
            if velocity.y == 0{
                if ratio>0.5{ratio=1}
                else{ratio=0}
            }
            else if velocity.y > 0 {
                if ratio>0.1{ratio=1}
                else{ratio=0}
            }
            else {
                if ratio>0.9{ratio=1}
                else{ratio=0}
            }
            
            targetContentOffset.memory.y=ratio * foregroundView.frame.origin.y - foregroundScrollView.contentInset.top
            
        }
        
        
    }
    
}
