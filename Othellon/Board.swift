
import Foundation

class Board {
    
    //MARK: Constant
    let BLUE_TURN = 100
    let RED_TURN = -100
    
    //MARK: Properties
    var nowTurn  : Int          // 現在の手番
    var nowIndex : Int          // 現在何手目か
    var playerBoard   : UInt64  // player側ビットボード
    var opponentBoard : UInt64  // opponent側ビットボード
    var putRevArray = [UInt64]() //着手位置・反転位置の履歴
    
    //MARK: Initialization
    init() {
        self.nowTurn       = BLUE_TURN
        self.nowIndex      = 1
        
        // 一般的な初期配置を指定
        self.playerBoard   = 0x0000000810000000
        self.opponentBoard = 0x0000001008000000
    }
    
    //座標をbitに変換
    // 1<=x,y<=8
    func coordinateToBit(x: Int, y: Int) -> UInt64 {
        if (x < 1 || x > 8 || y < 1 || y > 8) {
            return 0
        }
        var mask: UInt64 = 0x8000000000000000
        mask = mask >> (x-1)
        mask = mask >> ((y-1)*8)
        return mask
    }
    
    //着手可否判定
    //引数は置いた位置にのみフラグが立っている64ビット
    func canPut(put: UInt64) -> Bool {
        let legalBoard: UInt64 = makeLegalBoard(board: self)
        
        return (put & legalBoard) == put
    }
    //cpuのが配置可能な、合法手ボードの生成
    private func makeLegalBoard(board: Board) -> UInt64 {
        let holizontalWatchBoard: UInt64 = board.opponentBoard & 0x7e7e7e7e7e7e7e7e
        let verticalWatchBoard:   UInt64 = board.opponentBoard & 0xFFFFFFFFFFFFFF00
        let allSideWatchBoard:     UInt64 = board.opponentBoard & 0x007e7e7e7e7e7e00
        let blankBoard:           UInt64 = ~(board.playerBoard | board.opponentBoard)
        //隣に相手の色があるかを一時保存する
        var tmp: UInt64
        //返り値
        var legalBoard: UInt64
        
        //左
        tmp = holizontalWatchBoard & (board.playerBoard << 1)
        tmp |= holizontalWatchBoard & (tmp << 1)
        tmp |= holizontalWatchBoard & (tmp << 1)
        tmp |= holizontalWatchBoard & (tmp << 1)
        tmp |= holizontalWatchBoard & (tmp << 1)
        tmp |= holizontalWatchBoard & (tmp << 1)
        legalBoard = blankBoard & (tmp << 1)
        
        //右
        tmp = holizontalWatchBoard & (board.playerBoard >> 1)
        tmp |= holizontalWatchBoard & (tmp >> 1)
        tmp |= holizontalWatchBoard & (tmp >> 1)
        tmp |= holizontalWatchBoard & (tmp >> 1)
        tmp |= holizontalWatchBoard & (tmp >> 1)
        tmp |= holizontalWatchBoard & (tmp >> 1)
        legalBoard |= blankBoard & (tmp >> 1)
        
        //上
        tmp = verticalWatchBoard & (board.playerBoard << 8)
        tmp |= verticalWatchBoard & (tmp << 8)
        tmp |= verticalWatchBoard & (tmp << 8)
        tmp |= verticalWatchBoard & (tmp << 8)
        tmp |= verticalWatchBoard & (tmp << 8)
        tmp |= verticalWatchBoard & (tmp << 8)
        legalBoard |= blankBoard & (tmp << 8)
        
        //下
        tmp = verticalWatchBoard & (board.playerBoard >> 8)
        tmp |= verticalWatchBoard & (tmp >> 8)
        tmp |= verticalWatchBoard & (tmp >> 8)
        tmp |= verticalWatchBoard & (tmp >> 8)
        tmp |= verticalWatchBoard & (tmp >> 8)
        tmp |= verticalWatchBoard & (tmp >> 8)
        legalBoard |= blankBoard & (tmp >> 8)
        
        //右斜上
        tmp = allSideWatchBoard & (board.playerBoard << 7)
        tmp |= allSideWatchBoard & (tmp << 7)
        tmp |= allSideWatchBoard & (tmp << 7)
        tmp |= allSideWatchBoard & (tmp << 7)
        tmp |= allSideWatchBoard & (tmp << 7)
        tmp |= allSideWatchBoard & (tmp << 7)
        legalBoard |= blankBoard & (tmp << 7)
        
        //左斜上
        tmp = allSideWatchBoard & (board.playerBoard << 9)
        tmp |= allSideWatchBoard & (tmp << 9)
        tmp |= allSideWatchBoard & (tmp << 9)
        tmp |= allSideWatchBoard & (tmp << 9)
        tmp |= allSideWatchBoard & (tmp << 9)
        tmp |= allSideWatchBoard & (tmp << 9)
        legalBoard |= blankBoard & (tmp << 9)
        
        //右斜下
        tmp = allSideWatchBoard & (board.playerBoard >> 9)
        tmp |= allSideWatchBoard & (tmp >> 9)
        tmp |= allSideWatchBoard & (tmp >> 9)
        tmp |= allSideWatchBoard & (tmp >> 9)
        tmp |= allSideWatchBoard & (tmp >> 9)
        tmp |= allSideWatchBoard & (tmp >> 9)
        legalBoard |= blankBoard & (tmp >> 9)
        
        //左斜下
        tmp = allSideWatchBoard & (board.playerBoard >> 7)
        tmp |= allSideWatchBoard & (tmp >> 7)
        tmp |= allSideWatchBoard & (tmp >> 7)
        tmp |= allSideWatchBoard & (tmp >> 7)
        tmp |= allSideWatchBoard & (tmp >> 7)
        tmp |= allSideWatchBoard & (tmp >> 7)
        legalBoard |= blankBoard & (tmp >> 7)
        
        return legalBoard
    }
    
    //反転処理
    //引数は置いた位置にのみフラグが立っている64ビット
    func reverse(put: UInt64) {
        var rev: UInt64 = 0
        for k in 0..<8 {
            var rev_ : UInt64 = 0
            var mask : UInt64 = transfer(put: put, k: k)
            //隣に相手の色がある場合は条件式 is true
            while (mask != 0)&&((mask & opponentBoard) != 0) {
                rev_ |= mask
                mask = transfer(put: mask, k: k)
            }
            //反対側に自分の色がある場合は条件式 is true
            if (mask & playerBoard) != 0 {
                rev |= rev_
            }
        }
        //反転する
        playerBoard ^= put | rev // ^= は排他的論理和
        opponentBoard ^= rev
        putRevArray.append(put)
        putRevArray.append(rev)
        
        nowIndex  = self.nowIndex + 1
    }
    
    private func transfer(put: UInt64, k: Int) -> UInt64 {
        switch  k {
        case 0:
            return (put << 8) & 0xFFFFFFFFFFFFFF00
        case 1:
            return (put << 7) & 0x7f7f7f7f7f7f7f00
        case 2:
            return (put >> 1) & 0x7f7f7f7f7f7f7f7f
        case 3:
            return (put >> 9) & 0x007f7f7f7f7f7f7f
        case 4:
            return (put >> 8) & 0x00ffffffffffffff
        case 5:
            return (put >> 7) & 0x00ffffffffffffff
        case 6:
            return (put << 1) & 0xfefefefefefefefe
        case 7:
            return (put << 9) & 0xfefefefefefefe00
        default:
            return 0
        }
    }
    
    //パス判定
    func  isPass() -> Bool {
        let playerLegalBoard = makeLegalBoard(board: self)
        
        let tmpBoard = Board()
        tmpBoard.nowTurn = nowTurn
        tmpBoard.nowIndex = nowIndex
        tmpBoard.playerBoard = opponentBoard
        tmpBoard.opponentBoard = playerBoard
        let opponentLegalBoard = makeLegalBoard(board: tmpBoard)
        
        //手番側だけがパスの場合true
        return (playerLegalBoard == 0x0000000000000000 && opponentLegalBoard != 0x0000000000000000)
    }
    
    //終局判定
    func isGameFinished() -> Bool {
        let playerLegalBoard = makeLegalBoard(board: self)
        
        let tmpBoard = Board()
        tmpBoard.nowTurn = nowTurn
        tmpBoard.nowIndex = nowIndex
        tmpBoard.playerBoard = opponentBoard
        tmpBoard.opponentBoard = playerBoard
        let opponentLegalBoard = makeLegalBoard(board: tmpBoard)
        
        //両手番とも設置不可の場合true
        return (playerLegalBoard == 0x0000000000000000 && opponentLegalBoard == 0x0000000000000000)
    }
    
    //手番交代
    func swapBoard() {
        //ボードの入れ替え
        (playerBoard, opponentBoard) = (opponentBoard, playerBoard)
        //色の入れ替え
        nowTurn *= -1
    }
    
    //結果の取得
    func getResult() -> (firstScore: Int, secondScore: Int, winner: String) {
        //石数の取得
        var firstScore = bitCount(playerBoard)
        var secondScore  = bitCount(opponentBoard)
        
        if nowTurn == RED_TURN {
            let tmp = firstScore
            firstScore = secondScore
            secondScore = tmp
        }
        var winner = "青"
        let isRedWin = secondScore >= firstScore
        if isRedWin {
            winner = "赤"
        }
        return (firstScore, secondScore, winner)
    }
    
    public func bitCount(_ num: UInt64) -> Int {
        let BOARDSIZE = 64
        var mask: UInt64 = 0x8000000000000000
        var count: Int = 0
        
        for _ in 0..<BOARDSIZE {
            if mask & num != 0{
                count += 1
            }
            mask = mask >> 1
        }
        return count
    }
    
    func undo(){
        //反転する
        let length = putRevArray.count - 1
        playerBoard ^= putRevArray[length-1] | putRevArray[length] // ^= は排他的論理和
        opponentBoard ^= putRevArray[length]
        _ = putRevArray.popLast()
        _ = putRevArray.popLast()
        nowIndex  = self.nowIndex - 1
    }
    
    
    var count: Int = 0 //場合わけの回数
    /*
    public func negaMax(depth: Int) -> (Int, UInt64) {
//        count += 1
        var depth_ = depth
        var maxValue: Int?
        var bestPut: UInt64 = 0x0000000000000000
        let semaphore = DispatchSemaphore(value: 0)
        var fin = false{
            didSet{semaphore.signal()}
        }
        if depth == 6{
        print("❤️",String(self.playerBoard,radix: 16))
        }
        if depth_ == 0 {
            swapBoard()
            return (-evaluation(),0)
        }
        
        var put: UInt64 = 0x8000000000000000
        for y in 1..<9 {
            for x in 1..<9 {
                //A1のみフラグが立っているボード
//                var put: UInt64 = 0x8000000000000000
//                put = put >> ((y-1)*8 + (x-1))
                //A1から順に、配置可能な位置に配置
                if self.canPut(put: put) {
                    self.reverse(put: put)
                    self.swapBoard()
                    if self.isPass() {
                        self.swapBoard()
                        depth_ = depth_ - 1
//                        if depth_ % 2 == 1{
//                            //cpu ad
//                            return (-100, put)
//                        }else{
//                            return (100, put)
//                        }
                    }else if isGameFinished() {
                        swapBoard()
                        undo()
                        count += 1
                        if depth_ % 2 == 1{
                            //cpu win
                            return (-100, put)
                        }else{
                            return (100, put)
                        }
                    }
                    let (val, _) = self.negaMax(depth: depth_-1)
                    if depth == 7 {print("⭐️")}
                    if maxValue == nil || maxValue! < -val {
                        maxValue = -val
                        bestPut = put
                    }
                    self.swapBoard()
                    undo()
                }
                put = put >> 1
                if (x+y==16){fin = true}
            }
        }
        semaphore.wait()
        if maxValue == nil {
            return (-1, bestPut)
        }
        return (maxValue!, bestPut)
    }
    
    //静的評価関数
    func evaluation() -> Int {
        count += 1
        let (firstScore, secondScore, _) = getResult()
        print(String(self.playerBoard, radix: 16))
        print(firstScore)
        let blankBoard:           UInt64 = ~(self.playerBoard | self.opponentBoard)
        let blankNum = bitCount(blankBoard)
        print(String(blankBoard, radix: 16))
        return firstScore - secondScore + blankNum
    }
    */
}
