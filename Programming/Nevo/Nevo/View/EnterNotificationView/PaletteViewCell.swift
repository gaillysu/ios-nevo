//
//  PaletteViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/5.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

protocol PaletteDelegate {

    func selectedPalette(color:UIColor)

}

class PaletteViewCell: UITableViewCell {

    @IBOutlet weak var blueButton: UIButton!

    @IBOutlet weak var redButton: UIButton!

    @IBOutlet weak var greenButton: UIButton!

    @IBOutlet weak var yellowButton: UIButton!

    var pDelegate:PaletteDelegate!

    @IBAction func PaletteButtonManager(sender: AnyObject) {
        let senders:UIButton = sender as UIButton

        if (senders.isEqual(blueButton)){

            pDelegate.selectedPalette(UIColor.blueColor())
        }else if (senders.isEqual(redButton)){

            pDelegate.selectedPalette(UIColor.redColor())
        }else if (senders.isEqual(greenButton)){

            pDelegate.selectedPalette(UIColor.greenColor());
        }else if (senders.isEqual(yellowButton)){

            pDelegate.selectedPalette(UIColor.yellowColor())
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        blueButton.setTitle(NSLocalizedString("Blue",comment: ""), forState: UIControlState.Normal)
        redButton.setTitle(NSLocalizedString("Red",comment: ""), forState: UIControlState.Normal)
        greenButton.setTitle(NSLocalizedString("Green",comment: ""), forState: UIControlState.Normal)
        yellowButton.setTitle(NSLocalizedString("Yellow",comment: ""), forState: UIControlState.Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
