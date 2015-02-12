//
//  TutorialScanPageView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class TutorialScanPageView : UIView {
    var mDelegate:Page3Controller?

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 23)!
    let BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!

    var connectButton:UIButton!
    var errorLabel:UILabel!
    var finishButton:UIButton!
    var optionIndices:NSMutableIndexSet = NSMutableIndexSet(index: 1)

    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page3Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        buildTutorialPage()
    }

    func buildTutorialPage() {

        let guideImage:UIImageView = UIImageView(image: UIImage(named: String("step3" as NSString)))
        guideImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        guideImage.center = CGPointMake(self.frame.size.width/2.0, 100)
        guideImage.contentMode = UIViewContentMode.ScaleAspectFit
        guideImage.userInteractionEnabled = true;
        guideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(guideImage)

        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, guideImage.frame.size.width, 50))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, guideImage.frame.origin.y+guideImage.frame.size.height+30)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.font = TEXT_FONT
        titleLabel.text = NSLocalizedString("ConnectButton",comment:"lable string")
        self.addSubview(titleLabel)


        connectButton = UIButton(frame: CGRectMake(0, 0, 150, 150))
        connectButton.setBackgroundImage(UIImage(named:"connect"), forState: UIControlState.Normal)
        connectButton.setTitle( NSLocalizedString("Connect",comment:"lable string"), forState: UIControlState.Normal)
        connectButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        connectButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0+50)
        connectButton.contentMode = UIViewContentMode.ScaleAspectFit
        connectButton.backgroundColor = UIColor.clearColor()
        connectButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(connectButton)


        finishButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        finishButton.frame = CGRectMake(0, 0, 120, 50)
    finishButton.setTitle(NSLocalizedString(NSLocalizedString("Finish",comment:"lable string"),comment:"button title string"), forState: UIControlState.Normal)
        finishButton.titleLabel?.font = BUTTON_FONT
        finishButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-90)
        finishButton.hidden = true
        finishButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(finishButton)

        errorLabel = UILabel(frame: CGRectMake(0, 0, titleLabel.frame.size.width, 80))
        errorLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-100)
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        errorLabel.font = TEXT_FONT
        errorLabel.text = NSLocalizedString("PlaceConnect",comment:"lable string")
        self.addSubview(errorLabel)

    }

    /*
    - (void)didTapItemAtIndex:(NSUInteger)index {
    BOOL didEnable = ! [self.selectedIndices containsIndex:index];

    if (self.borderColors) {
    UIColor *stroke = self.borderColors[index];
    UIView *view = self.itemViews[index];

    if (didEnable) {
    view.layer.borderColor = stroke.CGColor;

    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.fromValue = (id)[UIColor clearColor].CGColor;
    borderAnimation.toValue = (id)stroke.CGColor;
    borderAnimation.duration = 0.5f;
    [view.layer addAnimation:borderAnimation forKey:nil];

    [self.selectedIndices addIndex:index];
    }else {
    view.layer.borderColor = [UIColor clearColor].CGColor;
    [self.selectedIndices removeIndex:index];
    }

    CGRect pathFrame = CGRectMake(-CGRectGetMidX(view.bounds), -CGRectGetMidY(view.bounds), view.bounds.size.width, view.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:view.layer.cornerRadius];

    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.view convertPoint:view.center fromView:self.contentView];

    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = stroke.CGColor;
    circleShape.lineWidth = self.borderWidth;

    [self.view.layer addSublayer:circleShape];

    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];

    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;

    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
    }
    */
    func buttonAnimation(sender:UIButton) {
        let didEnable:Bool = !optionIndices.containsIndex(0)
        let stroke:UIColor = UIColor.blackColor();
        var view:UIView = sender as UIView;
        if (didEnable) {

        }else{

        }
    }
    /*
    Connect the Success to empty some pictures don't need the button and the label text
    */
    func connectSuccessClean() {
        connectButton.setTitle(" ", forState: UIControlState.Normal)
        connectButton.setBackgroundImage(UIImage(named:"success"), forState: UIControlState.Normal)
        finishButton.hidden = false
        errorLabel.hidden = true
    }
    /*
    Button Event handling all returns in the controller
    */
    func ButtonAction(sender:UIButton){

        mDelegate?.nextButtonAction(sender)
        
    }
    
}