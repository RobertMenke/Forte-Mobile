//
//  ViewController.swift
//  Home
//
//  Created by Robert B. Menke on 12/18/15.
//  Copyright © 2015 Forte. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    let screenSize                                              = UIScreen.mainScreen().bounds;
    var logo            : UILabel!                              = UILabel()
    var emailLabel      : UILabel!                              = UILabel()
    var emailInput      : UITextField!                          = UITextField()
    var pwLabel         : UILabel!                              = UILabel();
    var pwInput         : UITextField!                          = UITextField()
    var loginButton     : UIButton!                             = UIButton();
    var userDefaults    : NSUserDefaults                        = NSUserDefaults.standardUserDefaults(); //Store system information in a variable
    var confirmWorkout  : ConfirmWorkoutStartViewController     = ConfirmWorkoutStartViewController();
    
    
/**
--------------------------------------------------------------------------------------------------------
This will be the UI setup portion of the class
--------------------------------------------------------------------------------------------------------
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoSetup();
        emailLabelSetup();
        emailInputSetup();
        pwLabelSetup();
        pwInputSetup();
        buttonSetup();
        
        self.view.backgroundColor = UIColor(red: 236, green: 239, blue: 241, alpha: 1.0)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func logoSetup(){
        
        logo.text = "Forte Fitness";
        logo.textAlignment = NSTextAlignment.Center;
        logo.translatesAutoresizingMaskIntoConstraints = false;
        logo.font = UIFont(name: "Helvetica", size: 20.0)

        self.view.addSubview(logo)
        centeredLabel(logo, relativeTo: self.view, height: 50, verticalSeparation: 20, left: 0, right: 0);
    }
    
   
    
    func emailLabelSetup(){
        
        emailLabel.text = "Email";
        emailLabel.textAlignment = NSTextAlignment.Center;
        emailLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(emailLabel)
        centeredLabel(emailLabel, relativeTo: logo, height: 50, verticalSeparation: 35, left: 0, right: 0);
    }
    
    func emailInputSetup(){
        
        
        emailInput.layer.borderColor = UIColor.blackColor().CGColor;
        emailInput.layer.borderWidth = 1.0;
        emailInput.translatesAutoresizingMaskIntoConstraints = false;
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        emailInput.leftView = paddingView;
        emailInput.leftViewMode = UITextFieldViewMode.Always;
        emailInput.placeholder = "Enter your email";
        emailInput.layer.cornerRadius = 7;
        emailInput.autocapitalizationType = UITextAutocapitalizationType.None;
        self.view.addSubview(emailInput);
        
        centeredLabel(emailInput, relativeTo: emailLabel, height: 50, verticalSeparation: 35, left: 40, right: -40);
    }
    
    func pwLabelSetup(){
        
        pwLabel.text = "Password";
        pwLabel.textAlignment = NSTextAlignment.Center;
        pwLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(pwLabel)
        centeredLabel(pwLabel, relativeTo: emailInput, height: 50, verticalSeparation: 35, left: 0, right: 0);
    }
    
    func pwInputSetup(){
        
        
        pwInput.layer.borderColor = UIColor.blackColor().CGColor;
        pwInput.layer.borderWidth = 1.0;
        pwInput.translatesAutoresizingMaskIntoConstraints = false;
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        pwInput.leftView = paddingView;
        pwInput.leftViewMode = UITextFieldViewMode.Always;
        pwInput.placeholder = "Enter your password";
        pwInput.secureTextEntry = true;
        pwInput.layer.cornerRadius = 7;
        pwInput.autocapitalizationType = UITextAutocapitalizationType.None;
        self.view.addSubview(pwInput);
        
        centeredLabel(pwInput, relativeTo: pwLabel, height: 50, verticalSeparation: 35, left: 40, right: -40)
    }
    
    func buttonSetup(){
        
        loginButton.backgroundColor = UIColor(red: 96.0/255.0, green: 125.0/255.0, blue: 139.0/255.0, alpha: 0.8);
        loginButton.setTitle("Login", forState: .Normal);
        loginButton.titleLabel!.textColor = UIColor.whiteColor();
        loginButton.addTarget(self, action: "attemptLogin:", forControlEvents: .TouchUpInside);
        loginButton.translatesAutoresizingMaskIntoConstraints = false;
        loginButton.layer.cornerRadius = 7;
        
        view.addSubview(loginButton);

        centeredLabel(loginButton, relativeTo: pwInput, height: 60, verticalSeparation: 80, left: 40, right: -40)
    }
    
    
    func centeredLabel(element : AnyObject, relativeTo : AnyObject,  height : CGFloat,verticalSeparation : CGFloat, left: CGFloat, right: CGFloat) -> Void{
        
        
        let leftConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: left);
        
        let rightConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: right);
        
        let topConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: relativeTo, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: verticalSeparation)
        
        let heightConstraint = NSLayoutConstraint(item: element, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: height);
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint]);
    }

    
    
    
    
    
    
    
/**
--------------------------------------------------------------------------------------------------------
This will be the functional part of the class, end of ui setup
--------------------------------------------------------------------------------------------------------
*/
    

    func attemptLogin(sender: AnyObject){
    
        
        print("\(checkSystemLoginInfo()?.allKeys.count)");
        //Step 2 - set up a mutable dictionary to store key/value pairs for login fields
        let loginDetailsMap : NSMutableDictionary = NSMutableDictionary();
        
        //Step 3 - add email and password objects to the dictionary
        
        
        loginDetailsMap.setObject(emailInput.text!, forKey : "userEmail");
        
        loginDetailsMap.setObject(pwInput.text!, forKey: "password");
        
        //Step 4 - remove the stored forteLoginData object if it exists and add the new data
        
        userDefaults.removeObjectForKey("forteLoginData");
        userDefaults.setObject(loginDetailsMap, forKey: "forteLoginData");
        
        //Test to see if we actually have the data
        let userMapTest:NSMutableDictionary = userDefaults.objectForKey("forteLoginData") as! NSMutableDictionary;
        
        for (key, value) in userMapTest{
            print("key: \(key) value: \(value)");
        }
        
        makeLoginRequest(loginDetailsMap);
        
    }
    
    func makeLoginRequest(dict: NSDictionary){
        var response: NSMutableDictionary!;
        let requester = RequestData(data: dict, aUrl: "http://localhost/PtManagement/php/login_validation.php")
        do {
            try requester.loginRequest(true, callback: {(jsonDict) -> Void in

                response = jsonDict as! NSMutableDictionary;
                print("got here \(jsonDict.allKeys.count)");
                for (key, value) in jsonDict{
                    print("login response \(key) and \(value)");
                    response.setValue(value, forKey: key as! String)
                }
                response.setValue(0, forKey: "dateInteger"); //set a starting date integer to query workouts if any exist
                self.confirmWorkout.loginDetails = response;
                self.userDefaults.setValue(response, forKey: "userDetails");

                let jsonForCall = NSMutableDictionary();
                
                jsonForCall.setValue(response.valueForKey("userID"), forKey: "userId");
                jsonForCall.setValue(response.valueForKey("dateInteger"), forKey: "dateInteger");
                
                self.getActualsData(jsonForCall);
                self.getWorkoutData(jsonForCall);
            });
            
        } catch{
            print("error on request")
        }
        
    }
    
    func getWorkoutData(dict : NSMutableDictionary){
    
    
        //let response : NSMutableDictionary!;
        let requester = RequestData(data: dict, aUrl: "http://localhost/PtManagement/athletes/php/aWorkoutDay.php");
        
        do{
            try requester.workoutDayRequest({(jsonDict) in
                
                
                for (key, value) : (String, JSON) in jsonDict{
                    print("workout day \(key) and \(value)");
                }
                
                self.confirmWorkout.todaysWorkout = jsonDict;
                self.userDefaults.setObject(jsonDict.stringValue, forKey: "todaysWorkout");
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.presentViewController(self.confirmWorkout, animated: true, completion: nil)
                });
            });
        } catch{
            
            
        }
        

    }
    
    func getActualsData(dict : NSMutableDictionary){
        
        
        //let response : NSMutableDictionary!;
        let requester = RequestData(data: dict, aUrl: "http://localhost/PtManagement/athletes/php/retrieveDayActuals.php");
        
        do{
            try requester.workoutDayRequest({(jsonDict) in
                
                print("im a json", jsonDict);
                self.confirmWorkout.todaysActuals = jsonDict;
                self.userDefaults.setObject(jsonDict.string, forKey: "todaysActuals");
                
            });
        } catch{
            
            
        }
        
        
    }

    
    
    func checkSystemLoginInfo() -> NSDictionary?{
        
        if(userDefaults.objectForKey("forteLoginData") != nil){
            let data : NSDictionary = userDefaults.objectForKey("forteLoginData") as! NSDictionary;
        
            if(data.allKeys.count > 0){
                return data;
            } else{
                return nil;
            }
        }
        return nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

