//
//  Player.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import Foundation

enum PlayerStatus {
    case Won
    case WillWin
    case Uncertain
}

class Player {
    
    let name: String
    let index: Int
    weak var gameBoard: GameBoard?
    var lastCellCoord: CellCoord?
    var gridCellSeqs = [GridCellSeq]()
    var cellCoords = Set<CellCoord>()
    var winningCellSeq: GridCellSeq?
    
    init(name:String, index: Int) {
        self.name = name
        self.index = index
    }
    
    convenience init(name:String, index: Int, gameBoard: GameBoard) {
        self.init(name: name, index: index)
        self.gameBoard = gameBoard
    }
    
    var opponent: Player {
        get {
            return self.gameBoard!.players.filter{$0 !== self}.first!
        }
    }
    
    var availableNeighborCellCoords: Set<CellCoord> {
        get {
            var resultCoords = Set<CellCoord>()
            for coord in self.cellCoords {
                for neighborCoord in coord.allNeighborCoords {
                    if self.gameBoard![neighborCoord] == nil {
                        resultCoords.insert(neighborCoord)
                    }
                }
            }
            return resultCoords
        }
    }
    
    func findGridCellSeq(oritentation: GridCellSeqOrientation, coord: CellCoord) -> GridCellSeq? {
        let index = self.gridCellSeqs.indexOf{$0.orientation == oritentation && $0.seq.contains{$0.coord == coord}}
        if let index = index {
            return self.gridCellSeqs[index]
        } else {
            return nil
        }
    }
    
    func didPickGridCellAtCoord(coord: CellCoord) -> PlayerStatus {
        self.lastCellCoord = coord
//        self.removeUnWinnableSeqs()
        let gridCell = self.gameBoard![coord]!
        var countOfGridCellSeqsThatWillCompleteAfterAddingOneCell = 0
        for oritentation in GridCellSeqOrientation.allValues {
            let newSeq = self.buildSeq(gridCell, orientation: oritentation)
            if let newSeq = newSeq {
                switch newSeq.status {
                case .Uncompletable:
                    self.gridCellSeqs.removeAtIndex(self.gridCellSeqs.indexOf{$0 === newSeq}!)
                case .Completed:
                    self.winningCellSeq = newSeq
                    return .Won
                case .WillCompleteAfterAddingOneCell:
                    countOfGridCellSeqsThatWillCompleteAfterAddingOneCell += 1
                default:
                    break
                }
            }
        }
        if countOfGridCellSeqsThatWillCompleteAfterAddingOneCell >= 2 {
            return .WillWin
        } else {
            return .Uncertain
        }
    }
    
    func tryGridCellAtCoord(coord: CellCoord) -> Bool {
        if let _ = self.gameBoard!.grid[coord] {
            return false
        }
        self.gameBoard!.grid[coord] = GridCell(coord: coord, player: self)
        let lastCellCoordBackUp = self.lastCellCoord
        var gridCellSeqsBackUp = [GridCellSeq]()
        self.removeUncompletableSeqs()
        for gridCellSeq in self.gridCellSeqs {
            gridCellSeqsBackUp.append(gridCellSeq.copy())
        }
        var result: Bool
        switch self.didPickGridCellAtCoord(coord) {
        case .Won, .WillWin:
            result = true
        default:
            result = false
        }
        self.gridCellSeqs = gridCellSeqsBackUp
        self.lastCellCoord = lastCellCoordBackUp
        self.gameBoard!.grid[coord] = nil
        return result
    }
    
    func tryCellCoordsAround(coord: CellCoord, offset: Int) -> CellCoord? {
        let cellCoords = coord.getNeighborCoords(offset)
        for cellCoord in cellCoords {
            if self.tryGridCellAtCoord(cellCoord) {
                return cellCoord
            }
        }
        return nil
    }
    
    func tryNeighborCellCoords() -> CellCoord? {
        for cellCoord in self.availableNeighborCellCoords {
            if self.tryGridCellAtCoord(cellCoord) {
                return cellCoord
            }
        }
        return nil
    }
    
    func removeUncompletableSeqs() {
        for gridCellSeq in self.gridCellSeqs {
            if gridCellSeq.status == GridCellSeqStatus.Uncompletable {
                self.gridCellSeqs.removeAtIndex(self.gridCellSeqs.indexOf{$0 === gridCellSeq}!)
            }
        }
    }
    
    
    func buildSeq(gridCell: GridCell, orientation: GridCellSeqOrientation) -> GridCellSeq? {
        
        var newSeq = GridCellSeq(seq: [], gameBoard: self.gameBoard!)
        let neighborCoords = gridCell.coord.neighborCoords[orientation]!
        let lowerNeighborCoord = neighborCoords[0]
        let upperNeighborCoord = neighborCoords[1]
        
        if let lowerNeighbor = self.gameBoard![lowerNeighborCoord] {
            if lowerNeighbor.player === self {
                let lowerNeighborSeq = self.findGridCellSeq(orientation, coord: lowerNeighborCoord)
                if let lowerNeighborSeq = lowerNeighborSeq {
                    lowerNeighborSeq.seq.append(gridCell)
                    newSeq = lowerNeighborSeq
                } else {
                    newSeq.seq = [lowerNeighbor, gridCell]
                    self.gridCellSeqs.append(newSeq)
                }
            }
        }
        
        if let upperNeighbor = self.gameBoard![upperNeighborCoord] {
            if upperNeighbor.player === self {
                let upperNeighborSeq = self.findGridCellSeq(orientation, coord: upperNeighborCoord)
                if let upperNeighborSeq = upperNeighborSeq {
                    if newSeq.seq.isEmpty == false {
                        upperNeighborSeq.connectWithSeq(newSeq)
                        self.gridCellSeqs.removeAtIndex(self.gridCellSeqs.indexOf{$0 === newSeq}!)
                    } else {
                        upperNeighborSeq.seq.insert(gridCell, atIndex: 0)
                    }
                    newSeq = upperNeighborSeq
                } else {
                    if newSeq.seq.isEmpty == false {
                        newSeq.seq.append(upperNeighbor)
                    } else {
                        newSeq.seq = [gridCell, upperNeighbor]
                        self.gridCellSeqs.append(newSeq)
                    }
                }
            }
        }
        
        if newSeq.seq.isEmpty == false {
            return newSeq
        } else {
            return nil
        }
    }
    
    func reset() {
        self.lastCellCoord = nil
        self.gridCellSeqs = []
        self.cellCoords = []
        self.winningCellSeq = nil
    }
}