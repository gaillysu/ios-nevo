//
//  AppTheme.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/**
This class holds all app-wide constants.
Colors, fonts etc...
*/
class AppTheme {
    
    /**
    This color should be used app wide on all actionable elements
    sRGB value : #ff9933
    */
    class func NEVO_SOLAR_YELLOW() -> UIColor {
        return UIColor(red: 255/255.0, green: 153/255.0, blue: 51/255.0, alpha: 1)
    }

    class func NEVO_SOLAR_GRAY() -> UIColor {
        return UIColor(red: 186/255.0, green: 185/255.0, blue: 182/255.0, alpha: 1)
    }

    class func SYSTEMFONTOFSIZE(mSize size:CGFloat = 25) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
    class func FONT_RALEWAY_BOLD(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"Raleway-Bold", size: size)!
    }

    class func FONT_RALEWAY_LIGHT(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"Raleway-Light", size: size)!
    }

    class func FONT_RALEWAY_THIN(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"Raleway-Thin", size: size)!//Uniform
    }

    class func PALETTE_BAGGROUND_COLOR() -> UIColor {
        return UIColor(red: 10/255.0, green: 255/255.0, blue: 178/255.0, alpha: 1)//Uniform
    }

    /**
    Access to resources image

    :param: imageName resource name picture

    :returns: Return to obtain images of the object
    */
    class func GET_RESOURCES_IMAGE(imageName:String) -> UIImage {
        let imagePath:String = NSBundle.mainBundle().pathForResource(imageName, ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!

    }

}