//
//  MenuViewController.swift
//  Othellon
//
//  Created by 金井俊樹 on 2021/02/06.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var homeButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light //ダークモード無効

        homeButton.layer.shadowColor = UIColor.black.cgColor
        homeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        homeButton.layer.shadowOpacity = 0.5
        homeButton.layer.shadowRadius = 15
        homeButton.layer.cornerRadius = 15
        
        reloadButton.layer.shadowColor = UIColor.black.cgColor
        reloadButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        reloadButton.layer.shadowOpacity = 0.5
        reloadButton.layer.shadowRadius = 15
        reloadButton.layer.cornerRadius = 15

    }
    
    @IBAction func reload(){
        self.presentingViewController?.loadView()
        self.presentingViewController?.viewDidLoad()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func home(){
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
