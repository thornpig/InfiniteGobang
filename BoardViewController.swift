//
//  BoardViewController.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit
import ReplayKit

var numOfRounds = 0

class BoardViewController: UIViewController, UIScrollViewDelegate, BoardViewDataSource, BoardCellDelegate {
    
    
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var historyBarButtonItem: UIBarButtonItem!
    
    var boardView: BoardView!
    var gameBoard: GameBoard!
    var label: UILabel!
    var restartButton: UIButton!

    var cellColors: [UIColor]!
    var icons: [UIImage]!
    var lastCell: GridCell?
    
    var previewViewController: UIViewController?
    var recorderPaused: Bool = false
    
    var numOfWins: Int = 0
    var numOfLoses: Int = 0

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
        
        self.recordSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("shouldRecord")
        self.historyBarButtonItem.title = "\(self.numOfWins) W  :  \(self.numOfLoses)"
        
        self.gameBoard = GameBoard()
        self.gameBoard.players = [Player(name: "You", index: 0, gameBoard: self.gameBoard), Computer(name: "Computer", index: 1, gameBoard: self.gameBoard)]
        self.cellColors = [UIColor.greenColor(), UIColor.blueColor()]
        self.icons = [UIImage(named: "circle")!, UIImage(named: "cross")!]
        
        self.startScreenRecording()

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
//            boardCell.button.backgroundColor = self.cellColors[gridCell.player!.index]
            if let winner = self.gameBoard.winner {
                boardCell.button.userInteractionEnabled = true
                if winner.winningCellSeq!.cellCoords.contains(gridCell.coord) {
                    boardCell.button.backgroundColor = kCellBackgroundColorWinning
                }
            } else {
                boardCell.button.userInteractionEnabled = false
                if gridCell === self.lastCell {
    //               boardCell.layer.borderColor = kCellBorderColorHighlight.CGColor
    //               boardCell.layer.borderWidth = 1.0
                    boardCell.button.backgroundColor = kCellBackgroundColorHighlight

                }
            }
            boardCell.button.setBackgroundImage(self.icons[gridCell.player.index], forState: .Normal)

        } else {
            boardCell.button.setBackgroundImage(nil, forState: .Normal)
            boardCell.layer.borderColor = kCellBorderColor.CGColor
            boardCell.button.backgroundColor = kCellBackgroundColor
            boardCell.layer.borderWidth = 0.5
        }

    }
    
    func onBoardCellTapped(boardCell: BoardCell) {
        

        if self.gameBoard.winner != nil {
            self.restart()
            return
        }
        
        if self.gameBoard.numOfRounds > 1 && (self.gameBoard.currentPlayer as? Computer != nil) {
            return
        }

        self.gameBoard.grid[boardCell.coord] = GridCell(coord: boardCell.coord, player: self.gameBoard.currentPlayer)
        self.gameBoard.addCell(GridCell(coord: boardCell.coord, player: self.gameBoard.currentPlayer))

        if let lastCell = self.lastCell {
            self.boardView[lastCell.coord]?.layer.borderColor = kCellBorderColor.CGColor
            self.boardView[lastCell.coord]?.button.backgroundColor = kCellBackgroundColor
            self.boardView[lastCell.coord]?.layer.borderWidth = 0.5
        }
        boardCell.button.userInteractionEnabled = false
//        boardCell.button.backgroundColor = self.cellColors[self.gameBoard.indexOfPlayer]
        boardCell.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], forState: .Normal)
//        boardCell.layer.borderColor = kCellBorderColorHighlight.CGColor
        boardCell.button.backgroundColor = kCellBackgroundColorHighlight
        boardCell.layer.borderWidth = 1.0
        self.lastCell = self.gameBoard.grid[boardCell.coord]
        
        self.gameBoard.currentPlayer.removeUncompletableSeqs()
        if self.gameBoard.currentPlayer.didPickGridCellAtCoord(boardCell.coord) == .Won {
            self.didFindWinner()
            return
        }
//            self.view.userInteractionEnabled = false
        self.gameBoard.numOfRounds += 1
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.gameBoard.currentPlayer.removeUncompletableSeqs()
            let cellCoordPickedByComputer = (self.gameBoard.currentPlayer as! Computer).cellCoordToPick
            self.gameBoard.addCell(GridCell(coord: cellCoordPickedByComputer, player: self.gameBoard.currentPlayer))
            dispatch_async(dispatch_get_main_queue()) {
                
//                    self.view.userInteractionEnabled = true
                if let boardCellPickedByComputer = self.boardView[cellCoordPickedByComputer] {
                  
                    boardCellPickedByComputer.button.userInteractionEnabled = false
//                        boardCellPickedByComputer.button.backgroundColor = self.cellColors[self.gameBoard.indexOfPlayer]
                    boardCellPickedByComputer.button.setBackgroundImage(self.icons[self.gameBoard.indexOfPlayer], forState: .Normal)
//                        boardCellPickedByComputer.layer.borderColor = kCellBorderColorHighlight.CGColor
                    boardCellPickedByComputer.button.backgroundColor = kCellBackgroundColorHighlight
                    boardCellPickedByComputer.layer.borderWidth = 1.0
                   
                }
                
                self.boardView.scrollToShowCellCoordAtCenter(cellCoordPickedByComputer)
                
                self.boardView[self.lastCell!.coord]?.layer.borderColor = kCellBorderColor.CGColor
                self.boardView[self.lastCell!.coord]?.button.backgroundColor = kCellBackgroundColor
                self.boardView[self.lastCell!.coord]?.layer.borderWidth = 0.5
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

        
        self.gameBoard.winner = self.gameBoard.currentPlayer
        let winningCellCoords = self.gameBoard.currentPlayer.winningCellSeq!.cellCoords
        self.boardView.scrollToShowCellCoordAtCenter(winningCellCoords[winningCellCoords.count / 2])
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            for cellCoord in winningCellCoords {
                self.boardView[cellCoord]?.button.backgroundColor = kCellBackgroundColorWinning
            }
        }, completion: {_ in
            
            self.stopScreenRecordingWithHandler { _ in

                UIView.animateWithDuration(0.0, delay: 1.0, options: .CurveEaseOut, animations: {
                    }, completion: {_ in
                        let message = "\(self.gameBoard.currentPlayer.name) Won!"
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in
                            for aColomnOfCells in self.boardView.cells {
                                for boardCell in aColomnOfCells {
                                    boardCell.button.userInteractionEnabled = true
                                }
                            }
                        }))
                        if self.previewViewController != nil {
                            alert.addAction(UIAlertAction(title: "Preview recording", style: UIAlertActionStyle.Default, handler: { _ in
                                self.presentViewController(self.previewViewController!, animated: true, completion: nil)
                            }))
                        }
                        alert.addAction(UIAlertAction(title: "New game", style: UIAlertActionStyle.Default, handler: { _ in
                            self.restart()
                        }))

                        self.presentViewController(alert, animated: true, completion: nil)

                })
            }
        })
    }
    
    func restart() {
        self.gameBoard.reset()
        self.boardView.removeFromSuperview()
        self.boardView = nil
        self.createBoardView()
        
        self.discardRecording()
        self.startScreenRecording()
        
        print("Restart")
        
    }
    
    @IBAction func onRecordSwitchChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sender.on, forKey: "shouldRecord")
    }
    
}

extension BoardViewController: RPPreviewViewControllerDelegate, RPScreenRecorderDelegate {
    var screenRecordingToggleEnabled: Bool {
//        return NSUserDefaults.standardUserDefaults().boolForKey(screenRecorderEnabledKey)
        return self.recordSwitch.on
    }
    
    // MARK: Start/Stop Screen Recording
    
    func startScreenRecording() {
        // Do nothing if screen recording hasn't been enabled.
        guard screenRecordingToggleEnabled else { return }
        
        let sharedRecorder = RPScreenRecorder.sharedRecorder()
        
        // Register as the recorder's delegate to handle errors.
        sharedRecorder.delegate = self
        
        sharedRecorder.startRecordingWithMicrophoneEnabled(true) { error in
            if let error = error {
                self.showScreenRecordingAlert(error.localizedDescription)
            }
        }
    }
    
    func stopScreenRecordingWithHandler(handler:(() -> Void)) {
        
        let sharedRecorder = RPScreenRecorder.sharedRecorder()
        
        if sharedRecorder.recording == false {
            handler()
            return
        }
        
        sharedRecorder.stopRecordingWithHandler { (previewViewController: RPPreviewViewController?, error: NSError?) in
            if let error = error {
                // If an error has occurred, display an alert to the user.
                self.showScreenRecordingAlert(error.localizedDescription)
                return
            }
            
            if let previewViewController = previewViewController {
                // Set delegate to handle view controller dismissal.
                previewViewController.previewControllerDelegate = self
                
                /*
                Keep a reference to the `previewViewController` to
                present when the user presses on preview button.
                */
                self.previewViewController = previewViewController
            }
            
            handler()
        }
    }
    
    func showScreenRecordingAlert(message: String) {
        // Pause the scene and un-pause after the alert returns.
        self.recorderPaused = true
        
        // Show an alert notifying the user that there was an issue with starting or stopping the recorder.
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { _ in
            self.recorderPaused = false
        }
        alertController.addAction(alertAction)
        
        view?.window?.rootViewController?.presentViewController(alertController, animated: false, completion: nil)
    }
    
    func discardRecording() {
        // When we no longer need the `previewViewController`, tell ReplayKit to discard the recording and nil out our reference
        RPScreenRecorder.sharedRecorder().discardRecordingWithHandler {
            self.previewViewController = nil
        }
    }
    
    // MARK: RPScreenRecorderDelegate
    
    func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
        // Display the error the user to alert them that the recording failed.
        showScreenRecordingAlert(error.localizedDescription)
        
        /*
        Hold onto a reference of the `previewViewController` if not nil. The
        `previewViewController` will be nil when:
        
        - There is an error writing the movie file (disk space, avfoundation).
        - startRecording failed due to AirPlay/TVOut session is in progress.
        - startRecording failed because the device does not support it (lower than A7)
        */
        if previewViewController != nil {
            self.previewViewController = previewViewController
        }
    }
    
    // MARK: RPPreviewViewControllerDelegate
    
//    func previewControllerDidFinish(previewController: RPPreviewViewController) {
//        previewViewController?.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        previewViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
