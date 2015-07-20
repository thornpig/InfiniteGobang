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
            NSUserDefaults.standardUserDefaults().setInteger(self.numOfWins, forKey: kUserDefaultKeyForWins)
        }
    }
    
    var numOfLoses: Int = 0 {
        didSet {
            self.title = "\(self.numOfWins) W  :  \(self.numOfLoses) L"
            NSUserDefaults.standardUserDefaults().setInteger(self.numOfLoses, forKey: kUserDefaultKeyForLoses)
        }
    }
    

    override func loadView() {
        super.loadView()
        self.createBoardView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController!.navigationBar.titleTextAttributes = NSDictionary(object: UIColor.lightGrayColor(), forKey: NSForegroundColorAttributeName) as! [String : AnyObject]
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        
        self.numOfWins = NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultKeyForWins)
        self.numOfLoses = NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultKeyForLoses)
        

        
        self.gameBoard = GameBoard()
        self.gameBoard.players = [Player(name: "You", index: 0, gameBoard: self.gameBoard), Computer(name: "Computer", index: 1, gameBoard: self.gameBoard)]
        self.icons = [UIImage(named: "circle")!, UIImage(named: "cross")!]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.boardView.reusableCells.removeAll(keepCapacity: false)
        // Dispose of any resources that can be recreated.
    }
    
    func createBoardView() {
        let screenBounds = UIScreen.mainScreen().bounds
        let boardViewFrame = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height)
        self.boardView = BoardView(frame: boardViewFrame)
        self.boardView.delegate = self
        self.boardView.dataSource = self
        self.boardView.clearsContextBeforeDrawing = false
        self.view.addSubview(self.boardView)
//        self.view.userInteractionEnabled = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let boardView = scrollView as! BoardView
        boardView.manageCellsAfterScroll()
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        println("offset before dragging  \(self.contentOffsetBase)" + "bounds \(scrollView.bounds)")
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let boardView = scrollView as! BoardView
        boardView.setupContentInsets()
    }
    
   
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
//            println("offset for stationary scrollView after dragging \(scrollView.contentOffset)" + "base \(self.contentOffsetBase)")
            let boardView = scrollView as! BoardView
            boardView.setupContentInsets()
        }
    }
    
    func setupBoardViewCell(boardView: BoardView, boardCell: BoardCell) {
        if boardCell.delegate !== self {
                boardCell.delegate = self
        }
        
        if let gridCell = self.gameBoard[boardCell.coord] {
            if let _ = self.gameBoard.winner {
                boardCell.button.userInteractionEnabled = true
            } else {
                boardCell.button.userInteractionEnabled = false
                if gridCell === self.lastCell {
                    boardCell.button.backgroundColor = kCellBackgroundColorHighlight
                }
            }
            boardCell.button.setBackgroundImage(self.icons[gridCell.player.index], forState: .Normal)

        } else {
            boardCell.button.setBackgroundImage(nil, forState: .Normal)
            boardCell.button.backgroundColor = kCellBackgroundColor
        }

    }
    
    func onBoardCellTapped(boardCell: BoardCell) {
        
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
        boardCell.button.userInteractionEnabled = false
        boardCell.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], forState: .Normal)
        self.lastCell = self.gameBoard.grid[boardCell.coord]
        boardCell.button.backgroundColor = kCellBackgroundColorHighlight
        
        self.gameBoard.currentPlayer.removeUncompletableSeqs()
        if self.gameBoard.currentPlayer.didPickGridCellAtCoord(boardCell.coord) == .Won {
            self.didFindWinner()
            return
        }
        self.gameBoard.numOfRounds += 1
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.gameBoard.currentPlayer.removeUncompletableSeqs()
            let cellCoordPickedByComputer = (self.gameBoard.currentPlayer as! Computer).cellCoordToPick
            self.gameBoard.addCell(GridCell(coord: cellCoordPickedByComputer, player: self.gameBoard.currentPlayer))
            dispatch_async(dispatch_get_main_queue()) {
                
                if let boardCellPickedByComputer = self.boardView[cellCoordPickedByComputer] {
                  
                    boardCellPickedByComputer.button.userInteractionEnabled = false
                    boardCellPickedByComputer.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], forState: .Normal)
                    boardCellPickedByComputer.button.backgroundColor = kCellBackgroundColorHighlight
                   
                }
                
                self.boardView.scrollToShowCellCoordAtCenter(cellCoordPickedByComputer, completion: nil)
                
                self.boardView[self.lastCell!.coord]?.button.backgroundColor = kCellBackgroundColor
                self.lastCell = self.gameBoard.grid[cellCoordPickedByComputer]
                
                if self.gameBoard.currentPlayer.didPickGridCellAtCoord(cellCoordPickedByComputer) == .Won {
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
                let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in
                    for aColomnOfCells in self.boardView.cells {
                        for boardCell in aColomnOfCells {
                            boardCell.button.userInteractionEnabled = true
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "New game", style: UIAlertActionStyle.Default, handler: { _ in
                    self.restart()
                }))

                self.presentViewController(alert, animated: true, completion: nil)
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
    
    func drawALineToConnectWinningCounters(completion: (() -> Void) ) {
        let winningCellCoords = self.gameBoard.currentPlayer.winningCellSeq!.cellCoords
        let startCellFrame = self.boardView.getFrameForCellCoord(winningCellCoords.first!)
        let endCellFrame = self.boardView.getFrameForCellCoord(winningCellCoords.last!)
        let startPoint = CGPointMake(startCellFrame.origin.x + startCellFrame.size.width * 0.5, startCellFrame.origin.y + startCellFrame.size.height * 0.5)
        let endPoint = CGPointMake(endCellFrame.origin.x + endCellFrame.size.width * 0.5, endCellFrame.origin.y + endCellFrame.size.height * 0.5)
        
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.CGPath
        lineLayer.strokeColor = kCellBackgroundColorWinning.CGColor
        lineLayer.lineWidth = 5.0
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 1.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        lineLayer.addAnimation(animateStrokeEnd, forKey: nil)
        CATransaction.commit()
        self.boardView.layer.addSublayer(lineLayer)
    }
    
    @IBAction func onNewButtonTapped(sender: UIBarButtonItem) {
        self.restart()
    }
    
    
}

