//
//  TodaysWorkout.swift
//  Home
//
//  Created by Robert B. Menke on 12/27/15.
//  Copyright © 2015 Forte. All rights reserved.
//

import UIKit

class TodaysWorkout: UIView {

    var todaysWorkout : JSON?;
    
    var startButton : UIButton?
    
    var todaysTitle : String?;
    
    init(workoutDay : JSON){
        
        super.init(frame: CGRect.zero);
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.todaysWorkout = workoutDay;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextLabel(){
        
        let workoutLabel      = UILabel();
        let todaysWorkoutText = UILabel();
        
        workoutLabel.font      = UIFont(name: "Avenir-Medium", size: 20);
        todaysWorkoutText.font = UIFont(name: "Avenir-Medium", size: 20);
        
        
        workoutLabel.translatesAutoresizingMaskIntoConstraints = false;
        todaysWorkoutText.translatesAutoresizingMaskIntoConstraints = false
        
        workoutLabel.textAlignment = NSTextAlignment.Center;
        todaysWorkoutText.textAlignment = NSTextAlignment.Center;


        
        workoutLabel.text = "Today's Workout";

        if let boolTest = self.todaysWorkout!["workoutDay"]["background"]["workoutDayId"].string{
    
            if(boolTest.characters.count == 0){
                
                todaysWorkoutText.text = "Rest Day";
                todaysTitle = "Rest Day";
                setupImage();

            } else{
            

                todaysWorkoutText.text = self.todaysWorkout!["workoutDay"]["background"]["name"].string
                todaysTitle = self.todaysWorkout!["workoutDay"]["background"]["name"].string
                setupButton()
            
            }
        } else{
            
            todaysTitle = "Rest Day";
            todaysWorkoutText.text = "Rest Day";
            setupImage();
        }
        
        
        self.addSubview(workoutLabel)
        
        let verticalConstraint2 = NSLayoutConstraint(item: workoutLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 0.22, constant: 0);
        
        let horizontalConstraint2 = NSLayoutConstraint(item: workoutLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        let heightConstraint2 = NSLayoutConstraint(item: workoutLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100);
        
        let widthConstraint2 = NSLayoutConstraint(item: workoutLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 200);
        
        self.addConstraints([verticalConstraint2, horizontalConstraint2, heightConstraint2, widthConstraint2]);

        
        self.addSubview(todaysWorkoutText);
        
        //        centeredLabel(todaysWorkoutText, relativeTo: self.contentView, height: 30, verticalSeparation: self.contentView.bounds.height / 2 - 120, left: 0, right: 0);
        //
        //        centeredLabel(workoutLabel, relativeTo: todaysWorkoutText, height: 30, verticalSeparation: -50, left: 0, right: 0);
        
       
            
        
        
        let verticalConstraint = NSLayoutConstraint(item: todaysWorkoutText, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 0.40, constant: 0);
        
        let horizontalConstraint = NSLayoutConstraint(item: todaysWorkoutText, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: todaysWorkoutText, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100);
        
        let widthConstraint = NSLayoutConstraint(item: todaysWorkoutText, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 200);
            
        self.addConstraints([verticalConstraint, horizontalConstraint, heightConstraint, widthConstraint]);
        
    }
    
    
    internal func setupImage(){
        
        let imageContainer = UIImage(named: "sleep");
        let imageView = UIImageView(image: imageContainer);
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit;
        
        imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        
        self.addSubview(imageView);
        
        
        //Constraints
        
        let verticalConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0);
        
        let horizontalConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        //let heightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 120);
        
        let widthConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 170);
        
        self.addConstraints([verticalConstraint, horizontalConstraint, /*heightConstraint,*/ widthConstraint]);
    }
    
    
    internal func setupButton(){
        
        startButton = UIButton();
        
        startButton!.backgroundColor = UIColor(red: 96.0/255.0, green: 125.0/255.0, blue: 139.0/255.0, alpha: 1.0);
        
        startButton!.layer.cornerRadius = 60;
        
        startButton!.setTitle("Start!", forState: .Normal);
        
        startButton!.translatesAutoresizingMaskIntoConstraints = false;
        
        
        self.addSubview(startButton!);
        
        
        //Constraints
        
        let verticalConstraint = NSLayoutConstraint(item: startButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0);
        
        let horizontalConstraint = NSLayoutConstraint(item: startButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: startButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 120);
        
        let widthConstraint = NSLayoutConstraint(item: startButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 120);
        
        self.addConstraints([verticalConstraint, horizontalConstraint, heightConstraint, widthConstraint]);
        
    }
    
    
    
    func setViewConstraints(superView : UIView) -> Void{
        
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant:30);
        
        let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: -60);
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0);

        superView.addConstraints([verticalConstraint, horizontalConstraint, heightConstraint, widthConstraint]);
        
    }
    
    func getToday() -> UIView{
        return self;
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
