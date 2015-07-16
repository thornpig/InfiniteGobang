//
//  BoardView.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import UIKit

enum Border {
    case Left
    case Right
    case Top
    case Bottom
}

protocol BoardViewDataSource: class {
    func setupBoardViewCell(boardView: BoardView, boardCell: BoardCell)
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

        self.cells = [[BoardCell]](count: numOfColumns, repeatedValue: [BoardCell](count: numOfRows, repeatedValue: BoardCell(indexOfColumn: 0, indexOfRow: 0, frame: CGRectMake(0.0, 0.0, 0.0, 0.0))))
        
        super.init(frame: frame)
        self.contentSize = CGSizeMake(self.bounds.size.width * 2.0, self.bounds.size.height * 2.0)
        self.bounds.origin = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)
        self.backgroundColor = UIColor.redColor()
        
// the two options below cause frame drop of 5 fps
//        self.decelerationRate = UIScrollViewDecelerationRateFast
//        self.bounces = false
        
        let localIndexOfCenterColumn = Int(numOfColumns / 2)
        let localIndexOfCenterRow = Int(numOfRows / 2)
        
        for i in 0...numOfColumns - 1 {
            for j in 0...numOfRows - 1  {
                let indexOfColumn = i - localIndexOfCenterColumn
                let indexOfRow = j - localIndexOfCenterRow
                let cellFrame = CGRectMake(self.bounds.origin.x + CGFloat(i) * kDefaultBoardCellSize, self.bounds.origin.y + CGFloat(numOfRows - 1 - j) * kDefaultBoardCellSize, kDefaultBoardCellSize, kDefaultBoardCellSize)
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
    
    
    func cellForPoint(point: CGPoint) -> BoardCell {
        let i = Int((point.x - self.cells[0][0].frame.origin.x) / self.cells[0][0].frame.size.width)
        let j = Int((point.y - self.cells[0][0].frame.origin.y) / self.cells[0][0].frame.size.height)
        return self.cells[i][j]
    }
    
    func moveCellsBy(dX dX: CGFloat, dY: CGFloat) {
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
            self.reusableCells.removeAtIndex(0)
        }
        return cellToReturn
    }
    
    func addColumnOfCellsAt(localIndexOfColumn localIndexOfColumn: Int) {
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
        for (i,indexOfRow) in self.indicesOfRowsForCells.enumerate() {
            let boardCellToAdd : BoardCell
            let frameOfCellToAdd = CGRectMake(xOfColumnToAdd, self.cells[0][i].frame.origin.y, self.cellSize.width, self.cellSize.height)
            if let boardCell = self.getResuableCell() {
//                println("get reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
                boardCell.frame = frameOfCellToAdd
                boardCell.coord.indexOfColumn = indexOfColumn
                boardCell.coord.indexOfRow = indexOfRow
//                boardCell.button.setTitle("\(boardCell.coord.indexOfColumn),\(boardCell.coord.indexOfRow)", forState: .Normal)
                boardCell.button.backgroundColor = UIColor.lightGrayColor()
                boardCell.button.userInteractionEnabled = true
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
        self.cells.insert(cellsToAdd, atIndex: localIndexOfColumn)
    }
    
    func removeColumnOfCellsAt(localIndexOfColumn localIndexOfColumn: Int) {
        for boardCell in self.cells[localIndexOfColumn] {
            boardCell.defaultSetup()
            self.reusableCells.append(boardCell)
//            boardCell.removeFromSuperview()
        }
        self.cells.removeAtIndex(localIndexOfColumn)

    }
    
    func removeColumnsOfCellsOutsideOfBounds() {
        for var i = 0; i < self.numOfColumns; ++i {
            let firstCell = self.cells[i][0]
            if firstCell.frame.origin.x >= self.bounds.origin.x + self.bounds.size.width || firstCell.frame.origin.x + firstCell.frame.size.width <= self.bounds.origin.x {
                self.removeColumnOfCellsAt(localIndexOfColumn: i)
//                println("remove column at \(i)")
            }
        }
    }
    

    
    func addRowOfCellsAt(localIndexOfRow localIndexOfRow: Int) {
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
        
       self.cells = self.cells.map { (var aColumnOfCells : [BoardCell]) -> [BoardCell] in
            let boardCellToAdd : BoardCell
            let frameOfCellToAdd = CGRectMake(aColumnOfCells[0].frame.origin.x , yOfRowToAdd, self.cellSize.width, self.cellSize.height)
            if let boardCell = self.getResuableCell() {
//                println("get reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
                boardCell.frame = frameOfCellToAdd
                boardCell.coord.indexOfColumn = aColumnOfCells[0].coord.indexOfColumn
                boardCell.coord.indexOfRow = indexOfRow
//                boardCell.button.setTitle("\(boardCell.coord.indexOfColumn),\(boardCell.coord.indexOfRow)", forState: .Normal)
                boardCell.button.backgroundColor = UIColor.lightGrayColor()
                boardCell.button.userInteractionEnabled = true
                boardCellToAdd = boardCell
//                println("put reusable cell at \(boardCell.indexOfColumn),\(boardCell.indexOfRow)")
            } else {
                boardCellToAdd = BoardCell(indexOfColumn: aColumnOfCells[0].coord.indexOfColumn , indexOfRow: indexOfRow, frame: frameOfCellToAdd)
                self.addSubview(boardCellToAdd)
            }
//            self.addSubview(boardCellToAdd)
            aColumnOfCells.insert(boardCellToAdd, atIndex: localIndexOfRow)
            self.dataSource!.setupBoardViewCell(self, boardCell:boardCellToAdd)
            return aColumnOfCells
        }
    }
    
    func removeRowOfCellsAt(localIndexOfRow localIndexOfRow: Int) {
        self.cells = self.cells.map { (var aColumnOfCells: [BoardCell]) -> [BoardCell] in
            aColumnOfCells[localIndexOfRow].defaultSetup()
            self.reusableCells.append(aColumnOfCells[localIndexOfRow])
//            aColumnOfCells[localIndexOfRow].removeFromSuperview()
            aColumnOfCells.removeAtIndex(localIndexOfRow)
            return aColumnOfCells
        }
    }
    
    func removeRowsOfCellsOutsideOfBounds() {
        for var i = 0; i < self.numOfRows; ++i {
            let firstCell = self.cells[0][i]
            if firstCell.frame.origin.y >= self.bounds.origin.y + self.bounds.size.height || firstCell.frame.origin.y + firstCell.frame.size.height <= self.bounds.origin.y {
                self.removeRowOfCellsAt(localIndexOfRow: i)
//                println("remove row at \(i)")
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
        let bufferSize = CGSizeMake(self.cellSize.width * 2.0, self.cellSize.height * 2.0)
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
    

}
