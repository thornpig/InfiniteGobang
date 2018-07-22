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
    
    var numOfRounds: Int = 1
    var players = [Player]()
    var winner: Player? = nil
    var grid: [CellCoord: GridCell]
    
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
    
    
    init() {
        grid = [:]
    }
    
    subscript(coord: CellCoord) -> GridCell? {
        return grid[coord]
    }
    
    subscript(coords: [CellCoord]) -> [GridCell?] {
        return coords.map{return grid[$0]}
    }
    
    func addCell(_ cell: GridCell) {
        self.grid[cell.coord] = cell
        cell.player.cellCoords.insert(cell.coord)
    }
    
    func removeCellAtCoord(_ coord: CellCoord) {
        if let gameCell = self.grid[coord] {
            gameCell.player.cellCoords.remove(coord)
            self.grid[coord] = nil
        }
    }
    
    func reset() {
        self.numOfRounds = 1
        self.winner = nil
        self.grid = [:]
        for player in self.players {
            player.reset()
        }
    }
}

