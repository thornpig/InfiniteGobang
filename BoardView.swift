//
//  BoardView.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit

enum Border {
    case left
    case right
    case top
    case bottom
}

protocol BoardViewDataSource: class {
    func setupBoardViewCell(_ boardView: BoardView, boardCell: BoardCell)
}

final class BoardView: UIScrollView {
    
    var cells: [[BoardCell]]
    var reusableCells: [BoardCell]
    weak var dataSource: BoardViewDataSource? {
        willSet(newDataSource) {
            if let newDataSource = newDataSource {
                for i in 0...numOfColumns - 1 {
                    for j in 0...numOfRows - 1  {
                        self.cells[i][j].delegate = newDataSource as? BoardCellDelegate
                    }
                }
            }
        }
    }
    
    var numOfColumns: Int {
        get {
            return self.cells.count
        }
    }
    
    var numOfRows: Int {
        get {
            return (self.cells[0]).count
        }
    }
    
    var cellSize: CGSize {
        get {
            return self.cells[0][0].frame.size
        }
    }
    
    var indicesOfColumnsForCells: [Int] {
        get {
            return self.cells.map { (aColumnOfBoardCells: [BoardCell]) in
                return aColumnOfBoardCells[0].coord.indexOfColumn
            }
        }
    }
    
    var indicesOfRowsForCells: [Int] {
        get {
            return self.cells[0].map { (boardCell: BoardCell) in
                return boardCell.coord.indexOfRow
            }
        }
    }
    
    var contentOffsetBase: CGPoint {
        get {
            return  self.cells[0][0].frame.origin
        }
    }
    
    override init(frame: CGRect) {
        
        self.reusableCells = [BoardCell]()
        let numOfColumns = Int(ceil(frame.size.width / kDefaultBoardCellSize))
        let numOfRows = Int(ceil(frame.size.height / kDefaultBoardCellSize))

        self.cells = [[BoardCell]](repeating: [BoardCell](repeating: BoardCell(indexOfColumn: 0, indexOfRow: 0, frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)), count: numOfRows), count: numOfColumns)
        
        super.init(frame: frame)
        self.contentSize = CGSize(width: self.bounds.size.width * 2.0, height: self.bounds.size.height * 2.0)
        self.bounds.origin = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        self.backgroundColor = kCellBackgroundColor
        
// the two options below cause frame drop of 5 fps
//        self.decelerationRate = UIScrollViewDecelerationRateFast
//        self.bounces = false
        
        let localIndexOfCenterColumn = Int(numOfColumns / 2)
        let localIndexOfCenterRow = Int(numOfRows / 2)
        
        for i in 0...numOfColumns - 1 {
            for j in 0...numOfRows - 1  {
                let indexOfColumn = i - localIndexOfCenterColumn
                let indexOfRow = j - localIndexOfCenterRow
                let cellFrame = CGRect(x: self.bounds.origin.x + CGFloat(i) * kDefaultBoardCellSize, y: self.bounds.origin.y + CGFloat(numOfRows - 1 - j) * kDefaultBoardCellSize, width: kDefaultBoardCellSize, height: kDefaultBoardCellSize)
                self.cells[i][j] = BoardCell(indexOfColumn: indexOfColumn, indexOfRow: indexOfRow, frame: cellFrame)

                self.addSubview(self.cells[i][j])
            }
        }
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        self.cells = [[BoardCell]]()
        self.reusableCells = [BoardCell]()
        super.init(coder: aDecoder)
    }
    
    subscript(cellCoord: CellCoord) -> BoardCell? {
        
        for i in 0...numOfColumns - 1 {
            for j in 0...numOfRows - 1  {
                if self.cells[i][j].coord == cellCoord {
                    return self.cells[i][j]
                }
            }
        }
        return nil
    }
    
    
    func cellForPoint(_ point: CGPoint) -> BoardCell {
        let i = Int((point.x - self.cells[0][0].frame.origin.x) / self.cells[0][0].frame.size.width)
        let j = Int((point.y - self.cells[0][0].frame.origin.y) / self.cells[0][0].frame.size.height)
        return self.cells[i][j]
    }
    
    func moveCellsBy(dX: CGFloat, dY: CGFloat) {
        for aRowOfBoardCells in self.cells {
            for boardCell in aRowOfBoardCells {
                boardCell.frame.origin.x += dX
                boardCell.frame.origin.y += dY
            }
        }
    }
    
    func getResuableCell() -> BoardCell? {
        var cellToReturn : BoardCell? = nil
        if self.reusableCells.count > 0 {
            cellToReturn = self.reusableCells[0]
            self.reusableCells.remove(at: 0)
        }
        return cellToReturn
    }
    
    func addColumnOfCellsAt(localIndexOfColumn: Int) {
        let xOfColumnToAdd: CGFloat
        let indexOfColumn: Int
        switch localIndexOfColumn {
        case 0 :
            xOfColumnToAdd = self.cells[0][0].frame.origin.x - self.cellSize.width
            indexOfColumn = self.cells[0][0].coord.indexOfColumn - 1
        case 1...self.numOfColumns :
            xOfColumnToAdd = self.cells[localIndexOfColumn - 1][0].frame.origin.x + self.cellSize.width
            indexOfColumn = self.cells[localIndexOfColumn - 1][0].coord.indexOfColumn + 1
        default :
            assertionFailure("localIndexOfColumn for cells to add is out of range.")
            xOfColumnToAdd = 0.0
            indexOfColumn = 0
        }
        var cellsToAdd = [BoardCell]()
        for (i,indexOfRow) in self.indicesOfRowsForCells.enumerated() {
            let boardCellToAdd : BoardCell
            let frameOfCellToAdd = CGRect(x: xOfColumnToAdd, y: self.cells[0][i].frame.origin.y, width: self.cellSize.width, height: self.cellSize.height)
            if let boardCell = self.getResuableCell() {
//                println("get reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
                boardCell.frame = frameOfCellToAdd
                boardCell.coord.indexOfColumn = indexOfColumn
                boardCell.coord.indexOfRow = indexOfRow
//                boardCell.button.setTitle("\(boardCell.coord.indexOfColumn),\(boardCell.coord.indexOfRow)", forState: .Normal)
                boardCell.button.backgroundColor = kCellBackgroundColor
                boardCell.button.isUserInteractionEnabled = true
                boardCellToAdd = boardCell
//                println("put reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
            } else {
                boardCellToAdd = BoardCell(indexOfColumn: indexOfColumn, indexOfRow: indexOfRow, frame:     frameOfCellToAdd)
                self.addSubview(boardCellToAdd)
            }
            cellsToAdd.append(boardCellToAdd)
            self.dataSource!.setupBoardViewCell(self, boardCell:boardCellToAdd)
//            self.addSubview(boardCellToAdd)
        }
        self.cells.insert(cellsToAdd, at: localIndexOfColumn)
    }
    
    func removeColumnOfCellsAt(localIndexOfColumn: Int) {
        for boardCell in self.cells[localIndexOfColumn] {
            boardCell.defaultSetup()
            self.reusableCells.append(boardCell)
//            boardCell.removeFromSuperview()
        }
        self.cells.remove(at: localIndexOfColumn)

    }
    
    func removeColumnsOfCellsOutsideOfBounds() {
        var numOfColumnsRemoved = 0
        for i in 0 ..< self.numOfColumns {
            let indexOfColumn = i - numOfColumnsRemoved
            let firstCell = self.cells[indexOfColumn][0]
            if firstCell.frame.origin.x >= self.bounds.origin.x + self.bounds.size.width || firstCell.frame.origin.x + firstCell.frame.size.width <= self.bounds.origin.x {
                self.removeColumnOfCellsAt(localIndexOfColumn: indexOfColumn)
                numOfColumnsRemoved += 1
//                println("remove column at \(i)")
            }
        }
    }
    

    
    func addRowOfCellsAt(localIndexOfRow: Int) {
        let yOfRowToAdd: CGFloat
        let indexOfRow: Int
        switch localIndexOfRow {
        case 0 :
            yOfRowToAdd = self.cells[0][0].frame.origin.y + self.cellSize.height
            indexOfRow = self.cells[0][0].coord.indexOfRow - 1
        case 1...self.numOfRows :
            yOfRowToAdd = self.cells[0][self.numOfRows - 1].frame.origin.y - self.cellSize.height
            indexOfRow = self.cells[0][self.numOfRows - 1].coord.indexOfRow + 1
        default :
            assertionFailure("localIndexOfColumn for cells to add is out of range.")
            yOfRowToAdd = 0.0
            indexOfRow = 0
        }
        
       self.cells = self.cells.map { (aColumnOfCells : [BoardCell]) -> [BoardCell] in
            let boardCellToAdd : BoardCell
            let frameOfCellToAdd = CGRect(x: aColumnOfCells[0].frame.origin.x , y: yOfRowToAdd, width: self.cellSize.width, height: self.cellSize.height)
            if let boardCell = self.getResuableCell() {
//                println("get reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
                boardCell.frame = frameOfCellToAdd
                boardCell.coord.indexOfColumn = aColumnOfCells[0].coord.indexOfColumn
                boardCell.coord.indexOfRow = indexOfRow
//                boardCell.button.setTitle("\(boardCell.coord.indexOfColumn),\(boardCell.coord.indexOfRow)", forState: .Normal)
                boardCell.button.backgroundColor = kCellBackgroundColor
                boardCell.button.isUserInteractionEnabled = true
                boardCellToAdd = boardCell
//                println("put reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
            } else {
                boardCellToAdd = BoardCell(indexOfColumn: aColumnOfCells[0].coord.indexOfColumn , indexOfRow: indexOfRow, frame: frameOfCellToAdd)
                self.addSubview(boardCellToAdd)
            }
//            self.addSubview(boardCellToAdd)
            var aColumnOfCellsToReturn = aColumnOfCells
            aColumnOfCellsToReturn.insert(boardCellToAdd, at: localIndexOfRow)
            self.dataSource!.setupBoardViewCell(self, boardCell:boardCellToAdd)
            return aColumnOfCellsToReturn
        }
    }
    
    func removeRowOfCellsAt(localIndexOfRow: Int) {
        self.cells = self.cells.map { (aColumnOfCells: [BoardCell]) -> [BoardCell] in
            aColumnOfCells[localIndexOfRow].defaultSetup()
            self.reusableCells.append(aColumnOfCells[localIndexOfRow])
//            aColumnOfCells[localIndexOfRow].removeFromSuperview()
            var aColumnOfCellsToReturn = aColumnOfCells
            aColumnOfCellsToReturn.remove(at: localIndexOfRow)
            return aColumnOfCellsToReturn
        }
    }
    
    func removeRowsOfCellsOutsideOfBounds() {
        var numOfRowsRemoved = 0
        for i in 0 ..< self.numOfRows {
            print("at \(i) with numOfRows \(self.numOfRows)")
            let indexOfRow = i - numOfRowsRemoved
            let firstCell = self.cells[0][indexOfRow]
            if firstCell.frame.origin.y >= self.bounds.origin.y + self.bounds.size.height || firstCell.frame.origin.y + firstCell.frame.size.height <= self.bounds.origin.y {
                self.removeRowOfCellsAt(localIndexOfRow: indexOfRow)
                numOfRowsRemoved += 1
                print("remove row at \(i)")
            }
        }
    }
    
    func manageCellsAfterScroll() {
        let startTime = CFAbsoluteTimeGetCurrent()
        self.removeColumnsOfCellsOutsideOfBounds()
        self.removeRowsOfCellsOutsideOfBounds()

        if self.contentOffset.x <= self.cells[0][0].frame.origin.x {
            self.addColumnOfCellsAt(localIndexOfColumn: 0)
        }
        
        if self.contentOffset.x + self.bounds.size.width >= self.cells[self.numOfColumns - 1][0].frame.origin.x + self.cellSize.width {
           self.addColumnOfCellsAt(localIndexOfColumn: self.numOfColumns)
        }
        
        if self.contentOffset.y <= self.cells[0][self.numOfRows - 1].frame.origin.y {
            self.addRowOfCellsAt(localIndexOfRow: self.numOfRows)
        }
        
        if self.contentOffset.y + self.bounds.size.height >= self.cells[0][0].frame.origin.y + self.cellSize.height {
           self.addRowOfCellsAt(localIndexOfRow: 0)
        }
        
        print("\((CFAbsoluteTimeGetCurrent() - startTime) * 1000.0)")
    }
    
    func setupContentInsets() {
        let bufferSize = CGSize(width: self.cellSize.width * 2.0, height: self.cellSize.height * 2.0)
        if self.contentOffset.x <= bufferSize.width {
            self.contentInset.left += bufferSize.width
        }
        if self.contentOffset.x + self.bounds.size.width >= self.contentSize.width - bufferSize.width {
            self.contentInset.right += bufferSize.width
        }
        if self.contentOffset.y <= bufferSize.height {
            self.contentInset.top += bufferSize.height
        }
        if self.contentOffset.y + self.bounds.size.height >= self.contentSize.height - bufferSize.height {
            self.contentInset.bottom += bufferSize.height
        }
    }
    
    func scrollToShowCellCoordAtCenter(_ coord: CellCoord, completion: (() -> Void)? ) {
//    func scrollToShowCellCoordAtCenter(coord: CellCoord) {
        let centerCell = self.cells[self.numOfColumns / 2][self.numOfRows / 2]
        let deltaX = (CGFloat)(coord.indexOfColumn - centerCell.coord.indexOfColumn ) * centerCell.frame.size.width
        let deltaY = (CGFloat)(centerCell.coord.indexOfRow - coord.indexOfRow ) * centerCell.frame.size.height
        let offsetX = deltaX + self.bounds.origin.x
        let offsetY = deltaY + self.bounds.origin.y
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: true)
        CATransaction.commit()
        
        //Customized animation dosen't look right, don't understand why
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.contentOffset = CGPointMake(offsetX, offsetY)
//            }) { _ in
//                completion?()
//        }
    }
    
    func getFrameForCellCoord(_ coord: CellCoord) -> CGRect {
        let firstCell = self.cells[0][0]
        let deltaX = (CGFloat)(coord.indexOfColumn - firstCell.coord.indexOfColumn ) * firstCell.frame.size.width
        let deltaY = (CGFloat)(firstCell.coord.indexOfRow - coord.indexOfRow ) * firstCell.frame.size.height
        return CGRect(x: firstCell.frame.origin.x + deltaX, y: firstCell.frame.origin.y + deltaY, width: firstCell.frame.size.width, height: firstCell.frame.size.height)
    }
    

}
