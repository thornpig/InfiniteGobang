//
//  BoardViewController.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit


let kUserDefaultKeyForWins = "numOfWins"
let kUserDefaultKeyForLoses = "numOfLoses"

class BoardViewController: UIViewController, UIScrollViewDelegate, BoardViewDataSource, BoardCellDelegate {
    
    
    @IBOutlet weak var newButton: UIBarButtonItem!
    
    var boardView: BoardView!
    var gameBoard: GameBoard!

    var icons: [UIImage]!
    var lastCell: GridCell?
    
    var numOfWins: Int = 0 {
        didSet {
            self.title = "\(self.numOfWins) W  :  \(self.numOfLoses) L"
            UserDefaults.standard.set(self.numOfWins, forKey: kUserDefaultKeyForWins)
        }
    }
    
    var numOfLoses: Int = 0 {
        didSet {
            self.title = "\(self.numOfWins) W  :  \(self.numOfLoses) L"
            UserDefaults.standard.set(self.numOfLoses, forKey: kUserDefaultKeyForLoses)
        }
    }
    

    override func loadView() {
        super.loadView()
        self.createBoardView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController!.navigationBar.titleTextAttributes = NSDictionary(object: UIColor.lightGrayColor(), forKey: NSForegroundColorAttributeName) as! [String : AnyObject]
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.lightGray]
        
        self.numOfWins = UserDefaults.standard.integer(forKey: kUserDefaultKeyForWins)
        self.numOfLoses = UserDefaults.standard.integer(forKey: kUserDefaultKeyForLoses)
        

        
        self.gameBoard = GameBoard()
        self.gameBoard.players = [Player(name: "You", index: 0, gameBoard: self.gameBoard), Computer(name: "Computer", index: 1, gameBoard: self.gameBoard)]
        self.icons = [UIImage(named: "circle")!, UIImage(named: "cross")!]
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.boardView.reusableCells.removeAll(keepingCapacity: false)
        // Dispose of any resources that can be recreated.
    }
    
    func createBoardView() {
        let screenBounds = UIScreen.main.bounds
        let boardViewFrame = CGRect(x: 0.0, y: 0.0, width: screenBounds.size.width, height: screenBounds.size.height)
        self.boardView = BoardView(frame: boardViewFrame)
        self.boardView.delegate = self
        self.boardView.dataSource = self
        self.boardView.clearsContextBeforeDrawing = false
        self.view.addSubview(self.boardView)
//        self.view.userInteractionEnabled = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let boardView = scrollView as! BoardView
        boardView.manageCellsAfterScroll()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        println("offset before dragging  \(self.contentOffsetBase)" + "bounds \(scrollView.bounds)")
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let boardView = scrollView as! BoardView
        boardView.setupContentInsets()
    }
    
   
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
//            println("offset for stationary scrollView after dragging \(scrollView.contentOffset)" + "base \(self.contentOffsetBase)")
            let boardView = scrollView as! BoardView
            boardView.setupContentInsets()
        }
    }
    
    func setupBoardViewCell(_ boardView: BoardView, boardCell: BoardCell) {
        if boardCell.delegate !== self {
                boardCell.delegate = self
        }
        
        if let gridCell = self.gameBoard[boardCell.coord] {
            if let _ = self.gameBoard.winner {
                boardCell.button.isUserInteractionEnabled = true
            } else {
                boardCell.button.isUserInteractionEnabled = false
                if gridCell === self.lastCell {
                    boardCell.button.backgroundColor = kCellBackgroundColorHighlight
                }
            }
            boardCell.button.setBackgroundImage(self.icons[gridCell.player.index], for: UIControlState())

        } else {
            boardCell.button.setBackgroundImage(nil, for: UIControlState())
            boardCell.button.backgroundColor = kCellBackgroundColor
        }

    }
    
    func onBoardCellTapped(_ boardCell: BoardCell) {
        
        if self.gameBoard.winner != nil {
            self.restart()
            return
        }
        
        if self.gameBoard.numOfRounds > 1 && self.gameBoard.currentPlayer is Computer {
            return
        }

        self.gameBoard.grid[boardCell.coord] = GridCell(coord: boardCell.coord, player: self.gameBoard.currentPlayer)
        self.gameBoard.addCell(GridCell(coord: boardCell.coord, player: self.gameBoard.currentPlayer))

        if let lastCell = self.lastCell {
            self.boardView[lastCell.coord]?.button.backgroundColor = kCellBackgroundColor
        }
        boardCell.button.isUserInteractionEnabled = false
        boardCell.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], for: UIControlState())
        self.lastCell = self.gameBoard.grid[boardCell.coord]
        boardCell.button.backgroundColor = kCellBackgroundColorHighlight
        
        self.gameBoard.currentPlayer.removeUncompletableSeqs()
        if self.gameBoard.currentPlayer.didPickGridCellAtCoord(boardCell.coord) == .won {
            self.didFindWinner()
            return
        }
        self.gameBoard.numOfRounds += 1
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            self.gameBoard.currentPlayer.removeUncompletableSeqs()
            let cellCoordPickedByComputer = (self.gameBoard.currentPlayer as! Computer).cellCoordToPick
            self.gameBoard.addCell(GridCell(coord: cellCoordPickedByComputer, player: self.gameBoard.currentPlayer))
            DispatchQueue.main.async {
                
                if let boardCellPickedByComputer = self.boardView[cellCoordPickedByComputer] {
                  
                    boardCellPickedByComputer.button.isUserInteractionEnabled = false
                    boardCellPickedByComputer.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], for: UIControlState())
                    boardCellPickedByComputer.button.backgroundColor = kCellBackgroundColorHighlight
                   
                }
                
                self.boardView.scrollToShowCellCoordAtCenter(cellCoordPickedByComputer, completion: nil)
                
                self.boardView[self.lastCell!.coord]?.button.backgroundColor = kCellBackgroundColor
                self.lastCell = self.gameBoard.grid[cellCoordPickedByComputer]
                
                if self.gameBoard.currentPlayer.didPickGridCellAtCoord(cellCoordPickedByComputer) == .won {
                    self.didFindWinner()
                    return
                }
                self.gameBoard.numOfRounds += 1
            }
        }
        
        print("shit")
    }
    
    func didFindWinner() {
        
        if let lastBoardCell = self.boardView[self.lastCell!.coord] {
           lastBoardCell.button.backgroundColor = kCellBackgroundColor
        }
        self.lastCell = nil
        

        self.gameBoard.winner = self.gameBoard.currentPlayer
        self.updateHistoryRecord()
        let winningCellCoords = self.gameBoard.currentPlayer.winningCellSeq!.cellCoords
//        self.boardView.scrollToShowCellCoordAtCenter(winningCellCoords[winningCellCoords.count / 2])
        
        self.boardView.scrollToShowCellCoordAtCenter(winningCellCoords[winningCellCoords.count / 2]) { _ in
            self.drawALineToConnectWinningCounters { () -> Void in
                let message = "\(self.gameBoard.currentPlayer.name) Won!"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { _ in
                    for aColomnOfCells in self.boardView.cells {
                        for boardCell in aColomnOfCells {
                            boardCell.button.isUserInteractionEnabled = true
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "New game", style: UIAlertActionStyle.default, handler: { _ in
                    self.restart()
                }))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func updateHistoryRecord() {
        guard let winner = self.gameBoard.winner else { return }
        if winner is Computer {
            self.numOfLoses += 1
        } else {
            self.numOfWins += 1
        }

    }
    
    func restart() {
        self.gameBoard.reset()
        self.boardView.removeFromSuperview()
        self.boardView = nil
        self.createBoardView()
        
        print("Restart")
        
    }
    
    func drawALineToConnectWinningCounters(_ completion: @escaping (() -> Void) ) {
        let winningCellCoords = self.gameBoard.currentPlayer.winningCellSeq!.cellCoords
        let startCellFrame = self.boardView.getFrameForCellCoord(winningCellCoords.first!)
        let endCellFrame = self.boardView.getFrameForCellCoord(winningCellCoords.last!)
        let startPoint = CGPoint(x: startCellFrame.origin.x + startCellFrame.size.width * 0.5, y: startCellFrame.origin.y + startCellFrame.size.height * 0.5)
        let endPoint = CGPoint(x: endCellFrame.origin.x + endCellFrame.size.width * 0.5, y: endCellFrame.origin.y + endCellFrame.size.height * 0.5)
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = kCellBackgroundColorWinning.cgColor
        lineLayer.lineWidth = 5.0
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 1.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        lineLayer.add(animateStrokeEnd, forKey: nil)
        CATransaction.commit()
        self.boardView.layer.addSublayer(lineLayer)
    }
    
    @IBAction func onNewButtonTapped(_ sender: UIBarButtonItem) {
        self.restart()
    }
    
    
}

