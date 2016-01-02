//
//  WorkoutInstruction.swift
//  Home
//
//  Created by Robert B. Menke on 12/27/15.
//  Copyright © 2015 Forte. All rights reserved.
//

import UIKit

// Sample data will look like this
//
//{
//    "eID" : "3",
//    "wId" : "484",
//    "instructionId" : "3478",
//    "wname" : "Barbell Deadlift",
//    "0" : [
//    {
//    "weight" : "270",
//    "reps" : "5"
//    },

    
class WorkoutInstruction: UIScrollView{

    var instructionJson  : JSON?;
    var justInstructions : JSON?;
    var actualsJson      : JSON?;
    
    var workoutTitle     : UILabel   = UILabel();
    var sets             : [UIView]  = [UIView]();
    var orderedSet       : [Dictionary<String, String>] = [Dictionary<String, String>]();
    
    
    init(instruction : JSON/*, actuals : JSON*/){
        
        super.init(frame: CGRect.zero);
        
        self.instructionJson = instruction;
        //self.actualsJson     = actuals; will take care of this later**
        
        addInstructionLabel();
        setupSetViews();

        self.layer.shadowColor     = UIColor.darkGrayColor().CGColor
        self.layer.shadowOffset    = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowOpacity   = 0.4
        self.layer.shadowRadius    = 2
        self.layer.masksToBounds   = false
        
    }
    
    func getNumSets() -> Int{
        
        return sets.count;
    }
    
    func addInstructionLabel(){
        
        workoutTitle.text = self.instructionJson!["wname"].string;
        workoutTitle.textAlignment = .Center;
        workoutTitle.translatesAutoresizingMaskIntoConstraints = false;
        
        self.addSubview(workoutTitle);
        
        let verticalConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10);
        
        let horizontalConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 30);
        
        let widthConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 200);
        
        self.addConstraints([verticalConstraint, horizontalConstraint, heightConstraint, widthConstraint]);

    }
    
    
    func setupSetViews(){
        
    
        var counter = 0;
        
        for(var i = 0; i < self.instructionJson!["0"].count; i++){
            
            //First, look at an individual set and order it appropriately based on a few rules
            //This should return something like -> reps : 5, weight : 100
            let orderedSet : [Dictionary<String, String>] = determineOrder(self.instructionJson!["0"][i]);
            
            if(orderedSet.count > 0){
                
                sets.append(UIView());
                
                let setLabel : UILabel          = UILabel();
                var fields   : [UITextField]    = [UITextField]();
                
                setLabel.text = String("Set \(i)");
                setLabel.translatesAutoresizingMaskIntoConstraints = false;
                

                for(var x = 0; x < orderedSet.count; x++){
                
                    for(key, value) : (String, String) in orderedSet[x]{ //Now, loop through an individual set and make UITextFields
                
                        //print("ordered set \(key) , value: \(value)");
                        var tempField  = UITextField();
                        tempField.text = value;
                        fields.append(tempField);
                
                    }
                }
            
                sets[counter].translatesAutoresizingMaskIntoConstraints = false;
                constrainFields(fields, parentView : sets[counter]);
                self.addSubview(sets[counter]);
                counter++;
            }
        }
        constrainSets(sets, parentView : self);
    }
    
    func constrainFields(fields : [UITextField], parentView : UIView){
        
        for(var i = 0; i < fields.count; i++){
            
            fields[i].translatesAutoresizingMaskIntoConstraints = false;
            parentView.addSubview(fields[i]);
        
            let leftConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: CGFloat(i * 40 + 5));
        
            let topConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        
            let heightConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 30);
            
            parentView.addConstraints([leftConstraint, topConstraint, heightConstraint]);
        }
    }
    
    
    func constrainSets(allSets : [UIView], parentView : UIScrollView){
        
        for(var i = 0; i < allSets.count; i++){
            
        
            let leftConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
            
            let rightConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);

        
            let topConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: CGFloat(30 + (30 * i)))
        
            let heightConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 30);
            
            parentView.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint]);
        }
    }
    
    /**
     * Orders an individual array of fields for 1 particular instruction based on rules
     *
     * Rules are:
     * 1) Reps is always first
     * 2) Rest interval is always last
     * 3) Time always comes before distance
     *
     * Any more rules need to be added to the logic in this method and noted in the comments
     *
     *
     * @param fields - [[display, key],[display,key], etc]
     * @return fields - the input array sorted according to the rules listed above
     */
    
    func determineOrder(set : JSON) -> [Dictionary<String, String>]{
        
        var log  : [String] = [String]();
        var temp : [Dictionary<String, String>] = [Dictionary<String, String>]();
        
        
        for(key, value) : (String, JSON) in set{
            
            if(key == "reps" && value != nil){
                temp.append([key : value.string!]);
                log.append(key);
            }
        }
        
        for(key, value) : (String, JSON) in set{
            
            if(key == "time" && value != nil){
                temp.append([key : value.string!]);
                log.append(key);
            }
        }
        
        for(key, value) : (String, JSON) in set{
            
            if(key == "distance" && value != nil){
                temp.append([key : value.string!]);
                log.append(key);
            }
        }
        
        for(key, value) : (String, JSON) in set{
            
            if(log.indexOf(key) < 0 && key != "rest_interval"  && value.string != nil){
                temp.append([key : value.string!]);
                log.append(key);
            }
        }
        
        
        
        for(key, value) : (String, JSON) in set{
            
            if(key == "rest_interval" && value != nil){
                temp.append([key : value.string!]);
                log.append(key);
            }
        }
        
        
        for(key, value) : (String, JSON) in set{
            
            if(key == "rest_interval"){
                temp.append([key : value.string!]);
                log.append(key);
            }
        }
        
        
        orderedSet = temp;
        return temp;
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
