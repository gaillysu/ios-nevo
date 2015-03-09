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

    @IBOutlet weak var orangeButton: UIButton!

    @IBOutlet weak var cyanButton: UIButton!

    @IBOutlet weak var currentLabel: UILabel!

    @IBOutlet weak var currentColorView: UIView!

    var pDelegate:PaletteDelegate!
    var currentColor:UIColor!


    @IBAction func PaletteButtonManager(sender: AnyObject) {
        let senders:UIButton = sender as UIButton

        if (senders.isEqual(blueButton)){
            currentColor = UIColor.blueColor()
            pDelegate.selectedPalette(currentColor)
        }else if (senders.isEqual(redButton)){
            currentColor = UIColor.redColor()
            pDelegate.selectedPalette(currentColor)
        }else if (senders.isEqual(greenButton)){
            currentColor = UIColor.greenColor()
            pDelegate.selectedPalette(currentColor);
        }else if (senders.isEqual(yellowButton)){
            currentColor = UIColor.yellowColor()
            pDelegate.selectedPalette(currentColor)
        }else if (senders.isEqual(orangeButton)){
            currentColor = UIColor.orangeColor()
            pDelegate.selectedPalette(currentColor)
        }else if (senders.isEqual(cyanButton)){
            currentColor = AppTheme.PALETTE_BAGGROUND_COLOR()
            pDelegate.selectedPalette(currentColor)
        }
        currentColorView.backgroundColor = currentColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        blueButton.setTitle(NSLocalizedString(" ",comment: ""), forState: UIControlState.Normal)
        redButton.setTitle(NSLocalizedString(" ",comment: ""), forState: UIControlState.Normal)
        greenButton.setTitle(NSLocalizedString(" ",comment: ""), forState: UIControlState.Normal)
        yellowButton.setTitle(NSLocalizedString(" ",comment: ""), forState: UIControlState.Normal)
        orangeButton.setTitle(NSLocalizedString(" ",comment: ""), forState: UIControlState.Normal)
        cyanButton.setTitle(NSLocalizedString(" ",comment: ""), forState: UIControlState.Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
