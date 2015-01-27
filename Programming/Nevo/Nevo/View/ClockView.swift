//
//  ClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/1/20.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

import UIKit

/*
A view that ressembles the nevo watch face
*/

let kNEVOClockAnimationIncrement:CGFloat = 30;

struct NEVOVector3D {
    var x:CGFloat = 0;
    var y:CGFloat = 0;
    var z:CGFloat = 0;
}

class ClockView: UIControl {
    ///The hour and minute that the clock is currently displaying.
    var hour: NSInteger = 0;
    var minute: NSInteger = 0;

    //When setting a time, you may wish to always work with UTC. In this case,
    //you can provide an offset for other locales.
    var hourOffset: NSInteger = 0;
    var minuteOffset: NSInteger = 0;
    

    //A short string shown near the top of the clock.
    var title: String = "";

    //A short string shown near the bottom of the clock.
    var subtitle: String = "";

    //Attributes that describe how the title, subtitle and digits should be rendered.
    // Setup the default text attributes
    var titleAttributes: NSDictionary = NSDictionary();
    var subtitleAttributes: NSDictionary = NSDictionary()
    var digitAttributes: NSDictionary = NSDictionary()

    /*
    By setting this to YES, the minute hand will move slowly around
    the clock when the user drags. Default is NO.
    */
    // Theminute hand can move smoothly or at second intervals.
    var minuteHandMovesSmoothly: Bool = false;

    /*
    Customisation for the markings that are displayed around the circumference
    of the clock.
    */
    var majorMarkingColor: UIColor = UIColor(white:0.3, alpha:1.0);
    var minorMarkingColor: UIColor = UIColor(white:0.4, alpha:1.0);
    var majorMarkingsThickness: CGFloat = 1.0;
    var minorMarkingsThickness: CGFloat = 1.0;
    var majorMarkingsLength: CGFloat = 5.0;
    var minorMarkingsLength: CGFloat = 1.0;
    var markingsInset: CGFloat = 5.0;

    /*
    Customisation for the clock hands.
    */
    var minuteHandColor: UIColor = UIColor(white:0.2, alpha:1.0);
    var hourHandColor: UIColor = UIColor(white:0.2, alpha:1.0);
    var minuteHandThickness: CGFloat = 5.0;
    var hourHandThickness: CGFloat = 5.0;

    /**
    Customisation for the border the clock border Color.
    */
    var borderColor: UIColor = UIColor.redColor();
    var borderWidth: CGFloat = 6.0;

    /*
    Describes whether the clock is showing an AM or PM time
    */
    var isAM: Bool = true
    // Have the hands pointing up initially.
    var totalRotation: CGFloat = 0
    var radius: CGFloat = 0.0
    // Set default colours
    var clockFaceBackgroundColor: UIColor = UIColor(white:0.97, alpha:1.0)
    var isAnimating: Bool = false
    var timer: NSTimer = NSTimer()
    var targetRotation: CGFloat = 0


    override init(frame: CGRect) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.clearColor()
        // How wide should the clock be?
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        titleAttributes = [NSForegroundColorAttributeName:UIColor(white:0.2, alpha:1.0),NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:UIFont.systemFontOfSize(20.0)]
        subtitleAttributes = [NSForegroundColorAttributeName:UIColor(white: 0.4, alpha: 1.0),NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:UIFont.systemFontOfSize(13.0)];
        digitAttributes = [NSForegroundColorAttributeName:UIColor(white: 0.0, alpha: 1.0),NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:UIFont.systemFontOfSize(16.0)];

        updateRadius();

    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
    @param hour The hour the clock should display
    @param animated Should the transition be animated
    */
    func setHour(hour:NSInteger, animated:Bool){
        self.setHour(hour, minute: self.minute, animated:animated)
    }

    /**
    @param hour The hour the clock should display
    @param minnute The minute the clock should display
    @param animated Should the transition be animated
    */
    func setHour(hour:NSInteger ,minute:NSInteger , animated:Bool){
        if(self.isAnimating){
            return;
        }

        var rotation:CGFloat = self.rotationForHour(CGFloat(hour+self.hourOffset), minute: minute+self.minuteOffset)
        self.targetRotation = rotation;

        if (animated){
            self.animateClockToHour(hour+self.hourOffset , minute: minute+self.minuteOffset)
        }else{
            self.minute = (minute+self.minuteOffset + 60) % 60;
            self.hour = (hour+self.hourOffset + 24) % 24;

            self.totalRotation = rotation;
            self.setNeedsDisplay();
        }
    }

    /**
    @param minnute The minute the clock should display
    @param animated Should the transition be animated
    */
    func setMinute(minute:(NSInteger),animated:(Bool)){
        self.setHour(hour, minute: minute, animated: animated)
    }
    func updateRadius(){
        radius = min(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0) - 20
    }

    func setBorderColor(borderColor:UIColor){
        self.borderColor = borderColor
        self.setNeedsDisplay()
    }

    func setBackgroundColor(backgroundColor:UIColor){
        // As we always want the background of this view to be
        // clear, we override this default method an make it
        // change the background colour of the clock instead.
        self.clockFaceBackgroundColor = backgroundColor;
        self.setNeedsDisplay();
    }

    func animateClockToHour(hour:NSInteger, minute:NSInteger){
        // Flag animation to prevent interations
        self.isAnimating = true;
        // Either snap to the target immediately, or fire a timer to animate
        if(self.shouldSnapToTargetRotation()){
            self.snapToTarget()
        } else {
            if self.timer.valid{
                self.timer.invalidate()
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1/60.0, target: self, selector: Selector("handleTimer:"), userInfo: nil, repeats: true)
            }
        }
    }

    func shouldSnapToTargetRotation()->Bool{
        // If we're within 1 increment, we should snap to the target
        if (abs(self.targetRotation - self.totalRotation) < kNEVOClockAnimationIncrement){
            return true;
        }else{
            return false;
        }
    }

    func snapToTarget(){
        // As we've been told to snap to the target angle, kill the timer
        if(self.timer.valid){
            self.timer.invalidate()
        }
        // Perform the snap, then update the hour and minute.
        self.totalRotation = self.targetRotation;
        hour = NSInteger(floor(fmod(-self.totalRotation/360.0 + 24, 24)));
        minute = NSInteger(floor(fmod(-self.totalRotation/6.0 + 60, 60)));

        self.updateDisplayAndListeners();

        // No loger animating, so we'll allow interation again.
        self.isAnimating = true;
    }

    func handleTimer(timer:NSTimer){
        // Find the shortest direction to spin and then add the increment
        // (possibly negative)

        if(fmod(self.targetRotation - self.totalRotation + 24 * 360, 24 * 360) <
            fmod(self.totalRotation - self.targetRotation + 24 * 360, 24 * 360)){
                self.totalRotation = fmod(self.totalRotation + kNEVOClockAnimationIncrement, 24 * 360);
        }else{
            self.totalRotation = fmod(self.totalRotation - kNEVOClockAnimationIncrement, 24 * 360);
        }

        // Update the hour and minute
        hour = NSInteger(floor(fmod(-self.totalRotation/360.0 + 24, 24)));
        minute = NSInteger(floor(fmod(-self.totalRotation/6.0 + 60, 60)));

        // Check to see if we should snap to the target, or just update
        // the view and any listeners.

        if(self.shouldSnapToTargetRotation()){
            self.snapToTarget();
        }else{
            self.updateDisplayAndListeners();
        }

    }

    func updateDisplayAndListeners(){
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.setNeedsDisplay()
    }

    override func beginTrackingWithTouch(touch:UITouch, withEvent:UIEvent)->Bool{
        super.beginTrackingWithTouch(touch, withEvent: withEvent)
        self.sendActionsForControlEvents(UIControlEvents.TouchDragEnter)
        //We need to track continuously
        return true;
    }

    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool{
        super.continueTrackingWithTouch(touch, withEvent: event)
        if(self.isAnimating){
            return false;
        }
        //Get touch location
        var currentPoint:CGPoint = touch.locationInView(self);
        var previousPoint:CGPoint = touch.previousLocationInView(self);

        //Use the location to design the Handle
        //self.moveHandFromPoint(previousPoint, toPoint: currentPoint)
        return true;
    }

    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        self.sendActionsForControlEvents(UIControlEvents.TouchDragExit)
    }


    func moveHandFromPoint(fromPoint:CGPoint, toPoint:CGPoint) {
        var center:CGPoint = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);

        var u1:NEVOVector3D = self.vectorFromPoint(center, toPoint: fromPoint);
        var u2:NEVOVector3D = self.vectorFromPoint(center, toPoint: toPoint);

        // We find the smallest angle between these two vectors
        var deltaAngle:CGFloat = self.angleBetweenVector(u1, andVector: u2);

        // Calculate if we are moving clockwise or anti-clockwise
        var directedDeltaAngle:CGFloat = self.isMovingCounterClockwise(u1, vector: u2) ? deltaAngle : -1 * deltaAngle;

        // Update the total rotation
        self.totalRotation = fmod(self.totalRotation + directedDeltaAngle, 24 * 360);

        // Update the hour and minute properties

        self.hour = NSInteger(floor(fmod(-self.totalRotation/360.0 + 24, 24)));
        self.minute = NSInteger(floor(fmod(-self.totalRotation/6.0 + 60, 60)));
        
        //Redraw
        self.updateDisplayAndListeners()
    }

    override func drawRect(rect: CGRect) {
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        var center:CGPoint = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);

        // We find a max width to ensure that the clock is always
        // bounded by a square box

        var maxWidth:CGFloat = min(self.frame.size.width, self.frame.size.height)

        // Create a rect that maximises the area of the clock in the
        // square box

        var rectForClockFace:CGRect = CGRectInset(CGRectMake((self.frame.size.width - maxWidth)/2.0,
            (self.frame.size.height - maxWidth)/2.0,
            maxWidth,
            maxWidth), 2*self.borderWidth, 2*self.borderWidth);

        // --------------------------
        // -- Draw the background  --
        // --------------------------
        // Draw the clock background
        CGContextSetFillColorWithColor(context, self.clockFaceBackgroundColor.CGColor);
        CGContextFillEllipseInRect(context, rectForClockFace);

        // --------------------------
        // --    Draw the title    --
        // --------------------------
        var titleRect:CGRect = CGRectMake(CGRectGetMinX(rectForClockFace) + CGRectGetWidth(rectForClockFace)*0.2,
            CGRectGetMinY(rectForClockFace) + CGRectGetHeight(rectForClockFace)*0.25,
            CGRectGetWidth(rectForClockFace)*0.6,
            20.0);

        self.title.drawInRect( titleRect, withAttributes :self.titleAttributes)

        // --------------------------
        // --  Draw the subtitle   --
        // --------------------------
        var subtitleRect:CGRect = CGRectMake(CGRectGetMinX(rectForClockFace) + CGRectGetWidth(rectForClockFace)*0.2,
            CGRectGetMinY(rectForClockFace) + CGRectGetHeight(rectForClockFace)*0.65,
            CGRectGetWidth(rectForClockFace)*0.6,
            20.0);

        self.subtitle.drawInRect( subtitleRect, withAttributes :self.subtitleAttributes)

        // --------------------------
        // --  Draw the markings   --
        // --------------------------
        // Set the colour of the major markings
        CGContextSetStrokeColorWithColor(context, self.majorMarkingColor.CGColor);
        // Set the major marking width
        CGContextSetLineWidth(context, self.majorMarkingsThickness);

        // Draw the major markings
        for var i = 0; i < 12; i++ {
            // Get the location of the end of the hand
            var markingDistanceFromCenter:CGFloat = rectForClockFace.size.width/2.0 - self.markingsInset;
            var markingX1:CGFloat = center.x+markingDistanceFromCenter * cos((CGFloat(M_PI)/180.0)*(CGFloat(i))*30.0 + CGFloat(M_PI));
            var markingY1:CGFloat = center.y + (-1) * markingDistanceFromCenter * sin((CGFloat(M_PI)/180) * (CGFloat(i)) * 30);
            var markingX2:CGFloat = center.x + (markingDistanceFromCenter - self.majorMarkingsLength) * cos((CGFloat(M_PI)/180) * CGFloat(i) * 30 + CGFloat(M_PI));
            var markingY2:CGFloat = center.y + (-1) * (markingDistanceFromCenter - self.majorMarkingsLength) * sin((CGFloat(M_PI)/180) * (CGFloat(i)) * 30);

            // Move the cursor to the edge of the marking
            CGContextMoveToPoint(context, markingX1, markingY1);

            // Move to the end of the hand
            CGContextAddLineToPoint(context, markingX2, markingY2);
        }

        // Draw minor markings.
        CGContextDrawPath(context, kCGPathStroke);

        // Set the colour of the minor markings
        CGContextSetStrokeColorWithColor(context, self.minorMarkingColor.CGColor);

        // Set the minor minor width
        CGContextSetLineWidth(context, self.minorMarkingsThickness);

        for var i = 0; i < 60; i++ {
            // Don't put a minor mark if there's already a major mark
            if ((i % 5) == 0){
                continue
            }

            // Get the location of the end of the hand
            var markingDistanceFromCenter:CGFloat = rectForClockFace.size.width/2.0 -  self.markingsInset;

            var markingX1:CGFloat = center.x + markingDistanceFromCenter * cos((CGFloat(M_PI)/180) * (CGFloat(i)) * 6 + CGFloat(M_PI));
            var markingY1:CGFloat = center.y + (-1) * markingDistanceFromCenter * sin((CGFloat(M_PI)/180) * (CGFloat(i)) * 6);

            var markingX2:CGFloat = center.x + (markingDistanceFromCenter - self.minorMarkingsLength) * cos( (CGFloat(M_PI)/180) * (CGFloat(i)) * 6 + CGFloat(M_PI));
            var markingY2:CGFloat = center.y + (-1) * (markingDistanceFromCenter - self.minorMarkingsLength) * sin((CGFloat(M_PI)/180) * (CGFloat(i)) * 6);

            // Move the cursor to the edge of the marking
            CGContextMoveToPoint(context, markingX1, markingY1);

            // Move to the end of the hand
            CGContextAddLineToPoint(context, markingX2, markingY2);
        }

        // Draw minor markings.
        CGContextDrawPath(context, kCGPathStroke);

        // Draw the digits
        for var i = 0; i < 12; i++ {
            var digitFont:UIFont = UIFont.systemFontOfSize(16.0);

            var markingDistanceFromCenter:CGFloat = rectForClockFace.size.width/2.0 - digitFont.lineHeight/4.0 - self.markingsInset - max(self.majorMarkingsLength, self.minorMarkingsLength);
            let offset:NSInteger = 4;

            var labelX:CGFloat = center.x + (markingDistanceFromCenter - digitFont.lineHeight/2.0) * cos((CGFloat(M_PI)/180) * (CGFloat(i)+CGFloat(offset)) * 30 + CGFloat(M_PI));
            var labelY:(CGFloat) = center.y + (-1) * (markingDistanceFromCenter - digitFont.lineHeight/2.0) * sin((CGFloat(M_PI)/180)*(CGFloat(i)+CGFloat(offset)) * 30);

            var hourNumber:NSString = NSString(format:"%i", i+1);
            hourNumber.drawInRect(CGRectMake(labelX - digitFont.lineHeight/2.0,labelY - digitFont.lineHeight/2.0,digitFont.lineHeight,digitFont.lineHeight), withAttributes: self.digitAttributes)
        }

        // --------------------------
        // --  Draw the hour hand  --
        // --------------------------
        // Set the hand width
        CGContextSetLineWidth(context, self.hourHandThickness);

        // Set the colour of the hand
        CGContextSetStrokeColorWithColor(context, self.hourHandColor.CGColor);

        // Offset the hour hand by 90 degrees
        var hourHandAngle:CGFloat = fmod(self.totalRotation * 1/12.0, 360);
        hourHandAngle += 90;

        // Move the cursor to the center
        CGContextMoveToPoint(context, center.x, center.y);

        // Get the location of the end of the hand
        var hourHandX:CGFloat = center.x + (0.6*self.radius) * cos((CGFloat(M_PI)/180)*hourHandAngle);
        var hourHandY:CGFloat = center.y + (-1) * (0.6*self.radius) * sin((CGFloat(M_PI)/180)*hourHandAngle);

        // Move to the end of the hand
        CGContextAddLineToPoint(context, hourHandX, hourHandY);

        // Draw hour hand.
        CGContextDrawPath(context, kCGPathStroke);

        // --------------------------
        // -- Draw the minute hand --
        // --------------------------
        // Set the hand width
        CGContextSetLineWidth(context, self.minuteHandThickness);

        // Set the colour of the hand
        CGContextSetStrokeColorWithColor(context, self.minuteHandColor.CGColor);

        var minuteHandAngle:CGFloat = ceil(fmod(self.totalRotation + 24 * 360, 24 * 360) / 6.0) * 6;
        if (self.minuteHandMovesSmoothly){
            minuteHandAngle = self.totalRotation
        }

        // Offset the minute hand by 90 degrees
        minuteHandAngle += 90;

        // Move the cursor to the center
        CGContextMoveToPoint(context, center.x, center.y );

        // Get the location of the end of the hand
        var minuteHandX:CGFloat = center.x + 0.90*self.radius * cos((CGFloat(M_PI)/180)*minuteHandAngle);
        var minuteHandY:CGFloat = center.y + (-1) * 0.90*self.radius * sin((CGFloat(M_PI)/180)*minuteHandAngle);

        // Move to the end of the hand
        CGContextAddLineToPoint(context, minuteHandX, minuteHandY);

        // Draw minute hand.
        CGContextDrawPath(context, kCGPathStroke);

        // --------------------------
        // -- Draw the centre cap  --
        // --------------------------
        CGContextSetFillColorWithColor(context, self.minuteHandColor.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMidX(rectForClockFace)-8,CGRectGetMidY(rectForClockFace)-8,16,16));

        // --------------------------
        // --   Draw the stroke    --
        // --------------------------
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextSetLineWidth(context, 2 * self.borderWidth);
        CGContextAddEllipseInRect(context, CGRectInset(rectForClockFace, -self.borderWidth, -self.borderWidth));
        CGContextDrawPath(context, kCGPathStroke);

    }

    func rotationForHour(hour:CGFloat,minute:NSInteger) ->CGFloat{
        return (CGFloat(-minute)) * 6 - hour * 360;
    }

    func returnMinutes()->NSInteger{
        return (minute + 60) % 60;
    }

    func returnHour()->NSInteger{
        return (hour + 24) % 24;
    }

    func returnTargetRotation()->CGFloat{
        return fmod(fmod(targetRotation, 24 * 360) + 24 * 360, 24 * 360);
    }

    func returnTotalRotation()->CGFloat{
        return fmod(fmod(totalRotation, 24 * 360) + 24 * 360, 24 * 360);
    }

    func returnIsAM()->Bool{
        return self.totalRotation > 4320 ? true:false
    }

    func description()->NSString{
        return NSString(format: "%d:%d, isAM:%d, isAnimating:%d", self.hour, self.minute, self.isAM, self.isAnimating);
    }

    func setHour(hour:NSInteger){
        self.setHour(hour, animated: false)
    }

    func setMinute(minute:NSInteger){
        self.setMinute(minute, animated: false)
    }

    func vectorFromPoint(fromPoint:CGPoint, toPoint:CGPoint)->NEVOVector3D{
        var v:NEVOVector3D = NEVOVector3D(x:toPoint.x-fromPoint.x, y: toPoint.y - fromPoint.y, z: 0);
        return v;
    }

    func dotProductOfVector(v1:NEVOVector3D ,andVector:NEVOVector3D)->CGFloat{
        let value:CGFloat = v1.x * andVector.x + v1.y * andVector.y + v1.z * andVector.z;
        return value;
    }

    func angleBetweenVector(v1:NEVOVector3D, andVector:NEVOVector3D)->CGFloat{
        let normOfv1:CGFloat = sqrt(self.dotProductOfVector(v1, andVector: v1))
        let normOfv2:CGFloat = sqrt(self.dotProductOfVector(andVector, andVector: andVector));

        let angle:CGFloat = (180/CGFloat(M_PI)) * acos( fmin(self.dotProductOfVector(v1, andVector: andVector) / (normOfv1 * normOfv2), 1) );
        return angle;
    }

    func crossProductOfVector(v1:NEVOVector3D ,andVector:NEVOVector3D)->NEVOVector3D{
        var v = NEVOVector3D(x:v1.y*andVector.z - v1.z*andVector.y,y:-1 * (v1.x*andVector.z - v1.z*andVector.x),z:v1.x*andVector.y - v1.y*andVector.x);
        return v;
    }


    func isMovingCounterClockwise(v1:NEVOVector3D ,vector:NEVOVector3D)->Bool{
        var normal = NEVOVector3D(x:0,y:0,z:1);
        let crossProduct:NEVOVector3D = self.crossProductOfVector(v1, andVector: vector);
        let isCounterClockwise:Bool = (self.dotProductOfVector(crossProduct, andVector: normal) < 0) ? true : false;

        return isCounterClockwise;
    }

    func currentTimer() {
        let now:NSDate = NSDate()
        let cal:NSCalendar = NSCalendar.currentCalendar()
        let unitFlags:NSCalendarUnit = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
        let dd:NSDateComponents = cal.components(unitFlags, fromDate: now);
        let hour:NSInteger = dd.hour;
        let min:NSInteger = dd.minute;
        setHour(hour, minute: min, animated: false)

    }
}