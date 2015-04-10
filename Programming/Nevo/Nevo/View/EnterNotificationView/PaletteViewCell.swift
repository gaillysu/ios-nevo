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

    var pDelegate:PaletteDelegate?
    var currentColor:UIColor!
    private var buttonArray:[UIButton]!


    @IBAction func PaletteButtonManager(sender: AnyObject) {
        let senders:UIButton = sender as! UIButton
        for button:UIButton in buttonArray {
            button.selected = false
        }
        senders.selected = true

        if (senders.isEqual(blueButton)){
            currentColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 44, Green: 166, Blue: 224)
            pDelegate?.selectedPalette(currentColor)
        }else if (senders.isEqual(redButton)){
            currentColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 229, Green: 0, Blue: 18)
            pDelegate?.selectedPalette(currentColor)
        }else if (senders.isEqual(greenButton)){
            currentColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 141, Green: 194, Blue: 31)
            pDelegate?.selectedPalette(currentColor);
        }else if (senders.isEqual(yellowButton)){
            currentColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 250, Green: 237, Blue: 0)
            pDelegate?.selectedPalette(currentColor)
        }else if (senders.isEqual(orangeButton)){
            currentColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 150, Blue: 0)
            pDelegate?.selectedPalette(currentColor)
        }else if (senders.isEqual(cyanButton)){
            currentColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 13, Green: 172, Blue: 103)
            pDelegate?.selectedPalette(currentColor)
        }
        //currentColorView.backgroundColor = currentColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonArray = [blueButton, redButton, greenButton, greenButton, yellowButton, orangeButton, cyanButton]

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
