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
        ConnectionManager.manager.connect()
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

    }

    func timerAction(_ action:Timer) {
        progresValue+=0.1
        progressBar.setProgress(progresValue, animated: true)
        if(progresValue > 1){
            action.isValid ? action.invalidate():()
            if ConnectionManager.manager.isConnected {
                delay(1.0) {
                    ConnectionManager.manager.forgetSavedAddress()
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
            if ConnectionManager.manager.isConnected {
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
