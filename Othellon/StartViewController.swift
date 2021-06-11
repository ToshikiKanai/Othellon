//
//  StartViewController.swift
//  Othellon
//
//  Created by 金井俊樹 on 2021/02/04.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet var playSingleButton: UIButton!
    @IBOutlet var playDoubleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(UIScreen.main.bounds.size.height)
        
        self.overrideUserInterfaceStyle = .light //ダークモード無効
        
        playSingleButton.layer.shadowColor = UIColor.black.cgColor
        playSingleButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        playSingleButton.layer.shadowOpacity = 0.3
        playSingleButton.layer.shadowRadius = 15
        playSingleButton.layer.cornerRadius = 15
        
        playDoubleButton.layer.shadowColor = UIColor.black.cgColor
        playDoubleButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        playDoubleButton.layer.shadowOpacity = 0.3
        playDoubleButton.layer.shadowRadius = 15
        playDoubleButton.layer.cornerRadius = 15
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            playSingleButton.translatesAutoresizingMaskIntoConstraints = false
            playSingleButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
            
            playDoubleButton.translatesAutoresizingMaskIntoConstraints = false
            playDoubleButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true

        }
    }
    

}
