 //
 //  ViewController.swift
 //  Othellon
 //
 //  Created by 金井俊樹 on 2021/02/01.
 //
 
 import UIKit
 
 extension ViewController{
    
    func cpuAi() -> Int {
        let DEPTH = 2
        let TIMER = Date()
        let board = Board()
        let semaphore = DispatchSemaphore(value: 0)
        var bestPutIndex = 0 {
            didSet{
                semaphore.signal()
            }
        }
        
        (board.playerBoard,board.opponentBoard) = arrayToBit()
        
        var (judge, bestPut) = negaMax(board:board ,depth: DEPTH*2+1)
        if judge == -1 {
            fin()
        }
        let semaphore2 = DispatchSemaphore(value: 0)
        var f = false{
            didSet {semaphore2.signal()}
        }
        var y = 8
        if bestPut <= 0xff {f = true}
        while bestPut > 0xff {
            y -= 1
            bestPut /= 0xff
            if bestPut <= 0xff {f = true}
        }
        semaphore2.wait()
        var x = 8
        while bestPut > 1 {
            x -= 1
            bestPut /= 2
        }
        
        bestPutIndex = y*9+x
        
        semaphore.wait()
        print("❤️")
        print("bestPut(x,y) = (\(x),\(y))")
        print("パターン数:",board.count)
        let elapsed = Date().timeIntervalSince(TIMER)
        print("計算時間:",elapsed)
        board.count = 0
        return bestPutIndex
        
//        let (_, bestIndex) = NegaMax(depth: 5)//引数は奇数を指定
//        print("bestIndex =",bestIndex)
//        return bestIndex
    }
    
    //構造体の配列をビットボードに変換
    func arrayToBit() -> (UInt64, UInt64) {
        var userBoarqd: UInt64 = 0x0000000000000000
        var cpuBoard: UInt64   = 0x0000000000000000
        for y in 1..<9 {
            for x in 1..<9{
                var mask: UInt64 = 0x8000000000000000
                mask = mask >> ((y-1) * 8 + (x-1))
                let c = y*9+x
                if ban[c].user == self.USER {
                    userBoarqd = userBoarqd | mask
                }else if ban[c].user == self.CPU {
                    cpuBoard = cpuBoard | mask
                }
            }
        }
        return (cpuBoard, userBoarqd)
    }
    
    //MARK: NEGAMAX
    func negaMax(board:Board, depth: Int) -> (Int, UInt64) {
        var depth_ = depth
        var maxValue: Int?
        var bestPut: UInt64 = 0x0000000000000000
        let semaphore = DispatchSemaphore(value: 0)
        var fin = false{
            didSet{semaphore.signal()}
        }
        
        
        if depth_ == 0 {
//            board.swapBoard()
            return (-evaluation(board: board),0)
        }
        
        //直列キュー
//        let dispatchGroup = DispatchGroup()
//        let dispatchQueue = DispatchQueue(label: "queue")
        var put: UInt64 = 0x8000000000000000
        for _ in 1..<9 {
            for _ in 1..<9 {
//                dispatchGroup.enter()
//                dispatchQueue.async {
                //A1のみフラグが立っているボード
//                var put: UInt64 = 0x8000000000000000
//                put = put >> ((y-1)*8 + (x-1))
                //A1から順に、配置可能な位置に配置
                if board.canPut(put: put) {
                    board.reverse(put: put)
                    board.swapBoard()
                    if board.isPass() {
                        board.swapBoard()
                        depth_ = depth_ - 1
//                        if depth_ % 2 == 1{
//                            //cpu ad
//                            return (-100, put)
//                        }else{
//                            return (100, put)
//                        }
                    }else if board.isGameFinished() {
                        board.swapBoard()
                        board.undo()
                        board.count += 1
                        if depth_ % 2 == 1{
                            //cpu win
                            return (100, put)
                        }else{
                            return (-100, put)
                        }
                    }
                    let sem = DispatchSemaphore(value: 0)
                    var val:Int = 0 {
                        didSet{sem.signal()}
                    }
//                    print("count=",board.count,"depth=",depth)
                     (val, _) = self.negaMax(board:board ,depth: depth_-1)
                    sem.wait()
//                    print("count=",board.count,"depth=",depth,"val=",val)
                    if maxValue == nil || maxValue! < -val {
//                        print("maxValue=",-val)
                        maxValue = -val
                        bestPut = put
                    }
                    board.swapBoard()
                    board.undo()
                }
                put = put >> 1
//                if (x+y==16){fin = true}
//                    dispatchGroup.leave()
//                }
            }
        }
        
//        dispatchGroup.notify(queue: .main){
//            fin = true
//        }
//        semaphore.wait()
        if maxValue == nil {
            return (-1, bestPut)
        }
        return (maxValue!, bestPut)
    }
    
    //静的評価関数
    func evaluation(board:Board) -> Int {
        board.count += 1
//        print(board.count)
        let (firstScore, secondScore, _) = board.getResult()
        let blankBoard: UInt64 = ~(board.playerBoard | board.opponentBoard)
        let blankNum = board.bitCount(blankBoard)
        return firstScore - secondScore + blankNum
    }
    
    /*
    func NegaMax(index: Int = 0, depth: Int) -> (Float, Int) {
        var best: Float = -10000
        var bestIndex: Int = -1
        
        let semaphore = DispatchSemaphore(value: 0)
        
        if depth == 0 {
            let e = evaluation(index: index)
            return (-e, bestIndex)
        }
        
        DispatchQueue.global().sync {
            if depth % 2 == 0 {
                //user
                for p in canPutUserCell {
                    _ = flipUser(index: p)
                    canPut()
                    if canPutCpuCell.count == 0 {
                        best = -1000
                        undoUser()
                    }else{
                        let (val,_) = NegaMax(index: p, depth: depth - 1)
                        if (best < -val) { best = -val }
                        undoUser()
                    }
                }
            } else {
                //cpu
                for p in canPutCpuCell {
                    _ = flipCPU(index: p)
                    let semaphore2 = DispatchSemaphore(value: 0)
                    var f = false{
                        didSet {
                            semaphore2.signal()
                        }
                    }
                    f = self.canPut(flag: f)
                    //キューを利用しないと、canPut()の実行が終了する前にcanPutUserCell.countが実行されてしまう?
                    semaphore2.wait()
                    if self.canPutUserCell.count == 0 {
                        (best, bestIndex) = (1000, p)
                        self.undoCpu()
                        break
                    }else{
                        let (val,_) = self.NegaMax(index: p, depth: depth - 1)
                        if (best < -val) { best = -val; bestIndex = p }
                        self.undoCpu()
                    }
                }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return (best, bestIndex)
    }
    
    
    //静的評価関数
    func evaluation(index: Int) -> Float{
        let w = ban[index].weighting
        
        var cpu: Int = 0
        var user: Int = 0
        for y in 1..<9 { for x in 1..<9{
            let c = y*9+x
            if ban[c].user == self.USER {
                user += ban[c].score
            }else if ban[c].user == self.CPU {
                cpu += ban[c].score
            }
        }}
        
        let s = cpu - user
        let e: Float = Float(s + w)
        
        return e
    }
  
  */
    
 }
 
 
 
 
 
