//
//  BoardViewController.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit

var numOfRounds = 0

class BoardViewController: UIViewController, UIScrollViewDelegate, BoardViewDataSource, BoardCellDelegate {
    
    var boardView: BoardView!
    var gameBoard: GameBoard!
    var label: UILabel!
    var restartButton: UIButton!

    var cellColors: [UIColor]!
    var icons: [UIImage]!
    var lastCell: GridCell?

    override func loadView() {
        super.loadView()
        self.createBoardView()
//        self.label = UILabel(frame: CGRectMake(10, boardViewFrame.size.height + 10, 150, 30))
//        self.view.addSubview(self.label)
//        self.label.hidden = true
//        
//        self.restartButton = UIButton(frame: CGRectMake(200, boardViewFrame.size.height + 10, 100, 30))
//        self.restartButton.backgroundColor = UIColor.blackColor()
//        self.restartButton.setTitle("Restart", forState: UIControlState.Normal)
//        self.restartButton.addTarget(self, action: "onRestartButtonTapped", forControlEvents: .TouchUpInside)
//        self.view.addSubview(self.restartButton)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameBoard = GameBoard()
        self.gameBoard.players = [Player(name: "Zack", index: 0, gameBoard: self.gameBoard), Computer(name: "Computer", index: 1, gameBoard: self.gameBoard)]
        self.cellColors = [UIColor.greenColor(), UIColor.blueColor()]
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
//            boardCell.button.backgroundColor = self.cellColors[gridCell.player!.index]
            if gridCell === self.lastCell {
               boardCell.layer.borderColor = UIColor.greenColor().CGColor
               boardCell.layer.borderWidth = 1.0
            } else {
                boardCell.layer.borderColor = UIColor.yellowColor().CGColor
                boardCell.layer.borderWidth = 0.5
            }
            boardCell.button.setBackgroundImage(self.icons[gridCell.player!.index], forState: .Normal)
            boardCell.button.userInteractionEnabled = false
        } else {
            boardCell.button.setBackgroundImage(nil, forState: .Normal)
            boardCell.layer.borderColor = UIColor.yellowColor().CGColor
            boardCell.layer.borderWidth = 0.5
        }

    }
    
    func onBoardCellTapped(boardCell: BoardCell) {
        
        if self.gameBoard.numOfRounds > 0 && (self.gameBoard.currentPlayer as? Computer == nil) {
            return
        }
        
        self.gameBoard.numOfRounds += 1

        self.gameBoard.grid[boardCell.coord] = GridCell(coord: boardCell.coord, player: self.gameBoard.currentPlayer)

        if let lastCell = self.lastCell {
            self.boardView[lastCell.coord]?.layer.borderColor = UIColor.yellowColor().CGColor
            self.boardView[lastCell.coord]?.layer.borderWidth = 0.5
        }
        boardCell.button.userInteractionEnabled = false
//        boardCell.button.backgroundColor = self.cellColors[self.gameBoard.indexOfPlayer]
        boardCell.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], forState: .Normal)
        boardCell.layer.borderColor = UIColor.greenColor().CGColor
        boardCell.layer.borderWidth = 1.0
        self.lastCell = self.gameBoard.grid[boardCell.coord]
        
        self.gameBoard.currentPlayer.removeUncompletableSeqs()
        if self.gameBoard.currentPlayer.didPickGridCellAtCoord(boardCell.coord) == .Won {
            self.didFindWinner()
        } else {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                self.gameBoard.numOfRounds += 1
                self.gameBoard.currentPlayer.removeUncompletableSeqs()
                let cellCoordPickedByComputer = (self.gameBoard.currentPlayer as! Computer).cellCoordToPick
                self.gameBoard.grid[cellCoordPickedByComputer] = GridCell(coord: cellCoordPickedByComputer, player: self.gameBoard.currentPlayer)
                dispatch_async(dispatch_get_main_queue()) {
                    if let boardCellPickedByComputer = self.boardView[cellCoordPickedByComputer] {
                      
                        boardCellPickedByComputer.button.userInteractionEnabled = false
//                        boardCellPickedByComputer.button.backgroundColor = self.cellColors[self.gameBoard.indexOfPlayer]
                        boardCellPickedByComputer.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], forState: .Normal)
                        boardCellPickedByComputer.layer.borderColor = UIColor.greenColor().CGColor
                        boardCellPickedByComputer.layer.borderWidth = 1.0
                       
                    }
                    
                    let centerCell = self.boardView.cells[self.boardView.numOfColumns / 2][self.boardView.numOfRows / 2]
                    let deltaX = (CGFloat)(cellCoordPickedByComputer.indexOfColumn - centerCell.coord.indexOfColumn ) * centerCell.frame.size.width
                    let deltaY = (CGFloat)(centerCell.coord.indexOfRow - cellCoordPickedByComputer.indexOfRow ) * centerCell.frame.size.height
                    let offsetX = deltaX + self.boardView.bounds.origin.x
                    let offsetY = deltaY + self.boardView.bounds.origin.y
                    self.boardView.setContentOffset(CGPointMake(offsetX, offsetY), animated: true)
                    
                    self.boardView[self.lastCell!.coord]?.layer.borderColor = UIColor.yellowColor().CGColor
                    self.boardView[self.lastCell!.coord]?.layer.borderWidth = 0.5
                    self.lastCell = self.gameBoard.grid[cellCoordPickedByComputer]
                    
                    if self.gameBoard.currentPlayer.didPickGridCellAtCoord(cellCoordPickedByComputer) == .Won {
                        self.didFindWinner()
                    }
                }
            }
        }
        
        print("shit")
    }
    
    func didFindWinner() {
        let message = "\(self.gameBoard.currentPlayer.name) Won!"
//        self.label.text = message
//        self.label.hidden = false
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Play Again!", style: UIAlertActionStyle.Default, handler: { action in
            self.onRestartButtonTapped()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
       
    }
    
    func onRestartButtonTapped() {
        
        self.gameBoard.grid = [:]
        self.gameBoard.numOfRounds = 0
        self.gameBoard.players[0].gridCellSeqs = []
        self.gameBoard.players[1].gridCellSeqs = []
        self.boardView.removeFromSuperview()
        self.boardView = nil
        self.createBoardView()
//        self.label.hidden = true
        
        print("Restart")
    }
    
    
}
