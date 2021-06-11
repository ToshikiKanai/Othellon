//
//  ResultViewController.swift
//  Othellon
//
//  Created by 金井俊樹 on 2021/02/04.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet var bar: UILabel!
    @IBOutlet var resultUserScore: UILabel!
    @IBOutlet var resultCpuScore: UILabel!
    @IBOutlet var bgLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var resultImage: UIImageView!
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var homeButtom: UIButton!
    
    var single: Bool?
    
    var u: Int = 0
    var c: Int = 0
    var rImage: UIImage?
    var rLabel: String?
    var userColor: UIColor?
    var cpuColor: UIColor?
    
    var uColor: String?
    var cColor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light //ダークモード無効
        
        bar.text = "ー"
        bar.textColor = .black
        view.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 0)
        resultUserScore.text = String(u)
        resultCpuScore.text = String(c)
        resultUserScore.textColor = self.userColor
        resultCpuScore.textColor = self.cpuColor
        resultImage.image = rImage
        bgLabel.layer.cornerRadius = 20
        bgLabel.clipsToBounds = true
        resultLabel.text = rLabel!
        
        shareButton.layer.shadowColor = UIColor.black.cgColor
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 0.4)
        shareButton.layer.shadowOpacity = 0.4
        shareButton.layer.shadowRadius = 15
        shareButton.layer.cornerRadius = 15
        
        homeButtom.layer.shadowColor = UIColor.black.cgColor
        homeButtom.layer.shadowOffset = CGSize(width: 0, height: 0.4)
        homeButtom.layer.shadowOpacity = 0.4
        homeButtom.layer.shadowRadius = 15
        homeButtom.layer.cornerRadius = 15
        
        //Layout
//        let re = (self.view.bounds.size.height - self.view.bounds.size.width)/4
        
//        self.resultUserScore.translatesAutoresizingMaskIntoConstraints = false
//        self.resultUserScore.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2).isActive = true
////        self.resultUserScore.topAnchor.constraint(lessThanOrEqualTo: self.view.topAnchor).isActive = true
//        self.resultUserScore.bounds.size.height = re
        self.resultUserScore.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/15.0)
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.resultUserScore.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/30.0)
        }
//
//        self.resultCpuScore.translatesAutoresizingMaskIntoConstraints = false
//        self.resultCpuScore.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2).isActive = true
////        self.resultCpuScore.topAnchor.constraint(lessThanOrEqualTo: self.view.topAnchor).isActive = true
////        self.resultCpuScore.bounds.size.height = re
        self.resultCpuScore.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/15.0)
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.resultCpuScore.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/30.0)
        }
//
//        self.bar.translatesAutoresizingMaskIntoConstraints = false
//        self.bar.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2).isActive = true
////        self.bar.topAnchor.constraint(lessThanOrEqualTo: self.view.topAnchor).isActive = true
////        self.bar.bounds.size.height = re
        self.bar.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/15.0)
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.bar.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/30.0)
        }
//
        self.resultImage.translatesAutoresizingMaskIntoConstraints = false
        self.resultImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.resultImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.resultImage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.98).isActive = true
        self.resultImage.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.98).isActive = true
//
        self.resultLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.resultLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1).isActive = true
////        self.resultLabel.bounds.size.height = re
//        self.resultLabel.bottomAnchor.constraint(equalTo: self.resultImage.topAnchor).isActive = true
        self.resultLabel.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/15.0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.resultLabel.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/30.0)
        }
        
        
    }
    
    @IBAction func share() {
        var text: String = ""
        if single! {
            if u > c {
                text = "【\(u)(\(uColor!)) ー \(c)(\(cColor!))】 I WIN!"
            } else if u < c {
                text = "【\(u)(\(uColor!)) ー \(c)(\(cColor!))】 I LOSE."
            } else {
                text = "【\(u)(\(uColor!)) ー \(c)(\(cColor!))】 DRAW!"
            }
        }else{
            if u > c {
                text = "【\(u)(\(uColor!)) ー \(c)(\(cColor!))】 BLUE WIN!"
            } else if u < c {
                text = "【\(u)(\(uColor!)) ー \(c)(\(cColor!))】 RED WIN!"
            } else {
                text = "【\(u)(\(uColor!)) ー \(c)(\(cColor!))】 DRAW!"
            }
        }
        
        let resizedImage = rImage!.resize(targetSize: CGSize(width: rImage!.size.width/2, height: rImage!.size.height/2))
        
        let activityItems = [text, resizedImage] as [Any]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            //iPadでActivityViewControllerを出すため
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0,
                                                                                  y: self.view.bounds.size.height / 2.0,
                                                                                  width: 1.0,
                                                                                  height: 1.0)
        }
        
        let excludedActivityTypes: Array<UIActivity.ActivityType> = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.openInIBooks,
            //UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
           //UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.markupAsPDF
                ]
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            
            guard completed else { return }
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func home() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
}

extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}
