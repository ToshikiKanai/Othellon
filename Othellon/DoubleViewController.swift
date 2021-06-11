//
//  ViewController.swift
//  Othellon
//
//  Created by 金井俊樹 on 2021/02/01.
//

import UIKit

class DoubleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet var banBgLabel: UILabel!
    @IBOutlet public var collectionView: UICollectionView!
    @IBOutlet var userScoreLabel: UILabel!
    @IBOutlet var cpuScoreLabel: UILabel!
    
    var userColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    var cpuColor: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    var uColor: String = "BLUE"
    var cColor: String = "RED"
    
    //-- オセロ盤 ------------------------------------
    var userScore: Int = 0
    var cpuScore: Int = 0
    let BLANK = 0
    var USER  = 1
    var CPU   = 2
    let WALL  = 3
    struct info {
        var user: Int = 0
        var score: Int  = 0
        
    }
    var ban: [info] = Array(repeating: info(user: 3, score: 0), count: 91)
    var putUser = true
    var stackBlue: [Int] = Array(repeating: 0, count: 1000)
    var stackRed: [Int] = Array(repeating: 0, count: 1000)
    var spBlue: Int = 0
    var spRed: Int = 0
    var canPutUserCell  = [Int]()
    var canPutCpuCell = [Int]()
    
    //盤の初期化
    func banInit(){
        for y in 1..<9 { for x in 1..<9 { ban[y*9+x].user = self.BLANK }}
        
        ban[40].user = 1
        ban[41].user = 2
        ban[49].user = 2
        ban[50].user = 1
        
        ban[40].score  = 1
        ban[41].score  = 1
        ban[49].score  = 1
        ban[50].score  = 1
        self.view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.canPut()
        self.setScore()
    }
    
    //user -> cpu
    func flipUser(index: Int) -> Int {
        var n = 0
        
        n += flipLineUser(index: index, dir: -10)
        n += flipLineUser(index: index, dir:  -9)
        n += flipLineUser(index: index, dir:  -8)
        n += flipLineUser(index: index, dir:  -1)
        n += flipLineUser(index: index, dir:   1)
        n += flipLineUser(index: index, dir:   8)
        n += flipLineUser(index: index, dir:   9)
        n += flipLineUser(index: index, dir:  10)
        
        if n > 0 {
            ban[index].user = self.USER
            ban[index].score = 1
            stackBlue[spBlue] = index
            spBlue += 1
            stackBlue[spBlue] = n
            spBlue += 1
        }
        
        return n
    }
    
    func flipLineUser(index: Int, dir: Int) -> Int {
        var n = 0
        var i = index + dir
        
        while (ban[i].user == self.CPU) { i += dir }
        if ban[i].user != self.USER { return 0 }
        
        i -= dir
        while (i != index) {
            ban[i].user = self.USER
            ban[i].score += 1
            stackBlue[spBlue] = i
            spBlue += 1
            n += 1
            i -= dir
        }
        
        return n
    }
    
    func undoUser(){
        spBlue -= 1
        var n = stackBlue[spBlue]
        spBlue -= 1
        ban[stackBlue[spBlue]].user = self.BLANK
        ban[stackBlue[spBlue]].score = 0
        while n > 0 {
            spBlue -= 1
            ban[stackBlue[spBlue]].user = self.CPU
            ban[stackBlue[spBlue]].score -= 1
            n -= 1
        }
    }
    
    
    //cpu -> user
    func flipCPU(index: Int) -> Int {
        var n = 0
        
        n += flipLineCPU(index: index, dir: -10)
        n += flipLineCPU(index: index, dir:  -9)
        n += flipLineCPU(index: index, dir:  -8)
        n += flipLineCPU(index: index, dir:  -1)
        n += flipLineCPU(index: index, dir:   1)
        n += flipLineCPU(index: index, dir:   8)
        n += flipLineCPU(index: index, dir:   9)
        n += flipLineCPU(index: index, dir:  10)
        
        if n > 0 {
            ban[index].user = self.CPU
            ban[index].score = 1
            stackRed[spRed] = index
            spRed += 1
            stackRed[spRed] = n
            spRed += 1
        }
        
        return n
    }
    
    func flipLineCPU(index: Int, dir: Int) -> Int {
        var n = 0
        var i = index + dir
        
        while (ban[i].user == self.USER) { i += dir }
        if ban[i].user != self.CPU { return 0 }
        
        i -= dir
        while (i != index) {
            ban[i].user = self.CPU
            ban[i].score += 1
            stackRed[spRed] = i
            spRed += 1
            n += 1
            i -= dir
        }
        
        return n
    }
    
    func undoCpu(){
        spRed -= 1
        var n = stackRed[spRed]
        spRed -= 1
        ban[stackRed[spRed]].user = self.BLANK
        ban[stackRed[spRed]].score = 0
        while n > 0 {
            spRed -= 1
            ban[stackRed[spRed]].user = self.USER
            ban[stackRed[spRed]].score -= 1
            n -= 1
        }
    }
    
    //-- --- ------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light //ダークモード無効
        
        self.putUser = true
        self.userScoreLabel.textColor = self.userColor
        self.cpuScoreLabel.textColor = self.cpuColor
        self.userScoreLabel.layer.cornerRadius = 30
        self.userScoreLabel.clipsToBounds = true
        self.cpuScoreLabel.layer.cornerRadius = 30
        self.cpuScoreLabel.clipsToBounds = true
        self.userScoreLabel.backgroundColor = #colorLiteral(red: 1, green: 0.9894430041, blue: 0.8617147803, alpha: 1)
        self.cpuScoreLabel.backgroundColor = #colorLiteral(red: 1, green: 0.9894430041, blue: 0.8617147803, alpha: 1)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
        self.collectionView.bounds.size.width = UIScreen.main.bounds.size.width - 10
        self.collectionView.bounds.size.height = UIScreen.main.bounds.size.width - 10
        self.collectionView.backgroundColor = #colorLiteral(red: 0.5524346232, green: 0.5491539836, blue: 0.5549585223, alpha: 1)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.98).isActive = true
        self.collectionView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.98).isActive = true
        
        self.banBgLabel.translatesAutoresizingMaskIntoConstraints = false
        self.banBgLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.banBgLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.banBgLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        self.banBgLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.03).isActive = true
        
        
        self.userScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.userScoreLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: view.bounds.size.width/8.0).isActive = true
//        self.userScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
//        self.userScoreLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        if UIDevice.current.userInterfaceIdiom == .pad{
            //iPadの場合
            self.userScoreLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
            self.userScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/8).isActive = true
            self.userScoreLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/8).isActive = true
        }else{
            self.userScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
            self.userScoreLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        }
        
        self.cpuScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cpuScoreLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -view.bounds.size.width/8.0).isActive = true
//        self.cpuScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
//        self.cpuScoreLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        if UIDevice.current.userInterfaceIdiom == .pad{
            //iPadの場合
            self.cpuScoreLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
            self.cpuScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/8).isActive = true
            self.cpuScoreLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/8).isActive = true
        }else{
            self.cpuScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
            self.cpuScoreLabel.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        }
        
        
        self.banInit()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //cellの数を返す関数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64
    }
    
    //cellに情報を入れていく関数
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.label.text = String(self.BLANK)
        cell.label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.label.font = .boldSystemFont(ofSize: self.collectionView.bounds.size.width/30.0)
        cell.label.backgroundColor = #colorLiteral(red: 0.7154678702, green: 0.9686232209, blue: 0.9345201254, alpha: 1)
        
        let x = indexPath[1] % 8 + 1
        let y = indexPath[1] / 8 + 1
        let c = y*9 + x
        
        
        cell.label.text = String(ban[c].score)
        
        switch ban[c].user {
        case self.USER:
            cell.label.backgroundColor = self.userColor
        case self.CPU:
            cell.label.backgroundColor = self.cpuColor
        case self.BLANK:
            cell.label.backgroundColor = #colorLiteral(red: 0.7303581238, green: 0.72601825, blue: 0.7336953282, alpha: 1)
            cell.label.text = ""
            if (self.putUser && flipUser(index: c) > 0) {
                undoUser()
                cell.label.backgroundColor = #colorLiteral(red: 0.9852493405, green: 0.9793919921, blue: 0.989751637, alpha: 1)
            }else if (!self.putUser && flipCPU(index: c) > 0) {
                undoCpu()
                cell.label.backgroundColor = #colorLiteral(red: 0.9852493405, green: 0.9793919921, blue: 0.989751637, alpha: 1)
            }
        default: break
        }
        
        
        return cell
    }
    
    //cell選択(クリック)時に呼ばれる関数(引数にcellのIndexが渡される)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let x = indexPath[1] % 8 + 1
        let y = indexPath[1] / 8 + 1
        let c = y*9 + x
        
        if ban[c].user == self.BLANK {
            switch putUser{
            case true:
                if canPutUserCell.contains(c) {
                    _ = flipUser(index: c)
                    self.putUser = false
                    self.canPut()
                    self.collectionView.reloadData()
                    self.setScore()
                    if self.canPutCpuCell.count > 0 {
                        self.view.backgroundColor = self.cpuColor
                    }else{
                        self.putUser = true
                    }
//                    UIView.animate(
//                            withDuration: 0.0,
//                            animations:{
//                                self.canPut()//配置可能Cell情報の更新
//                                self.collectionView.reloadData()// リロード
//                            }, completion:{ finished in
                                //-- CPC_Auto --------------------
//                                if self.canPutCpuCell.count > 0 {
//                                    self.view.backgroundColor = self.cpuColor
//                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
//                                        self.cpu()
//                                    }
//                                    UIView.animate(
//                                            withDuration: 0.0,
//                                            animations:{
//                                                self.canPut()//配置可能Cell情報の更新
//                                            }, completion:{ finished in
//                                                print(self.canPutUserCell.count)
//                                                print(self.canPutUserCell.count == 0)
//                                        while (self.canPutUserCell.count == 0){
////                                            DispatchQueue.main.asyncAfter(deadline: .now()+0.4){
//                                                self.cpu()
//                                            if self.canPutCpuCell.count == 0 { break }
////                                            }
//                                        }
//                                    });
//                                }
                                //-- -------- --------------------
//                                self.putUser = true
//                                self.canPut()
//                        });
                }
                
            case false:
                if canPutCpuCell.contains(c) {
                    _ = flipCPU(index: c)
                    self.view.backgroundColor = self.cpuColor
                    self.canPut()
                    self.putUser = true
                    collectionView.reloadData()
                    self.setScore()
                    if self.canPutUserCell.count > 0 {
                        self.view.backgroundColor = self.userColor
                    }else{
                        self.putUser = false
                    }
                }
            }
            //終了
            UIView.animate(
                    withDuration: 0.0,
                    animations:{
                        self.canPut()//配置可能Cell情報の更新
                        self.setScore()
                        self.collectionView.reloadData()
                    }, completion:{ finished in
                        self.fin()
            });
            

        }
        
        
    }
    
    func cpu(){
        if let r = self.canPutCpuCell.randomElement() {
            self.setScore()
            //cpuが設置可能な場合
            _ = self.flipCPU(index: r)
            self.view.backgroundColor = self.userColor
            self.collectionView.reloadData()
            self.canPut()
            if canPutUserCell.count == 0 {
                self.cpu()
            }
        }
        //終了
        UIView.animate(
                withDuration: 0.0,
                animations:{
                    // リロード
                    self.canPut()//配置可能Cell情報の更新
                    self.setScore()
                    self.collectionView.reloadData()
                }, completion:{ finished in
                    self.fin()
        });
    }
    
//    func userAuto(){
//        if let r = self.canPutUserCell.randomElement() {
//            self.setScore()
//            //cpuが設置可能な場合
//            _ = self.flipUser(index: r)
//            self.view.backgroundColor = self.cpuColor
//            self.collectionView.reloadData()
//            self.canPut()
//            if canPutCpuCell.count == 0 {
//                self.userAuto()
//            }
//        }
//        //終了
//        UIView.animate(
//                withDuration: 0.0,
//                animations:{
//                    // リロード
//                    self.canPut()//配置可能Cell情報の更新
//                    self.setScore()
//                    self.collectionView.reloadData()
//                }, completion:{ finished in
//                    self.fin()
//        });
//    }
    
    func canPut(){
        self.canPutUserCell.removeAll()
        self.canPutCpuCell.removeAll()
        for y in 1..<9 { for x in 1..<9{
            let c = y*9+x
            if ban[c].user == self.BLANK {
                if flipUser(index: c) > 0 {
                    undoUser()
                    canPutUserCell.append(c)
                }
                if flipCPU(index: c) > 0 {
                    undoCpu()
                    canPutCpuCell.append(c)
                }
            }
        }}
    }
    
    func setScore(){
        self.cpuScore  = 0
        self.userScore = 0
        for y in 1..<9 { for x in 1..<9{
            let c = y*9+x
            if ban[c].user == self.USER {
                self.userScore += ban[c].score
            }else if ban[c].user == self.CPU {
                self.cpuScore += ban[c].score
            }
        }}
        self.userScoreLabel.text = String(self.userScore)
        self.cpuScoreLabel.text = String(self.cpuScore)
    }
    
    func fin(){
        //終了判定
        if self.canPutUserCell.count + self.canPutCpuCell.count == 0{
            self.setScore()
            self.showResult()
        }
    }
    
    func showResult() {
        let nextVc = self.storyboard?.instantiateViewController(withIdentifier: "Result") as! ResultViewController
        nextVc.u = userScore
        nextVc.c = cpuScore
        nextVc.userColor = self.userColor
        nextVc.cpuColor = self.cpuColor
        nextVc.uColor = self.uColor
        nextVc.cColor = self.cColor
        
        nextVc.single = false

        if self.userScore > self.cpuScore {
            nextVc.rLabel = "BLUE WIN!"
        }else if self.userScore < self.cpuScore {
            nextVc.rLabel = "RED WIN!"
        }else if self.userScore == self.cpuScore {
            nextVc.rLabel = "DRAW!"
        }
        
        nextVc.modalPresentationStyle = .automatic //.fullScreen
//        nextVc.isModalInPresentation = true //下スワイプ禁止。ダサいのでスワイプした時にスタート画面に戻る処理を別で書くと良い
        
        nextVc.presentationController?.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8){
            //コンテキスト開始
            UIGraphicsBeginImageContextWithOptions(self.collectionView.bounds.size, false, 0.0)
            //collectionViewを書き出す
            self.collectionView.drawHierarchy(in: self.collectionView.bounds, afterScreenUpdates: false)
            // imageにコンテキストの内容を書き出す
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            //コンテキストを閉じる
            UIGraphicsEndImageContext()
            nextVc.rImage = image
            self.userScoreLabel.isHidden = true
            self.cpuScoreLabel.isHidden = true
            self.present(nextVc, animated: true, completion: nil)
        }
    }
    
}

extension DoubleViewController: UIAdaptivePresentationControllerDelegate {
    
    //遷移先のvcからdismissで戻ってきたときに呼ばれる
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss(animated: true, completion: nil)
    }
    
}

