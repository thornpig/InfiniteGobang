//
//  GameBoard.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import Foundation

let kCountOfSeqToWin = 5

final class GameBoard {
    
    var players = [Player]()

    var numOfRounds: Int = 0
    var indexOfPlayer: Int {
        get {
           return (self.numOfRounds - 1) % 2
        }
    }
    var currentPlayer: Player {
        get {
            return self.players[self.indexOfPlayer]
        }
    }
    
    var grid: [CellCoord: GridCell]
    
    init() {
        grid = [:]
    }
    
    subscript(coord: CellCoord) -> GridCell? {
        return grid[coord]
    }
    
    subscript(coords: [CellCoord]) -> [GridCell?] {
        return coords.map{return grid[$0]}
    }
}

