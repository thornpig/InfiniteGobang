//
//  GridCellSeq.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import Foundation

enum GridCellSeqOrientation: Int {
    case horizontal = 999999
    case vertical = 0
    case diagonalLeft = 1
    case diagonalRight = -1
    static let allValues = [horizontal, vertical, diagonalLeft, diagonalRight]
}

enum GridCellSeqBound {
    case lower
    case upper
    static let allValues = [lower, upper]
}

enum GridCellSeqStatus {
    case completed
    case completeAfterAddingOneCell
    case willComplete
    case willCompleteAfterAddingOneCell
    case completable
    case uncompletable
}



class GridCellSeq {
    var seq: [GridCell]

    weak var gameBoard: GameBoard?
    
    init(seq: [GridCell]) {
        self.seq = seq.sorted{$0.coord < $1.coord}
    }
    
    convenience init(seq: [GridCell] , gameBoard: GameBoard) {
        self.init(seq: seq)
        self.seq = seq.sorted{$0.coord < $1.coord}
        self.gameBoard = gameBoard
    }
    
    var orientation: GridCellSeqOrientation {
        get {
            switch (self.seq[0].coord.indexOfColumn, self.seq[0].coord.indexOfRow, self.seq[1].coord.indexOfColumn, self.seq[1].coord.indexOfRow) {
            case let (x0, _, x1, _) where x0 == x1:
                return .vertical
            case let (x0, y0, x1, y1) where (y0 - y1) / (x0 - x1) == GridCellSeqOrientation.diagonalLeft.rawValue:
                return .diagonalLeft
            case let (x0, y0, x1, y1) where (y0 - y1) / (x0 - x1) == GridCellSeqOrientation.diagonalRight.rawValue:
                return .diagonalRight
            default :
                return .horizontal
            }
        }
    }
    
    var cellCoords: [CellCoord] {
        get {
            var coords = [CellCoord]()
            for gridCell in self.seq {
                coords.append(gridCell.coord)
            }
            return coords
        }
    }
    
    
    var neighborCoords: [CellCoord] {
        get {
           var coords = [CellCoord]()
           coords.append(self.seq.first!.coord.getNeighborCoords(1, orientation: self.orientation, bound: .lower).first!)
           coords.append(self.seq.last!.coord.getNeighborCoords(1, orientation: self.orientation, bound: .upper).first!)
           return coords
        }
    }
    
    var neighbors: [GridCell?] {
        get {
            return [self.gameBoard![self.neighborCoords.first!], self.gameBoard![self.neighborCoords.last!]]
        }
    }

    var endsBlocked: [Bool] {
        get {
            return [neighbors.first! != nil && neighbors.first!!.player !== self.seq[0].player,
                    neighbors.last! != nil && neighbors.last!!.player !== self.seq[0].player]
        }
    }
    
    var numOfCellsNeededToWin: Int {
        get {
            return kCountOfSeqToWin - self.seq.count
        }
    }
    
    var winningCoordsDict: [CellCoord: Int] {
        get {
            
            var coordsDict = [CellCoord: Int]()
            
            let lowerNeighborCoords = self.seq.first!.coord.getNeighborCoords(3, orientation: self.orientation, bound: .lower)
            let upperNeighborCoords = self.seq.last!.coord.getNeighborCoords(3, orientation: self.orientation, bound: .upper)
            let lowerNeighbors = self.gameBoard![lowerNeighborCoords]
            let upperNeighbors = self.gameBoard![upperNeighborCoords]
            
            if self.seq.count == kCountOfSeqToWin - 3 && self.endsBlocked == [false, false] {

                if lowerNeighbors[0] == nil && lowerNeighbors[1] != nil && lowerNeighbors[1]!.player === self.seq[0].player {
                    if lowerNeighbors[2] == nil {
                        coordsDict[lowerNeighborCoords[0]] = kCountOfSeqToWin - 1
                    } else if lowerNeighbors[2]!.player === self.seq[0].player {
                        coordsDict[lowerNeighborCoords[0]] = kCountOfSeqToWin
                    }
                }
                if upperNeighbors[0] == nil && upperNeighbors[1] != nil && upperNeighbors[1]!.player === self.seq[0].player {
                    if upperNeighbors[2] == nil {
                        coordsDict[upperNeighborCoords[0]] = kCountOfSeqToWin - 1
                    } else if upperNeighbors[2]!.player === self.seq[0].player {
                        coordsDict[upperNeighborCoords[0]] = kCountOfSeqToWin
                    }
                }
                
            } else if self.seq.count == kCountOfSeqToWin - 2 {
                if self.endsBlocked == [false, false]{
                    if lowerNeighbors[1] == nil {
                        coordsDict[lowerNeighborCoords[0]] = kCountOfSeqToWin - 1
                    } else if lowerNeighbors[1]!.player === self.seq[0].player {
                        coordsDict[lowerNeighborCoords[0]] = kCountOfSeqToWin
                    }
                    if upperNeighbors[1] == nil {
                        coordsDict[upperNeighborCoords[0]] = kCountOfSeqToWin - 1
                    } else if upperNeighbors[1]!.player === self.seq[0].player {
                        coordsDict[upperNeighborCoords[0]] = kCountOfSeqToWin
                    }
                } else if self.endsBlocked == [false, true] {
                    if lowerNeighbors[1] != nil && lowerNeighbors[1]!.player === self.seq[0].player {
                        coordsDict[lowerNeighborCoords[0]] = kCountOfSeqToWin
                    }
                } else if self.endsBlocked == [true, false] {
                    if upperNeighbors[1] != nil && upperNeighbors[1]!.player === self.seq[0].player {
                        coordsDict[upperNeighborCoords[0]] = kCountOfSeqToWin
                    }
                }
            } else if self.seq.count == kCountOfSeqToWin - 1 {
                if lowerNeighbors[0] == nil {
                    coordsDict[lowerNeighborCoords[0]] = kCountOfSeqToWin
                }
                if upperNeighbors[0] == nil {
                    coordsDict[upperNeighborCoords[0]] = kCountOfSeqToWin
                }
            }
            return coordsDict
        }
    }
    
    
    var effectiveCount: Int {
        if self.isCompletable == false {
            return 0
        }
        return self.seq.count - self.endsBlocked.filter{$0 == true}.count + 1
    }
    
    
    var status: GridCellSeqStatus {
        get {
            
            if self.seq.count >= kCountOfSeqToWin  {
                return .completed
            } else if self.effectiveCount == kCountOfSeqToWin {
                return .willComplete
            } else if self.winningCoordsDict.count > 0 {
//                for (_, numOfCells) in self.winningCoordsDict {
//                    if numOfCells == kCountOfSeqToWin {
//                        return .CompleteAfterAddingOneCell
//                    }
//                }
                return .willCompleteAfterAddingOneCell
            } else if self.isCompletable == true {
                return .completable
            } else {
                return .uncompletable
            }
        }
    }
    
    
    var isCompletable: Bool  {
        get {
            if self.numOfCellsNeededToWin > 0 && self.endsBlocked == [true, true] {
                return false
            }
            
            OuterLoop: for i in 0...self.numOfCellsNeededToWin {
                
                let numOfLowerNeighbors = i
                if numOfLowerNeighbors > 0 {
                    let lowerNeighborCoords = self.seq.first!.coord.getNeighborCoords(numOfLowerNeighbors, orientation: self.orientation, bound: .lower)
                    for coord in lowerNeighborCoords {
                        if let gridCell = self.gameBoard![coord] {
                            if gridCell.player !== self.seq.first!.player {
                                continue OuterLoop
                            }
                        }
                    }
                }
                
                let numOfUpperNeighbors = numOfCellsNeededToWin - numOfLowerNeighbors
                if numOfUpperNeighbors > 0 {
                    let upperNeighborCoords = self.seq.last!.coord.getNeighborCoords(numOfUpperNeighbors, orientation: self.orientation, bound: .upper)
                    for coord in upperNeighborCoords {
                        if let gridCell = self.gameBoard![coord] {
                            if gridCell.player !== self.seq.first!.player {
                                continue OuterLoop
                            }
                        }
                    }
                }
                return true
            }
            
            return false
        }
    }
    
    
    func connectWithSeq(_ aGridCellSeq: GridCellSeq) {
        for gridCell in aGridCellSeq.seq {
            self.seq.append(gridCell)
        }
        self.seq = self.seq.sorted{$0.coord < $1.coord}
    }
    
    func copy() -> GridCellSeq {
        let copyOfGridCellSeq = GridCellSeq(seq: [])
        for gridCell in self.seq {
            copyOfGridCellSeq.seq.append(gridCell)
        }
        copyOfGridCellSeq.gameBoard = self.gameBoard
        return copyOfGridCellSeq
    }
    
}
