//
//  PlayWorkout.swift
//  Home
//
//  Created by Robert B. Menke on 12/28/15.
//  Copyright © 2015 Forte. All rights reserved.
//


import UIKit

class PlayWorkout: UIScrollView{

    var workoutInstructionTiles : [WorkoutInstruction] = [WorkoutInstruction]();
    
    var heightsTotal : Int = 0; //This variable will keep track of the running total for each of the workout tile subviews to help with positioning
    
    init(workoutSubviews : [WorkoutInstruction]){
        
        super.init(frame : CGRect.zero);
        workoutInstructionTiles = workoutSubviews;
        appendTiles();
        
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.clipsToBounds = true;
    }

    
    func appendTiles(){
        
        var subScrollView = UIView();
        subScrollView.translatesAutoresizingMaskIntoConstraints = false;
    
        for(var i = 0; i < workoutInstructionTiles.count; i++){
            
            let setCount = workoutInstructionTiles[i].getNumSets();
            
            //print("set count \(setCount) \(workoutInstructionTiles[i].sets.count)");
            workoutInstructionTiles[i].backgroundColor    = UIColor.whiteColor();
            workoutInstructionTiles[i].translatesAutoresizingMaskIntoConstraints = false;
        
            //changeContentSize(workoutInstructionTiles[i]);
            subScrollView.addSubview(workoutInstructionTiles[i]);

            //print("height total \(heightsTotal) and set count \(setCount)");
            //Formula for position relative to top of the ScrollView will be 10 (margin) + 20 (label space) + setCount * 20 (content) + heightsTotal
            let verticalConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: CGFloat(30  + heightsTotal));
            
            let rightConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
            
            let testLeft = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
            
            let widthConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: -10);
            
            let leftConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0);
            
            let heightConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(setCount * 30 + 30));
            
            subScrollView.addConstraints([verticalConstraint, leftConstraint, widthConstraint, heightConstraint]);
            heightsTotal += setCount * 30 + 40;
        }
        
        self.addSubview(subScrollView);

        let verticalConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant:0);
        
        let leftConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0);
        
         let widthConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0);
        
        let bottomConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: CGFloat(heightsTotal + (self.workoutInstructionTiles.count * 10)));
        
        self.addConstraints([verticalConstraint, leftConstraint, widthConstraint, bottomConstraint]);
    }
    
    
    
    func setViewConstraints(superView : UIView) -> Void{
        
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant:60);
        
        let leftConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);

        let rightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: -120);
        
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -60);
        
        
        superView.addConstraints([verticalConstraint, leftConstraint, bottomConstraint,/* heightConstraint,*/ rightConstraint]);
        
    }
    
    func changeContentSize(aView : UIScrollView){
        
        aView.contentSize.height = CGFloat(aView.subviews.count * 30);
        aView.contentSize.width  = CGFloat(self.bounds.size.width);
    }

   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
