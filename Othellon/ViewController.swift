//
//  ViewController.swift
//  Othellon
//
//  Created by 金井俊樹 on 2021/02/01.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet var FBLabel: UILabel!
    @IBOutlet var first: UIButton!
    @IBOutlet var second: UIButton!

    @IBOutlet var banBgLabel: UILabel!
    @IBOutlet public var collectionView: UICollectionView!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var userScoreLabel: UILabel!
    @IBOutlet var cpuScoreLabel: UILabel!
    
    var userColor: UIColor = .white
    var cpuColor: UIColor = .white
    var uColor: String?
    var cColor: String?
    
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
        var weighting: Int = 0
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
        if putUser {
            ban[40].user = 1
            ban[41].user = 2
            ban[49].user = 2
            ban[50].user = 1
        } else {
            ban[40].user = 2
            ban[41].user = 1
            ban[49].user = 1
            ban[50].user = 2
        }
        
        ban[40].score  = 1
        ban[41].score  = 1
        ban[49].score  = 1
        ban[50].score  = 1
        self.view.backgroundColor = #colorLiteral(red: 0.2009865046, green: 0.2592999339, blue: 0.3360507488, alpha: 1)
//        self.canPut()
        self.setScore()
        
        var i = 10
        let weight = [30,-12,0,-1,-1,0,-12,30,0,
                  -12,-15,-3,-3,-3,-3,-15,-12,0,
                  0,-3,0,-1,-1,0,-3,0,0,
                  -1,-3,-1,-1,-1,-1,-3,-1,0,
                  -1,-3,-1,-1,-1,-1,-3,-1,0,
                  0,-3,0,-1,-1,0,-3,0,0,
                  -12,-15,-3,-3,-3,-3,-15,-12,0,
                  30,-12,0,-1,-1,0,-12,30,0]
        for w in weight {
            ban[i].weighting = w
            i += 1
        }
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
        
        self.FBLabel.layer.cornerRadius = 20
        self.FBLabel.clipsToBounds = true
        self.first.setTitle("First", for: .normal)
        self.first.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.first.layer.cornerRadius = 30
        self.second.setTitle("Second", for: .normal)
        self.second.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.second.layer.cornerRadius = 30
        
        self.first.layer.shadowColor = UIColor.black.cgColor
        self.first.layer.shadowOffset = CGSize(width: 0, height: 0.9)
        self.first.layer.shadowOpacity = 0.5
        self.first.layer.shadowRadius = 30
        
        self.second.layer.shadowColor = UIColor.black.cgColor
        self.second.layer.shadowOffset = CGSize(width: 0, height: 0.9)
        self.second.layer.shadowOpacity = 0.5
        self.second.layer.shadowRadius = 30
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.first.titleLabel?.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/25.0)
            self.second.titleLabel?.font = .boldSystemFont(ofSize: UIScreen.main.bounds.size.width/25.0)
        }
        
        
        self.collectionView.isUserInteractionEnabled = false
        resultLabel.text = ""
        self.userScoreLabel.isHidden = true
        self.cpuScoreLabel.isHidden = true
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
        
        
        //Layout
        
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
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.FBLabel.translatesAutoresizingMaskIntoConstraints = false
            self.FBLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/4).isActive = true
        }
        
        self.first.translatesAutoresizingMaskIntoConstraints = false
        self.first.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: view.bounds.size.width/6.0).isActive = true
        self.first.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        self.first.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        
        self.second.translatesAutoresizingMaskIntoConstraints = false
        self.second.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -view.bounds.size.width/6.0).isActive = true
        self.second.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        self.second.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/4).isActive = true
        
        
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
    
    @IBAction func userFirst() {
        self.userColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.cpuColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.uColor = "BLUE"
        self.cColor = "RED"
        self.orderHidden()
        collectionView.reloadData()
    }
    
    @IBAction func userSecond() {
        self.putUser = false
        self.userColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.cpuColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.uColor = "RED"
        self.cColor = "BLUE"
        self.orderHidden()
        self.cpu()
        collectionView.reloadData()
        self.putUser = true
    }
    
    func orderHidden(){
        self.banInit()
        self.canPut()
        self.collectionView.isUserInteractionEnabled = true
        self.userScoreLabel.isHidden = false
        self.cpuScoreLabel.isHidden = false
        self.userScoreLabel.textColor = self.userColor
        self.cpuScoreLabel.textColor = self.cpuColor
        self.FBLabel.isHidden = true
        self.first.isHidden = true
        self.second.isHidden = true
        self.view.backgroundColor = self.userColor
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
                    self.cpuScore  = 0
                    self.userScore = 0
                    self.putUser = false
                    self.canPut()
                    self.collectionView.reloadData()
                    self.setScore()
                    UIView.animate(
                            withDuration: 0.0,
                            animations:{
                                self.canPut()//配置可能Cell情報の更新
                                self.collectionView.reloadData()// リロード
                            }, completion:{ finished in
                                //-- CPC_Auto --------------------
                                if self.canPutCpuCell.count > 0 {
                                    self.view.backgroundColor = self.cpuColor
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
                                        self.cpu()
                                    }
//                                    UIView.animate(
//                                            withDuration: 0.0,
//                                            animations:{
//                                                self.canPut()//配置可能Cell情報の更新
//                                            }, completion:{ finished in
//                                                while (self.canPutUserCell.count == 0){
//                                                        self.cpu()
//                                                    if self.canPutCpuCell.count == 0 { break }
//                                                }
//                                                if self.canPutUserCell.count != 0{
//                                                    self.putUser = true
//                                                }
//                                            
//                                    });
                                }else{
                                    self.putUser = true
                                    self.collectionView.reloadData()
                                }
                                //-- -------- --------------------
//                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
//                                    self.putUser = true
//                                    self.canPut()
//                                    self.collectionView.reloadData()
//                                }
                        });
                }
                
//            case false://呼ばれない
//                if flipRed(index: c) > 0 {
//                    self.view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
//                    canPutBlueCell.removeAll()
//                    canPutRedCell.removeAll()
//                    self.user = true
//                    collectionView.reloadData()
//                }
            default: break
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
        
        
    }
    
    // -- CPU -----------------------------------------------
    func cpu(){
        let semaphore = DispatchSemaphore(value: 0)
        var f = false {
            didSet{
                semaphore.signal()
            }
        }
//        let r = self.canPutCpuCell.randomElement()!
        self.setScore()
        //cpuが設置可能な場合
//        _ = self.flipCPU(index: r)//置けるセルにランダムに配置している
//        cpuAi({besiIndex in _ = self.flipCPU(index: besiIndex)})
        _ = self.flipCPU(index: cpuAi())
        self.view.backgroundColor = self.userColor
        self.collectionView.reloadData()
        f = self.canPut(flag: f)
        semaphore.wait()
        if canPutUserCell.count == 0 {
            if canPutCpuCell.count != 0{
                sleep(1)
                self.cpu()
            }
        }else{
            self.putUser = true
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
    // -- CPU-fin -----------------------------------------------
    
    func canPut(flag: Bool = true) -> Bool {
            self.canPutUserCell.removeAll()
            self.canPutCpuCell.removeAll()
            for y in 1..<9 { for x in 1..<9{
                let c = y*9+x
                if self.ban[c].user == self.BLANK {
                    if self.flipUser(index: c) > 0 {
                        self.undoUser()
                        self.canPutUserCell.append(c)
                    }
                    if self.flipCPU(index: c) > 0 {
                        self.undoCpu()
                        self.canPutCpuCell.append(c)
                    }
                }
            }}
        return !flag
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
        
        nextVc.single = true

        if self.userScore > self.cpuScore {
            nextVc.rLabel = "YOU WIN!"
        }else if self.userScore < self.cpuScore {
            nextVc.rLabel = "YOU LOSE."
        }else if self.userScore == self.cpuScore {
            nextVc.rLabel = "DRAW!"
        }
        
        nextVc.modalPresentationStyle = .automatic //.fullScreen
        
//        if UIDevice.current.userInterfaceIdiom == .pad{
//            nextVc.modalPresentationStyle = .fullScreen
//        }
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
            self.resultLabel.isHidden = true
            self.userScoreLabel.isHidden = true
            self.cpuScoreLabel.isHidden = true
            self.present(nextVc, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
    
    //遷移先のvcからdismissで戻ってきたときに呼ばれる
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss(animated: true, completion: nil)
    }
    
}

