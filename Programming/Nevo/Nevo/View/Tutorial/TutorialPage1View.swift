//
//  TutorialPage1View.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class TutorialPage1View : UIView {
    
    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)

        buildTutorialPage()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildTutorialPage()
    }
    
    func buildTutorialPage() {
        
        let guideImage:UIImageView = UIImageView(image: UIImage(named: String("nevo360" as NSString)))
        guideImage.userInteractionEnabled = true;
        guideImage.backgroundColor = UIColor.clearColor();
        
        self.addSubview(guideImage)
    }

}