//
//  TutorialPageFive.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialFiveViewController: UIViewController {

    var progresValue:Double = 0.0
    var timer:Timer?

    @IBOutlet weak var watchImage: UIImageView!
    @IBOutlet weak var progressBar: CircleProgressView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    init() {
        super.init(nibName: "TutorialFiveViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        AppDelegate.getAppDelegate().connect()
        styleEvolve()
    }

    override func viewWillAppear(_ animated: Bool) {
        if(timer == nil) {
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(TutorialFiveViewController.timerAction(_:)), userInfo: nil, repeats: true)
        }else {
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(TutorialFiveViewController.timerAction(_:)), userInfo: nil, repeats: true)
            progressBar.setProgress(0, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.setLunaRtext()
        }
    }

    func timerAction(_ action:Timer) {
        progresValue+=0.1
        progressBar.setProgress(progresValue, animated: true)
        if(progresValue > 1){
            action.isValid ? action.invalidate():()
            if(AppDelegate.getAppDelegate().isConnected()){
                delay(1.0) {
                    AppDelegate.getAppDelegate().forgetSavedAddress()
                    let tutorialSix = TutorialSixViewController()
                    self.navigationController?.pushViewController(tutorialSix, animated: true)
                }
            }else{
                var res:Bool = true
                for nvc:UIViewController in self.navigationController!.viewControllers {
                    if(nvc.isKind(of: TutorialSevenViewController.classForCoder())) {
                        res = false
                        _ = self.navigationController?.popToViewController(nvc, animated: true)
                        return;
                    }
                }
                if(res) {
                    progresValue = 0.0
                    progressBar.setProgress(progresValue, animated: true)
                    let tutorial:TutorialSevenViewController = TutorialSevenViewController()
                    self.navigationController?.pushViewController(tutorial, animated: true)
                }
            }

        }else{
            if(AppDelegate.getAppDelegate().isConnected()){
                action.isValid ? action.invalidate():()
                delay(1.0) {
                    let tutorialSix = TutorialSixViewController()
                    self.navigationController?.pushViewController(tutorialSix, animated: true)
                }
            }
        }
    }

    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}

extension TutorialFiveViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            progressBar.backgroundColor = UIColor.clear
            progressBar.trackFillColor = UIColor.getBaseColor()
            progressBar.centerFillColor = UIColor.getGreyColor()
            watchImage.image = AppTheme.GET_RESOURCES_IMAGE("lunar_search")
        }
    }
    
    func setLunaRtext() {
        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "nevo watch", with: "LunaR")
        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "nevo", with: "LunaR")
        
        detailLabel.text = detailLabel.text?.replacingOccurrences(of: "nevo watch", with: "LunaR")
        detailLabel.text = detailLabel.text?.replacingOccurrences(of: "nevo", with: "LunaR")
    }
}
