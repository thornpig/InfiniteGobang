//
//  Computer.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import Foundation

let kOffsetForTryingCells = kCountOfSeqToWin - 1

class Computer: Player {
    
    var opponent: Player {
        get {
            return self.gameBoard!.players.filter{$0 !== self}.first!
        }
    }
   
    var cellCoordToPick: CellCoord {
        get {
            
            var winningCellCoord : CellCoord?
            for gridCellSeq in self.gridCellSeqs {
                if gridCellSeq.winningCoordsDict.count > 0 {
                    for (coord, numOfCells) in gridCellSeq.winningCoordsDict {
                        if numOfCells == kCountOfSeqToWin {
                           return coord
                        } else {
                           winningCellCoord = coord
                        }
                    }
                }
            }
            
            var winningCellCoordOfOpponent : CellCoord?
            for gridCellSeq in self.opponent.gridCellSeqs {
                if gridCellSeq.winningCoordsDict.count > 0 {
                    for (coord, numOfCells) in gridCellSeq.winningCoordsDict {
                        if numOfCells == kCountOfSeqToWin {
                           return coord
                        } else {
                           winningCellCoordOfOpponent = coord
                        }
                    }
                }
            }
            
            if let coord = winningCellCoord {
                return coord
            } else if let coord = winningCellCoordOfOpponent {
                return coord
            }
            
            if let lastCellCoord = self.lastCellCoord {
                if let winningCoord = self.tryCellCoordsAround(lastCellCoord, offset: kOffsetForTryingCells) {
                    return winningCoord
                }
            }
            

            if let opponentLastCellCoord = self.opponent.lastCellCoord {
                if let opponenetWinningCoord = self.opponent.tryCellCoordsAround(opponentLastCellCoord, offset: kOffsetForTryingCells) {
                    return opponenetWinningCoord
                }
            }
            
            if self.gridCellSeqs.count > 0 {
                var seqToHandle = self.gridCellSeqs[0]
                for gridCellSeq in self.gridCellSeqs {
                    if gridCellSeq.effectiveCount > seqToHandle.effectiveCount {
                        seqToHandle = gridCellSeq
                    }
                }
                let neighborCoords = seqToHandle.neighborCoords
                return neighborCoords[neighborCoords.indexOf{self.gameBoard![$0] == nil}!]
            }
            
            if self.opponent.gridCellSeqs.count > 0 {
                var seqOfOpponentToHandle = self.opponent.gridCellSeqs[0]
                for gridCellSeq in self.opponent.gridCellSeqs {
                    if gridCellSeq.effectiveCount > seqOfOpponentToHandle.effectiveCount {
                        seqOfOpponentToHandle = gridCellSeq
                    }
                }
                let neighborCoords = seqOfOpponentToHandle.neighborCoords
                return neighborCoords[neighborCoords.indexOf{self.gameBoard![$0] == nil}!]
            }
            
            var leftMostColumn = 0
            for (coord, gridCell) in self.gameBoard!.grid {
                for neighborCoord in gridCell.coord.allNeighborCoords {
                    if self.gameBoard![neighborCoord] == nil {
                        return neighborCoord
                    }
                }
                if coord.indexOfColumn < leftMostColumn {
                    leftMostColumn = coord.indexOfColumn
                }
            }
            
            return CellCoord(indexOfColumn: leftMostColumn - 1, indexOfRow: 0)
            
        }
    }
    
    
}