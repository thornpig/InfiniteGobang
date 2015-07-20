//
//  BoardCell.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit

let kDefaultBoardCellSize: CGFloat = 50.0
let kCellBackgroundColor = UIColor.lightGrayColor()
let kCellBackgroundColorHighlight = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 255.0/255.0, alpha: 1.0)
//let kCellBackgroundColorWinning = UIColor(red: 210.0/255.0, green: 180.0/255.0, blue: 140.0/255.0, alpha: 1.0)
let kCellBorderColor = UIColor(red: 139.0/255.0, green: 135.0/255.0, blue: 76.0/255.0, alpha: 1.0)
let kCellBorderColorHighlight = UIColor(red: 71.0/255.0, green: 60.0/255.0, blue: 139.0/255.0, alpha: 1.0)
let kCellBackgroundColorWinning = kCellBackgroundColorHighlight

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
        self.button.backgroundColor = kCellBackgroundColor
//        self.button.layer.borderWidth = 0.5
//        self.button.layer.borderColor = UIColor.yellowColor().CGColor
        self.button.opaque = true
        self.button.addTarget(self, action: "onBoardCellTapped:", forControlEvents: .TouchUpInside)
        
        self.addSubview(self.button)
        self.opaque = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = kCellBorderColor.CGColor
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