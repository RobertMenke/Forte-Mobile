//
//  ConfirmWorkoutStartViewController.swift
//  Home
//
//  Created by Robert B. Menke on 12/19/15.
//  Copyright © 2015 Forte. All rights reserved.
//

import UIKit

class ConfirmWorkoutStartViewController: UIViewController, UIScrollViewDelegate {

    var contentView                 : UIView!;
    var slideOutMenu                : TableViewController?
    let centerPanelExpandedOffset   : CGFloat   = 60;
    let bottomNavHeight             : CGFloat   = 50;

    var welcomeLabel        : UILabel            = UILabel();
    var beginButton         : UIButton           = UIButton();
    var todaysWorkoutLabel  : UILabel            = UILabel();
    var actualWorkoutLabel  : UILabel            = UILabel();
    var navController       : UINavigationBar    = UINavigationBar();
    var bottomNav           : UIView             = UIView();
    var todayView           : TodaysWorkout!
    var workoutConfig       : PlayWorkout?
    var workoutInstructions : [WorkoutInstruction] = [WorkoutInstruction]()
    
    var todaysWorkout       : JSON?;
    var todaysActuals       : JSON?;
    var justInstructions    : JSON?;
    var loginDetails        : NSMutableDictionary!;
    
    var userDetails     = Dictionary<String, String>();
    var userDefaults    = NSUserDefaults.standardUserDefaults();
    var menuShouldSlide = true;
    var menuIsSliding   = false;

    let leftBorder = CALayer();
    let topBorder  = CALayer();
    
    var workoutStarted = false;
    var scrollOffset : CGPoint?;
    var bottomMenuVisible = true;
    
    var deviceOrientation : String = ""; //This variable will track how the device is laid out
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        contentView = UIView();
        self.view.addSubview(contentView);
        todaysWorkoutViewSetup()
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
            deviceOrientation = "landscape"
        } else{
            deviceOrientation = "portrait"
        }
        
        for(key, subJSON) : (String, JSON) in self.todaysWorkout!["workoutDay"]{

            print("key: \(key) value: \(subJSON)")
        }

        
        if(self.todaysWorkout != nil){
            self.justInstructions = self.todaysWorkout!["workoutDay"]["instructions"];
        }

    }
    
    
    override func viewDidLayoutSubviews() {
        //Make changes to material that needs resizing when screen is rotated
        
        if(!menuIsSliding){
            setupBottomBar();
        }


        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            if(deviceOrientation == "portrait"){
                removeTablePrep();
                bottomMenuVisible = true;
            }
            deviceOrientation = "landscape";
        } else{
            
            if(deviceOrientation == "landscape"){
                removeTablePrep();
                bottomMenuVisible = true;
            }
            deviceOrientation = "portrait";
        }
        

        
//        if(workoutConfig != nil){
//            
//            workoutConfig!.contentSize.height = CGFloat(workoutConfig!.heightsTotal + (workoutConfig!.workoutInstructionTiles.count * 10));
//            workoutConfig!.contentSize.width  = CGFloat(self.view.bounds.size.width - 20);
//            
//            for view in workoutConfig!.subviews{
//                if view is UIScrollView{
//                    workoutConfig?.changeContentSize(view as! UIScrollView)
//                }
//            }
//        }
    }
    
    
    func parseWorkoutInstructions(){
        
        workoutInstructions = [WorkoutInstruction]()
        for (index , subJson) : (String, JSON) in self.justInstructions!{
            
            //print("parsing \(subJson) and \(index)");
            workoutInstructions.append(WorkoutInstruction(instruction: subJson));
        }
    }
    
    func todaysWorkoutViewSetup(){
        
        todayView = TodaysWorkout(workoutDay: self.todaysWorkout!); //set up an extension of UIView to display either the start or rest menu
        removeAllSubviews(self.contentView);
        
        setupNav();
        
        todayView.setupTextLabel();
        self.contentView.addSubview(todayView.getToday());
        todayView.setViewConstraints(self.contentView);

        let constraints = viewConstraints(contentView, superView: self.view);
        self.view.addConstraints([constraints.vertical, constraints.height, constraints.left, constraints.right]);
        self.contentView.layoutIfNeeded()
        
        
        
        contentView.backgroundColor = UIColor(red: 236/255, green: 239/255, blue: 241/255, alpha: 1);
        setupBottomBar();
        
        if(todayView.startButton != nil){ //Add a gesture recognizer to the start button if it is indeed a workout day
            
            todayView.startButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startWorkout:"));
        }
        
    }
    
    internal func removeAllSubviews(aView : UIView){
        for view in aView.subviews {
            
            if(view.subviews.count > 0){
                removeAllSubviews(view);
            }

            view.removeFromSuperview()
        }
    }
    
    /**

     This function should provide accurate constraints for the main content views that will occupy this
     view controller
     */
    func viewConstraints(contentView : UIView, superView : UIView) -> (vertical : NSLayoutConstraint, height: NSLayoutConstraint, left : NSLayoutConstraint, right : NSLayoutConstraint){
        
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        
        let verticalConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0);
        
        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
        
        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        return (verticalConstraint, heightConstraint, leftConstraint, rightConstraint);
    }
    
    func setupNav(){
        
        //Step 1: make a navigationbar object with a frame equal to the width of the device
        
        navController = UINavigationBar();
        navController.barTintColor              = UIColor(red: 69/255.0, green: 90/255, blue: 100/255, alpha: 1.0);
        navController.titleTextAttributes       = [NSForegroundColorAttributeName : UIColor.whiteColor()];
        
        //Step 2: make a UINavigationItem object. This object contains all the elements of the navigation bar
        let navItem     = UINavigationItem();
        navItem.title   = "Start Workout";
        
        //Step 3: set up a custom navbar button and give the button a target function
        let navItemLeft : UIButton = UIButton(type: UIButtonType.Custom);
        navItemLeft.setImage(UIImage(named: "ic_menu_white"), forState: UIControlState.Normal);
        navItemLeft.addTarget(self, action: "menuPressed:", forControlEvents: UIControlEvents.TouchUpInside);
        navItemLeft.frame = CGRect(x: 10, y: 10, width: 30, height: 30);
        
        
        //Step 4: add the UIBarButtonItem to the nav item object and then add the navItem to the navController
        let navLeft                 = UIBarButtonItem(customView: navItemLeft);
        navItem.leftBarButtonItem   = navLeft;
        navController.items         = [navItem];
        
        navController.translatesAutoresizingMaskIntoConstraints = false;
        
        //Step 5: add the navcontroller to the screen
        self.contentView.addSubview(navController);
        
        let leftConstraint = NSLayoutConstraint(item: navController, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
        
        let rightConstraint = NSLayoutConstraint(item: navController, attribute: NSLayoutAttribute.Leading, relatedBy: .Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: navController, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 60);
        
        let topConstraint = NSLayoutConstraint(item: navController, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        
        self.contentView.addConstraints([leftConstraint, rightConstraint, heightConstraint, topConstraint]);
    }
    
    func setupBottomBar(){
        
        var iconMap : Array<NSMutableDictionary>! = Array<NSMutableDictionary>();
        bottomNav.removeFromSuperview();
        bottomNav = UIView();
        
        let frameWidth = self.view.bounds.size.width;
        
        iconMap.append(NSMutableDictionary());
        iconMap[0].setValue("Today", forKey: "iconText");
        iconMap[0].setValue(UIImage(named: "ic_date_range"), forKey: "image");
        iconMap[0].setValue("goToTodaysWorkout", forKey: "target");
        
        iconMap.append(NSMutableDictionary());
        iconMap[1].setValue("Stats", forKey: "iconText");
        iconMap[1].setValue(UIImage(named: "ic_trending_up"), forKey: "image");
        iconMap[1].setValue("goToStats", forKey: "target");
        
        iconMap.append(NSMutableDictionary());
        iconMap[2].setValue("Schedule", forKey: "iconText");
        iconMap[2].setValue(UIImage(named: "ic_fitness_center"), forKey: "image");
        iconMap[2].setValue("goToSchedule", forKey: "target");
        
        iconMap.append(NSMutableDictionary());
        iconMap[3].setValue("Settings", forKey: "iconText");
        iconMap[3].setValue(UIImage(named: "ic_settings"), forKey: "image");
        iconMap[3].setValue("goToSettings", forKey: "target");
        
        var counter = 0;
        for dict in iconMap{
            
            let menuOption = UIView();
            let image = dict.objectForKey("image") as! UIImage;
            let imageView = UIImageView(image: image);
            
            
            
            let iconLabel : UILabel = UILabel();
            iconLabel.text = dict.objectForKey("iconText") as! String;
            iconLabel.font = UIFont(name: "Helvetica", size: 10);
            
            let centerXconstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: menuOption, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0);
        
        
            let centerYconstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: menuOption, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
            
            let heightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 25);
            
            let widthConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 25);
            
            
            let labelXconstraint = NSLayoutConstraint(item: iconLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: menuOption, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0);

            
            let labelYconstraint = NSLayoutConstraint(item: iconLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: menuOption, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 25);

            
            
            menuOption.translatesAutoresizingMaskIntoConstraints    = false;
            imageView.translatesAutoresizingMaskIntoConstraints     = false;
            iconLabel.translatesAutoresizingMaskIntoConstraints     = false;
            
            
            menuOption.addSubview(imageView);
            menuOption.addSubview(iconLabel);
            
            menuOption.addConstraints([centerXconstraint, centerYconstraint, heightConstraint, widthConstraint, labelXconstraint, labelYconstraint]);
            
            //iconLabel.textAlignment = .Center;
            
            let menuAction = Selector((dict.objectForKey("target") as? String)! + ":");
            menuOption.addGestureRecognizer(UITapGestureRecognizer(target: self.slideOutMenu, action: menuAction));
            
            bottomNav.addSubview(menuOption);
            
            
            let leftConstraint = NSLayoutConstraint(item: menuOption, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: bottomNav, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: CGFloat(counter) * frameWidth / CGFloat(iconMap.count));
            
            //print("left const \(CGFloat(counter) * frameWidth / CGFloat(iconMap.count))");
            
            
            let topConstraint = NSLayoutConstraint(item: menuOption, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: bottomNav, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
            
            let optionHeightConstraint = NSLayoutConstraint(item: menuOption, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: self.bottomNavHeight);
            
            let optionWidthConstraint = NSLayoutConstraint(item: menuOption, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: frameWidth / CGFloat(iconMap.count));

            bottomNav.addConstraints([leftConstraint, topConstraint, optionHeightConstraint, optionWidthConstraint])
            
            counter++;
        }
        
        
        //Add a layer for a thin top border

        topBorder.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 1);
        topBorder.backgroundColor = UIColor.lightGrayColor().CGColor;
        bottomNav.layer.addSublayer(topBorder);
        
        bottomNav.translatesAutoresizingMaskIntoConstraints     = false;
        bottomNav.backgroundColor = UIColor.whiteColor();
        self.contentView.addSubview(bottomNav);
        
        
        let trailingConstraint = NSLayoutConstraint(item: bottomNav, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
        
        let leadingConstraint = NSLayoutConstraint(item: bottomNav, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        
        let bottomConstraint = NSLayoutConstraint(item: bottomNav, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        
        let navHeightConstraint = NSLayoutConstraint(item: bottomNav, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 60);
        
        
        self.contentView.addConstraints([trailingConstraint, leadingConstraint, bottomConstraint, navHeightConstraint]);

    }
    
    
    func centeredLabel(element : AnyObject, relativeTo : AnyObject,  height : CGFloat,verticalSeparation : CGFloat, left: CGFloat, right: CGFloat) -> Void{
        
        
        let leftConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: left);
        
        let rightConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: right);
        
        let topConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: relativeTo, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: verticalSeparation)
        
        let heightConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: height);
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint]);
    }

    
    
    func menuPressed(sender: AnyObject){
        
        if(menuShouldSlide){
            slideOutMenu = TableViewController(primaryViewController: self);
            self.view.insertSubview(slideOutMenu!.view, atIndex: 0);
            addChildViewController(slideOutMenu!);
            slideOutMenu!.didMoveToParentViewController(self);
            
        }
        animateLeftPanel(menuShouldSlide);
    }
    
    func animateLeftPanel(shouldExpand : Bool){
        
        let frameWidth  = self.view.frame.width;
        let frameHeight = self.view.frame.height;
        let framecenter = self.view.center.x;
        slideOutMenu!.tableView.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight);
        
        if (shouldExpand) {
        
            self.menuIsSliding = true;
            self.view.addSubview(self.slideOutMenu!.tableView);
            self.view.sendSubviewToBack(self.slideOutMenu!.tableView);
            self.contentView.layer.borderColor = UIColor.blackColor().CGColor;

            leftBorder.frame = CGRect(x: 0, y: 0, width: 1, height: frameHeight)
            leftBorder.backgroundColor = UIColor.blackColor().CGColor
            self.contentView.layer.addSublayer(leftBorder);
            
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {() in
                
                self.view.layoutIfNeeded()
                self.contentView.center.x += frameWidth - 50;
                self.menuShouldSlide = false;
                
            
                }, completion: {(finished : Bool) -> Void in
               
                    self.menuIsSliding = false;
                    
                   });
            
            
        } else {
            
            leftBorder.removeFromSuperlayer();
        
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {() in
                
                //self.view.layoutIfNeeded()
                self.contentView.center.x = framecenter;

                }, completion: {(finished: Bool) -> Void in
                
                    self.slideOutMenu!.tableView.removeFromSuperview();
                    self.menuShouldSlide = true;
                    })
            
        }
    }
    
    
    func startWorkout(sender : UITapGestureRecognizer){
        
        parseWorkoutInstructions();
        print("count subviews \(workoutInstructions.count)");
        workoutConfig = PlayWorkout(workoutSubviews : workoutInstructions, viewController : self);
        workoutConfig!.delegate = self;
        //workoutConfig!.backgroundColor = UIColor.greenColor();
        
        self.contentView.addSubview(workoutConfig!);
        workoutConfig!.constrainContentViewToSuper();
        workoutConfig!.setViewConstraints(self.contentView);
        //workoutConfig!.layoutIfNeeded();
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {() in
            
            
            self.todayView.bounds.origin.x = -(self.view.bounds.size.width); //Slide the todayView out completely
            
            
        }, completion: {(finished : Bool) -> Void in
         
            
            self.todayView.removeFromSuperview();
        })
    }
    
    internal func removeTablePrep(){
        
        leftBorder.removeFromSuperlayer();

        if self.slideOutMenu != nil {
            self.slideOutMenu!.tableView.removeFromSuperview();
        }
        self.menuShouldSlide = true;
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollOffset = workoutConfig!.contentOffset;
    }

    func scrollViewDidScroll(scrollView: UIScrollView){
        
        if (scrollView.contentOffset.y < self.scrollOffset!.y) {
            //scroll view is moving upwards (Y offset value is decreasing)
            if(!self.bottomMenuVisible){
                self.bottomMenuVisible = !self.bottomMenuVisible;
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                    
                    self.bottomNav.center.y -= self.bottomNav.bounds.size.height;
                    
                }, completion: {(finished : Bool) in
                        
                    
                });
                
            }
            
        } else if (scrollView.contentOffset.y > self.scrollOffset!.y) {
            //scroll view is moving downwards (Y offset value is increasing)
            
            if(self.bottomMenuVisible){
                self.bottomMenuVisible = !self.bottomMenuVisible;
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                    
                    self.bottomNav.center.y += self.bottomNav.bounds.size.height;
                    
                    }, completion: {(finished : Bool) in
                        
                        
                });
                
            }
            
        }
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
