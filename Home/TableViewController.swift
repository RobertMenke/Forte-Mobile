//
//  TableViewController.swift
//  Home
//
//  Created by Robert B. Menke on 12/21/15.
//  Copyright © 2015 Forte. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var menuContents : Array<NSMutableDictionary>! = Array<NSMutableDictionary>();
    var userDefaults : NSUserDefaults              = NSUserDefaults.standardUserDefaults();
    var primaryViewController : ConfirmWorkoutStartViewController!;
    
    init(primaryViewController: ConfirmWorkoutStartViewController){
        
        super.init(style: UITableViewStyle.Plain);
        self.primaryViewController = primaryViewController;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell");
        createMenuContents();
        
        self.tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0);
        self.edgesForExtendedLayout = UIRectEdge.None;
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
//        let c = self.primaryViewController.viewConstraints(self.tableView, superView: self.view)
//        self.tableView.addConstraints([c.vertical, c.right, c.left, c.height]);

    }
    
    internal func createMenuContents(){
        
        menuContents.append(NSMutableDictionary());
        menuContents[0].setValue("Schedule", forKey: "celltext");
        menuContents[0].setValue(UIImage(named: "ic_date_range"), forKey: "image");
        menuContents[0].setValue("goToSchedule", forKey: "target");
        
        menuContents.append(NSMutableDictionary());
        menuContents[1].setValue("Stats", forKey: "celltext");
        menuContents[1].setValue(UIImage(named: "ic_trending_up"), forKey: "image");
        menuContents[1].setValue("goToStats", forKey: "target");
        
        menuContents.append(NSMutableDictionary());
        menuContents[2].setValue("Today's Workout", forKey: "celltext");
        menuContents[2].setValue(UIImage(named: "ic_fitness_center"), forKey: "image");
        menuContents[2].setValue("goToTodaysWorkout", forKey: "target");
        
        menuContents.append(NSMutableDictionary());
        menuContents[3].setValue("Settings", forKey: "celltext");
        menuContents[3].setValue(UIImage(named: "ic_settings"), forKey: "image");
        menuContents[3].setValue("goToSettings", forKey: "target");
    }
    
    
    internal func setupNav(){
        
        //Step 1: make a navigationbar object with a frame equal to the width of the device
        let navController : UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60));
        navController.backgroundColor   = UIColor(red: 96.0/255.0, green: 125.0/255.0, blue: 139.0/255.0, alpha: 1.0);
        navController.tintColor         = UIColor.whiteColor();
        
        //Step 2: make a UINavigationItem object. This object contains all the elements of the navigation bar
        let navItem     = UINavigationItem();
        navItem.title   = "Menu";
        
//        //Step 3: set up a custom navbar button and give the button a target function
//        let navItemLeft : UIButton = UIButton(type: UIButtonType.Custom);
//        navItemLeft.setImage(UIImage(named: "ic_menu_white"), forState: UIControlState.Normal);
//        navItemLeft.addTarget(self, action: "menuPressed:", forControlEvents: UIControlEvents.TouchUpInside);
//        navItemLeft.frame = CGRect(x: 10, y: 10, width: 30, height: 30);
        
        
        //Step 4: add the UIBarButtonItem to the nav item object and then add the navItem to the navController
//        let navLeft                 = UIBarButtonItem(customView: navItemLeft);
//        navItem.leftBarButtonItem   = navLeft;
        navController.items         = [navItem];
        
        //Step 5: add the navcontroller to the screen
        //self.view.addSubview(navController);
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        
        // Configure the cell...
        let cellWidth = cell.bounds.width;
        
        self.tableView.rowHeight = 50;
        
        let image = self.menuContents[indexPath.row].objectForKey("image") as! UIImage;
        let imageView = UIImageView(image: image);
        imageView.frame = CGRect(x: cellWidth - 100, y: 10, width: 25, height: 25)
        cell.addSubview(imageView);
       
        cell.textLabel!.text = self.menuContents[indexPath.row].objectForKey("celltext") as? String;
        cell.textLabel!.textAlignment = .Left;
        
        let cellAction = Selector((self.menuContents[indexPath.row].objectForKey("target") as? String)! + ":");
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: cellAction));
        
        

        return cell
    }

    func goToSchedule(sender: AnyObject){
        
        print("schedule");
    }
    
    func goToStats(sender: AnyObject){
        
        print("stats");
    }
    
    /**
     Use the confirmWorkout view controller object to send the user back to the view controller screen
     */
    func goToTodaysWorkout(sender: AnyObject){
        
        //print("dat object do \(userDefaults.objectForKey("userDetails")!)");
        self.primaryViewController.loginDetails  = self.userDefaults.objectForKey("userDetails")!   as! NSMutableDictionary;
        
        //If we've deconstructed the main object for some reason and today's workout has been set to nil, get the data from
        //the os
        if self.primaryViewController.todaysWorkout == nil{
            if let temp = self.userDefaults.objectForKey("todaysWorkout")!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
                
                print("stored string \(temp)");
                self.primaryViewController.todaysWorkout = JSON(temp);
            }
        }

        let frameWidth = self.view.frame.width;
        let framecenter = self.view.center.x;
        
        UIView.animateWithDuration(0.3, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            
            //self.view.layoutIfNeeded()
            self.primaryViewController.todaysWorkoutViewSetup();
            self.primaryViewController.view.center.x = framecenter;
            
            }, completion: {(finished: Bool) -> Void in
                

                self.primaryViewController.menuShouldSlide = true;
                self.tableView.removeFromSuperview();
                self.primaryViewController.leftBorder.removeFromSuperlayer();

        })
        

    }

    
    func goToSettings(sender : AnyObject){
        
        print("settings");
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
//
//    //In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        var selectedIndexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!;
//    }


}
