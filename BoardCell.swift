//
//  BoardCell.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit

let kDefaultBoardCellSize: CGFloat = 50.0

protocol BoardCellDelegate: class  {
    func onBoardCellTapped(boardCell: BoardCell)
}

class BoardCell: UIView {
    
    var coord: CellCoord
    let button: UIButton
//    weak var delegate: BoardCellDelegate? {
//        willSet(newDelegate) {
//            if let newDelegate = newDelegate {
//                self.button.addTarget(newDelegate, action: "onBoardCellTapped:", forControlEvents: .TouchUpInside)
//            }
//        }
//    }
    weak var delegate: BoardCellDelegate?
    
    init(indexOfColumn: Int, indexOfRow: Int, frame: CGRect) {
        self.delegate = nil
        self.coord = CellCoord(indexOfColumn: indexOfColumn, indexOfRow: indexOfRow)
        let buttonFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)
        self.button = UIButton(frame: buttonFrame)
        super.init(frame: frame)

//        self.button.setTitle("\(indexOfColumn),\(indexOfRow)", forState: .Normal)
        self.button.backgroundColor = UIColor.lightGrayColor()
//        self.button.layer.borderWidth = 0.5
//        self.button.layer.borderColor = UIColor.yellowColor().CGColor
        self.button.opaque = true
        self.button.addTarget(self, action: "onBoardCellTapped:", forControlEvents: .TouchUpInside)
        
        self.addSubview(self.button)
        self.opaque = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.yellowColor().CGColor
        self.defaultSetup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.coord = CellCoord(indexOfColumn: 0, indexOfRow: 0)
        self.button = UIButton(frame: CGRectMake(0.0, 0.0, 0.0, 0.0))
        super.init(coder: aDecoder)
        self.opaque = true
    }
    
    func defaultSetup() {
        self.button.setBackgroundImage(nil, forState: .Normal)
    }
    
    
    func onBoardCellTapped(sender: UIButton) {
//        sender.backgroundColor = UIColor.greenColor()
        self.delegate?.onBoardCellTapped(self)
    }
   
    
    
    
}