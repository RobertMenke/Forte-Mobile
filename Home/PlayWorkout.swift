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
    
    var viewController : ConfirmWorkoutStartViewController!;
    var subScrollView = UIView();
    
    let rowHeight : CGFloat = CGFloat(35);

    init(workoutSubviews : [WorkoutInstruction], viewController : ConfirmWorkoutStartViewController){
        
        super.init(frame : CGRect.zero);
        
        self.workoutInstructionTiles                    = workoutSubviews;
        self.viewController                             = viewController;
        self.translatesAutoresizingMaskIntoConstraints  = false;
        self.clipsToBounds                              = true;
        
        appendTiles();
        
        
    }

    
    func appendTiles(){
        

        subScrollView.translatesAutoresizingMaskIntoConstraints = false;
    
        for(var i = 0; i < workoutInstructionTiles.count; i++){
            
            
            
            //print("set count \(setCount) \(workoutInstructionTiles[i].sets.count)");
            workoutInstructionTiles[i].backgroundColor    = UIColor.whiteColor();
            workoutInstructionTiles[i].translatesAutoresizingMaskIntoConstraints = false;
        
            //changeContentSize(workoutInstructionTiles[i]);
            subScrollView.addSubview(workoutInstructionTiles[i]);

            //print("height total \(heightsTotal) and set count \(setCount)");
            //Formula for position relative to top of the ScrollView will be 10 (margin) + 20 (label space) + setCount * 20 (content) + heightsTotal
            let setCount        = workoutInstructionTiles[i].getNumSets();
            let topAttr         = CGFloat(50  + heightsTotal);
            let heightAttr      = CGFloat(setCount) * rowHeight + rowHeight + 50;
            
            let verticalConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: topAttr);
            
            let widthConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: -20);
            
            let leftConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 10);
            
            let heightConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: heightAttr);
            
            //let bottomConstraint = NSLayoutConstraint(item: workoutInstructionTiles[i], attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: topAttr + heightAttr - rowHeight);
            
            
            subScrollView.addConstraints([verticalConstraint, leftConstraint, widthConstraint, heightConstraint/*,bottomConstraint*/]);
            
            heightsTotal += Int(heightAttr) + 10;
        }
        
        self.addSubview(subScrollView);

    }
    
    
    
    func setViewConstraints(superView : UIView) -> Void{
        
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant:60);
        
        let leftConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);

        let rightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0);
        
        
        superView.addConstraints([verticalConstraint, leftConstraint, bottomConstraint,rightConstraint]);
        
    }
    
    func constrainContentViewToSuper(){
        
        /**
         Ok, future self, read this to understand the secret to the autolayout scroll view.
         Your (currently present) past self, after 3 days of maddening searching has the
         low down. Here's how you constrain a scroll view.
         
         1 - a scroll view can only have 1 child view, which should generally be a UIView
             to hold all of the scrollable content.
         
         2 - pin the scroll view to its superview with whatever constraints you want
         
         3 - pin that child UIView mentioned in step 1 to the scroll view -> top, leading, trailing, and bottom. This should generally be pinned exactly unless the UIView is designed to be smaller than the dimension of the scroll view
         
         4 - in order for the scroll view to understand the content size of the view, you MUST SET THE HEIGHT AND THE WIDTH OF THE UIVIEW BASED ON THE SCROLL VIEWS SUPERVIEW OR A CALCULATION THAT DOESN'T INVOLVE THE SCROLL VIEW. Don't worry about setting other dimensions of the UIView relative to the scroll views superview, just height and width are necessary for the cocoa api to infer the content size
         
         First, layout the content view relative to the scroll view. According to research it should basically be pinned
         exactly to the frame
         */
        let pinTop = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant:0);
        
        let pinBottom = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0);
        //CGFloat(heightsTotal + (self.workoutInstructionTiles.count * 10))
        
        let pinLeft = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        let pinRight = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);

        
        self.addConstraints([pinTop, pinBottom, pinLeft, pinRight]);
        
        
        /**
        Next, layout the content view relative to the scroll view's super view so that the scroll view knows to adjust
        to that content (confusing as hell)
        */
        
        let widthConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.viewController.contentView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0);
        
        
        //(added 20 for a little extra spacing at the bottom)
        let heightConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(heightsTotal + (self.workoutInstructionTiles.count * 10) + Int(rowHeight)));
        
        
        self.viewController.contentView.addConstraints([heightConstraint, widthConstraint]);

    }
    
    func changeContentSize(aView : UIScrollView){
        
        aView.contentSize.height = CGFloat(aView.subviews.count) * rowHeight + rowHeight;
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
