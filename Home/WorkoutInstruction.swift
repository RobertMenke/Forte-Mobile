//
//  WorkoutInstruction.swift
//  Home
//
//  Created by Robert B. Menke on 12/27/15.
//  Copyright © 2015 Forte. All rights reserved.
//

import UIKit

extension String {
    func firstCharacterUpperCase() -> String {
        let lowercaseString = self.lowercaseString
        
        return lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString)
    }
}


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

    var instructionJson     : JSON?;
    var justInstructions    : JSON?;
    var actualsJson         : JSON?;
    
    var workoutTitle        : UILabel   = UILabel();
    var sets                : [UIView]  = [UIView]();
    var orderedSet          : [Dictionary<String, String>] = [Dictionary<String, String>]();
    
    var subScrollView       : UIView    = UIView();
    var viewController      : ConfirmWorkoutStartViewController!;
    var instructionId       : Int?
    var workoutId           : Int?
    var workoutDayId        : Int?
    var instructionFields   : [String]?
    
    var editButton : UIButton!
    var isEditing = false;
    
    
    //Constants for row height, etc
    let rowHeight : CGFloat = CGFloat(35);
    
    init(instruction : JSON, actuals : JSON, viewController : ConfirmWorkoutStartViewController, workoutDayId : Int){
        
        super.init(frame: CGRect.zero);
        
        //self.instructionJson = instruction;
        self.instructionJson = actuals["0"].count > 0 ? actuals : instruction; //If an actuals value exists, use that
        self.actualsJson     = actuals;
        self.viewController  = viewController;
        self.instructionId   = Int(self.instructionJson!["instructionId"].string!);
        self.workoutId       = Int(self.instructionJson!["wId"].string!);
        self.workoutDayId    = workoutDayId;
        
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
        
        //Set up a view to contain label + button
        let labelView = UIView();
        labelView.translatesAutoresizingMaskIntoConstraints = false;
        addBorder(labelView, edges : [.Bottom], colour: UIColor.lightGrayColor(), thickness: 1);
        
        //Set up UIButton
        editButton = UIButton(type: UIButtonType.Custom);
        editButton.translatesAutoresizingMaskIntoConstraints = false;
        let origImage = UIImage(named: "ic_mode_edit");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) //Allows us to change color programmatically
        editButton.setImage(tintedImage, forState: .Normal)
        editButton.addTarget(self, action: "beginEdit:", forControlEvents: UIControlEvents.TouchUpInside);
        editButton.tintColor = UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1.0);
        labelView.addSubview(editButton);
        
        let buttonTop = NSLayoutConstraint(item: editButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: labelView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 5);
        
        let buttonRight = NSLayoutConstraint(item: editButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: labelView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -5);
        
        //let buttonHeight = NSLayoutConstraint(item: labelView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 30);
        
        //let buttonWidth = NSLayoutConstraint(item: labelView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 35);
        
        labelView.addConstraints([buttonTop, buttonRight/*, buttonHeight, buttonWidth*/]);
        
        
        //Set up title object
        workoutTitle.text = self.instructionJson!["wname"].string;
        workoutTitle.textAlignment = .Center;
        workoutTitle.translatesAutoresizingMaskIntoConstraints = false;
        workoutTitle.font = UIFont(name: "Avenir-Medium", size: 18)
        
        labelView.addSubview(workoutTitle);
        
        let verticalConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: labelView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 5);
        
        let horizontalConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: labelView, attribute: NSLayoutAttribute.CenterXWithinMargins, multiplier: 1.0, constant: 0);
        
        let heightConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);
        
        let widthConstraint = NSLayoutConstraint(item: workoutTitle, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 200);
        
        labelView.addConstraints([verticalConstraint, horizontalConstraint, heightConstraint, widthConstraint]);
        
        let pinTop = NSLayoutConstraint(item: labelView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0);
        
        let pinLeft = NSLayoutConstraint(item: labelView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0);
        
        let pinHeight = NSLayoutConstraint(item: labelView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);
        
        let pinWidth = NSLayoutConstraint(item: labelView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: subScrollView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0);
        
        subScrollView.addSubview(labelView);
        subScrollView.addConstraints([pinTop, pinLeft, pinHeight, pinWidth]);
    }
    
    
    func setupSetViews(){
        
    
        var counter = 0;
        
        for(var i = 0; i < self.instructionJson!["0"].count; i++){
            
            //First, look at an individual set and order it appropriately based on a few rules
            //This should return something like -> reps : 5, weight : 100
            let orderedSet : [Dictionary<String, String>] = determineOrder(self.instructionJson!["0"][i]);
            
            if(i == 0){ //Need to add labels for the set fields
                
                let setLabelRow = UIView();
                setLabelRow.translatesAutoresizingMaskIntoConstraints = false;
                
                for(var i = 0; i < self.instructionFields!.count; i++){
                    
                    let setLabel  = UILabel();
                    
                    setLabel.text = self.instructionFields![i].firstCharacterUpperCase();
                    setLabel.textAlignment = .Left;
                    setLabel.translatesAutoresizingMaskIntoConstraints = false;
                    constrainLabels(setLabel, parent: setLabelRow, counter: i);
                }
                constrainSetLabelRow(setLabelRow, parent: subScrollView);
            }
            
            if(orderedSet.count > 0){
                
                sets.append(UIView());
                
                let setLabel : UILabel          = UILabel();
                var fields   : [UIView]         = [UIView]();
                
                setLabel.text = String("Set \(i + 1)");
                setLabel.translatesAutoresizingMaskIntoConstraints = false;
                

                for(var x = 0; x < orderedSet.count; x++){
                
                    for(key, value) : (String, String) in orderedSet[x]{ //Now, loop through an individual set and make UITextFields
                
                        //print("ordered set \(key) , value: \(value)");
                        let tempField  = UITextField();
                        tempField.text = value;
                        tempField.textAlignment = .Center;
                        tempField.userInteractionEnabled = false;
                        addBorder(tempField, edges: [.Bottom], colour: UIColor.lightGrayColor(), thickness: 1);
                        fields.append(tempField);
                        
                        if(x != orderedSet.count - 1){
                            let xField = UILabel();
                            xField.text = "x";
                            xField.textAlignment = .Center;
                            fields.append(xField);
                        }
                        
                
                    }
                }
            

                constrainSetLabel(setLabel, superview : sets[counter]);
                sets[counter].translatesAutoresizingMaskIntoConstraints = false;
                constrainFields(fields, parentView : sets[counter]);
                subScrollView.addSubview(sets[counter]);
                counter++;
            }
        }
        constrainSets(sets, parentView : subScrollView);
        subScrollView.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(subScrollView);
        constrainSubToScroll(subScrollView, scrollView : self);
        
        let heightAttr    = CGFloat(sets.count) * rowHeight + rowHeight;
        
        //Note width will be changed once view is laid out properly
        let subWidthConst = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 300);
        
        let heightConstraint = NSLayoutConstraint(item: subScrollView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: heightAttr);
        
        subScrollView.addConstraints([subWidthConst, heightConstraint]);
        
    }
    
    /**
    This function constrains the scroll views child ui view to itself
     */
    func constrainSubToScroll(subview : UIView, scrollView : UIScrollView){
        
        let pinTop = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant:0);
        
        let pinBottom = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0);
        //CGFloat(heightsTotal + (self.workoutInstructionTiles.count * 10))
        
        let pinLeft = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        let pinRight = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
        
        
        scrollView.addConstraints([pinTop, pinBottom, pinLeft, pinRight]);
    }
    
    /**
    This function constrains the actual data for a set like 5 x 200
     */
    
    func constrainFields(fields : [UIView], parentView : UIView){
        
        for(var i = 0; i < fields.count; i++){
            
            fields[i].translatesAutoresizingMaskIntoConstraints = false;
            parentView.addSubview(fields[i]);
            var leftConstraint : NSLayoutConstraint!;
        
            if(i > 0){
                leftConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: fields[i - 1], attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 40);
                
            } else{

                leftConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 150);
            }
        
            let topConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        
            let heightConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);
            
            let widthConstraint = NSLayoutConstraint(item: fields[i], attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 40);
            
            parentView.addConstraints([leftConstraint, topConstraint, heightConstraint, widthConstraint]);
        }
    }
    
    /**
    This function basically constrains the label for individual sets -> like set 1, set 2, etc
     */
    func constrainSetLabel(label : UIView, superview : UIView){
        
        superview.addSubview(label);
        
        let leftConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20);
        
        let topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);

        superview.addConstraints([leftConstraint, topConstraint, heightConstraint]);
    }
    
    
    /**
    This function constrains sets like block elements in side of a workout instruction tile
     */
    
    func constrainSets(allSets : [UIView], parentView : UIView){
        
        for(var i = 0; i < allSets.count; i++){
            
        
            let leftConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
            
            let rightConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);

        
            let topConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: CGFloat(rowHeight + (rowHeight * CGFloat((i + 1)))))
        
            let heightConstraint = NSLayoutConstraint(item: allSets[i], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);
            
            parentView.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint]);
        }
    }
    
    /**
     This function constrains the set field label's row to the parent UIView
     */
    func constrainSetLabelRow(child : UIView, parent : UIView){
        
        parent.addSubview(child);
        
        let leftConstraint = NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0);
        
        let rightConstraint = NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0);
        
        
        let topConstraint = NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: rowHeight)
        
        let heightConstraint = NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);
        
        parent.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint]);
    }
    
    /**
     This function constrains labels for set fields like reps, weight, etc
    */
    func constrainLabels(label : UILabel, parent : UIView, counter : Int){
        
        parent.addSubview(label);
        
        var leftConstraint : NSLayoutConstraint!;
        
        if(counter > 0){
            leftConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: CGFloat(150 + (counter * 80))); //80 bc it's skipping the space for "x"
            
        } else{
            
            leftConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 150);
        }
        
        let topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rowHeight);
        
        let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 60);
        
        parent.addConstraints([leftConstraint, topConstraint, heightConstraint, widthConstraint]);

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
        
        
        self.instructionFields = log;
        return temp;
    }
    


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    /**
     
     Adds a border to whatever sides are specified in the edges array in addition to a color and a thickness
     It's called like this:
     
     addBorder(tempField, edges: [.Bottom], colour: UIColor.lightGrayColor(), thickness: 1);
     
     */
    func addBorder(aView : UIView, edges: UIRectEdge, colour: UIColor = UIColor.whiteColor(), thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRectZero)
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.Top) || edges.contains(.All) {
            let top = border()
            aView.addSubview(top)
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[top(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[top]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.Left) || edges.contains(.All) {
            let left = border()
            aView.addSubview(left)
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[left(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["left": left]))
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[left]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.Right) || edges.contains(.All) {
            let right = border()
            aView.addSubview(right)
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:[right(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["right": right]))
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[right]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.Bottom) || edges.contains(.All) {
            let bottom = border()
            aView.addSubview(bottom)
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:[bottom(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["bottom": bottom]))
            aView.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[bottom]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    /**
        This function will handle when a user begins and finishes editing a workout
     */
    func beginEdit(sender : AnyObject){
        
        if(isEditing){
            
            isEditing = !isEditing;
            
            let origImage = UIImage(named: "ic_mode_edit");
            let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) //Allows us to change color programmatically
            editButton.setImage(tintedImage, forState: .Normal)
            editButton.addTarget(self, action: "beginEdit:", forControlEvents: UIControlEvents.TouchUpInside);
            editButton.tintColor = UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1.0);
            
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                
                self.layer.backgroundColor = UIColor.whiteColor().CGColor;
                
                }, completion: {(finished : Bool) -> Void in
                    
                    if(finished){
                        self.changeTextFieldState(false);
                        self.grabInstructionData();
                    }
                    
            });
            
            
        } else{
            
            isEditing = !isEditing;
            
            let origImage = UIImage(named: "ic_check");
            let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            editButton.setImage(tintedImage, forState: .Normal)
            editButton.tintColor = UIColor(red: 46/255, green: 125/255, blue: 50/255, alpha: 1.0);
            
            
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                
                self.layer.backgroundColor = UIColor(red: 200/255, green: 230/255, blue: 201/255, alpha: 1.0).CGColor;
                
                }, completion: {(finished : Bool) -> Void in
                    
                    if(finished){
                        self.changeTextFieldState(true);
                    }
            
            });
            
        }
    }
    
    /**
     This loops through the fields of a workout and sets parameters as editable or uneditable
     */
    func changeTextFieldState(isEditable : Bool){
        
        let views = self.subScrollView.subviews;
        
        for(var i = 2; i < views.count; i++){
            
            let subs = views[i].subviews;
            var counter = 0;
            for(var x = 0; x < subs.count; x++){
                
                
                if(subs[x] is UITextField){
                    
                    subs[x].userInteractionEnabled = isEditable;
                    
                    if(i == 2 && counter == 0 && isEditable){ //If this is the first text field we've looked at, make sure to give it focus
                        subs[x].becomeFirstResponder();
                    }
                    counter++;
                }
            }
        }
    }
    
    
    func grabInstructionData() -> NSMutableDictionary{
        
        let views                 = self.subScrollView.subviews;

        var dict : NSMutableDictionary = NSMutableDictionary();
        dict.setValue(self.workoutDayId, forKey : "workoutDayId");
        dict.setValue(NSMutableArray(), forKey : "instructions");
        
        var instructionsArr = dict.objectForKey("instructions") as! NSMutableArray;
        instructionsArr.addObject(NSMutableDictionary());
        var instructions = instructionsArr.objectAtIndex(0);
        instructions.setValue(self.instructionId, forKey: "instructionId");
        instructions.setValue(self.workoutId, forKey: "workoutId");
        instructions.setValue(NSMutableArray(), forKey : "sets");
        
        var countSets = 0;
        for(var i = 2; i < views.count; i++){
            
            let subs = views[i].subviews;
            var sets = instructions.objectForKey("sets") as! NSMutableArray;
            sets.addObject(NSMutableArray());
            var countFields = 0;
//            dict["sets"][countSets] = JSON(NSMutableArray);

            for(var x = 0; x < subs.count; x++){
                
                if(subs[x] is UITextField){
                    
                    let fieldText = subs[x] as! UITextField;
                    let nextField = NSMutableDictionary();
                    print("field \(self.instructionFields![countFields])");
                    nextField.setValue(self.instructionFields![countFields], forKey: "field");
                    nextField.setValue(fieldText.text!, forKey : "value");
                    sets.objectAtIndex(countSets).addObject(nextField);
//                    let nextField = JSON(["field" : self.instructionFields![x], "value"  : fieldText.text!]).dictionary{
//                        dict["sets"][countSets][x]  += nextField
//                    }
                    
                    countFields++;
                }
            }
            countSets++;
        }
        
        let ret = JSON(dict);
        //print("swiftyjson");
        //print(ret.rawString());
    
     
        let Requester = RequestData(data: dict, aUrl : "http://localhost/PtManagement/athletes/php/updateInstructionActuals.php");
        do{
            try Requester.updateActuals({(jsonDict : JSON) -> Void in
                print("request result \(jsonDict)");
            });
        } catch{
                
        }
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let theJsonText = NSString(data: jsonData, encoding: NSASCIIStringEncoding)
            print("json data \(theJsonText!)");
        } catch let error as NSError {
            print(error)
        }
        
        return dict;

    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
