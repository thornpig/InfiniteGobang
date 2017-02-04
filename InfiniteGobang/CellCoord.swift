//
//  CellCoord.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import Foundation



struct CellCoord: Hashable {
    
    var indexOfColumn: Int
    var indexOfRow: Int
    
    var hashValue: Int {
        return self.indexOfColumn.hashValue ^ self.indexOfRow.hashValue
    }
    
    var neighborCoords: [GridCellSeqOrientation: [CellCoord]] {
        get {
            let horizontalNeighborCoords = [self + CellCoord(indexOfColumn: -1, indexOfRow: 0),
                                            self + CellCoord(indexOfColumn: 1, indexOfRow: 0)]
            let verticalNeighborCoords = [self + CellCoord(indexOfColumn: 0, indexOfRow: -1),
                                            self + CellCoord(indexOfColumn: 0, indexOfRow: 1)]
            let diagonalLeftNeighborCoords = [self + CellCoord(indexOfColumn: -1, indexOfRow: -1),
                                            self + CellCoord(indexOfColumn: 1, indexOfRow: 1)]
            let diagonalRightNeighborCoords = [self + CellCoord(indexOfColumn: 1, indexOfRow: -1),
                                            self + CellCoord(indexOfColumn: -1, indexOfRow: 1)]
            
            return [.horizontal: horizontalNeighborCoords,
                    .vertical: verticalNeighborCoords,
                    .diagonalLeft: diagonalLeftNeighborCoords,
                    .diagonalRight: diagonalRightNeighborCoords]
        }
    }
    
    var allNeighborCoords: [CellCoord] {
        get {
            var coords = [CellCoord]()
            for orientation in GridCellSeqOrientation.allValues {
                coords.append((self.neighborCoords[orientation]!)[0])
                coords.append((self.neighborCoords[orientation]!)[1])
            }
            return coords
        }
    }
    
    func getNeighborCoords(_ offset: Int, orientation: GridCellSeqOrientation, bound: GridCellSeqBound) -> [CellCoord] {
        var refCoord = self
        var neighborCoords = [CellCoord]()

        switch bound {
        case .lower:
            for _ in 0...offset - 1 {
                switch orientation {
                case .horizontal:
                    neighborCoords.append(refCoord + CellCoord(indexOfColumn: -1, indexOfRow: 0))
                default:
                    neighborCoords.append(refCoord + CellCoord(indexOfColumn: -1 * orientation.rawValue, indexOfRow: -1))
                }
                refCoord = neighborCoords.last!
            }
        default:
            for _ in 0...offset - 1 {
                switch orientation {
                case .horizontal:
                    neighborCoords.append(refCoord + CellCoord(indexOfColumn: 1, indexOfRow: 0))
                default:
                    neighborCoords.append(refCoord + CellCoord(indexOfColumn: orientation.rawValue, indexOfRow: 1))
                }
                refCoord = neighborCoords.last!
            }
        }
        
        return neighborCoords
    }
    
    func getNeighborCoords(_ offset: Int) -> [CellCoord] {
        var neighborCoords = [CellCoord]()
        for bound in GridCellSeqBound.allValues {
            for orientation in GridCellSeqOrientation.allValues {
               neighborCoords = neighborCoords + self.getNeighborCoords(offset, orientation: orientation, bound: bound)
            }
        }
        return neighborCoords
    }
    
}

func ==(lhs: CellCoord, rhs: CellCoord) -> Bool {
    return lhs.indexOfColumn == rhs.indexOfColumn && lhs.indexOfRow == rhs.indexOfRow
}

func >(lhs: CellCoord, rhs: CellCoord) -> Bool {
    return lhs.indexOfRow == rhs.indexOfRow ? lhs.indexOfColumn > rhs.indexOfColumn : lhs.indexOfRow > rhs.indexOfRow
}

func <(lhs: CellCoord, rhs: CellCoord) -> Bool {
    return lhs.indexOfRow == rhs.indexOfRow ? lhs.indexOfColumn < rhs.indexOfColumn : lhs.indexOfRow < rhs.indexOfRow
}

func +(lhs: CellCoord, rhs: CellCoord) -> CellCoord {
    return CellCoord(indexOfColumn: lhs.indexOfColumn + rhs.indexOfColumn, indexOfRow: lhs.indexOfRow + rhs.indexOfRow)
}
