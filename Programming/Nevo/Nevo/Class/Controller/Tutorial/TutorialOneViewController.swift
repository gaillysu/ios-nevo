//
//  TutorialPageOne.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialOneViewController: UIViewController{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var centerImageView: UIImageView!
    
    init() {
        super.init(nibName: "TutorialOneViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   

    override func viewDidLoad() {
        
        styleEvolve()
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            centerImageView.image = UIImage(named: "tutorial_lunar 1")
        }
        
        //controllManager(_:)
        let logPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TutorialOneViewController.logPressAction(_:)))
        self.view.addGestureRecognizer(logPress)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.setLunaRtext()
        }
    }
    
    func logPressAction(_ sender:UITapGestureRecognizer) {
        //let otaCont:OldOtaViewController = OldOtaViewController()
        //let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
        // TODO
        //self.present(navigation, animated: true, completion: nil)
    }
    
    @IBAction func activateYourNevoAction(_ sender: AnyObject) {
        let btEnabled = AppDelegate.getAppDelegate().getMconnectionController()!.isBluetoothEnabled()
        if(btEnabled){
            let tutorialThree = TutorialThreeViewController()
            self.navigationController?.pushViewController(tutorialThree, animated: true)
        }else{
            let tutorialTwo = TutorialTwoViewController()
            self.navigationController?.pushViewController(tutorialTwo, animated: true)
        }
    }
}


extension TutorialOneViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            nextStepButton.backgroundColor = UIColor.getBaseColor()
            nextStepButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func setLunaRtext() {
        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "nevo watch", with: "LunaR")
        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "nevo", with: "LunaR")
        
        detailLabel.text = detailLabel.text?.replacingOccurrences(of: "nevo watch", with: "LunaR")
        detailLabel.text = detailLabel.text?.replacingOccurrences(of: "nevo", with: "LunaR")
        
        var buttonText:String = nextStepButton.titleLabel!.text!.replacingOccurrences(of: "nevo", with: "LunaR")
        buttonText = buttonText.replacingOccurrences(of: "nevo watch", with: "LunaR")
        nextStepButton.setTitle(buttonText, for: .normal)
        nextStepButton.setTitle(buttonText, for: .selected)
        nextStepButton.setTitle(buttonText, for: .highlighted)
    }
}
