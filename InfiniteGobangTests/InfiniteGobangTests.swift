//
//  InfiniteGobangTests.swift
//  InfiniteGobangTests
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import XCTest
@testable import InfiniteGobang

class InfiniteGobangTests: XCTestCase {
    
    let cellCoord0 = CellCoord(indexOfColumn: 0, indexOfRow: 0)
    let cellCoord1 = CellCoord(indexOfColumn: 1, indexOfRow: 0)
    let cellCoord2 = CellCoord(indexOfColumn: 1, indexOfRow: 1)
    let cellCoord3 = CellCoord(indexOfColumn: 0, indexOfRow: 1)
    let cellCoord4 = CellCoord(indexOfColumn: -1, indexOfRow: 1)
    let cellCoord5 = CellCoord(indexOfColumn: -1, indexOfRow: 0)
    let cellCoord6 = CellCoord(indexOfColumn: -1, indexOfRow: -1)
    let cellCoord7 = CellCoord(indexOfColumn: 0, indexOfRow: -1)
    let cellCoord8 = CellCoord(indexOfColumn: 1, indexOfRow: -1)

    
    var cellCoordSet0: Set<CellCoord> = []
    var cellCoordSet1: Set<CellCoord> = []
    var cellCoordSet2: Set<CellCoord> = []
    var cellCoordSet3: Set<CellCoord> = []
    
    var cellCoordArraySorted0 = [CellCoord]()
    var cellCoordArraySorted1 = [CellCoord]()
    var cellCoordArraySorted2 = [CellCoord]()
    var cellCoordArraySorted3 = [CellCoord]()

    var masterCellCoordSet: Set<Set<CellCoord>> = []
    
    var gameBoard = GameBoard()
    let players = [Player(name: "player0", index: 0), Player(name: "player1", index: 1)]

    
    override func setUp() {
        super.setUp()
        cellCoordSet0 = [cellCoord0, cellCoord1, cellCoord5]
        cellCoordSet1 = [cellCoord0, cellCoord2, cellCoord6]
        cellCoordSet2 = [cellCoord0, cellCoord3, cellCoord7]
        cellCoordSet3 = [cellCoord0, cellCoord4, cellCoord8]
        
        cellCoordArraySorted0 = cellCoordSet0.sorted{$0 < $1}
        cellCoordArraySorted1 = cellCoordSet1.sorted{$0 < $1}
        cellCoordArraySorted2 = cellCoordSet2.sorted{$0 < $1}
        cellCoordArraySorted3 = cellCoordSet3.sorted{$0 < $1}
        
        masterCellCoordSet = [cellCoordSet0, cellCoordSet1, cellCoordSet2, cellCoordSet3]
        
        gameBoard.addCell(GridCell(coord: cellCoord0, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord1, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord2, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord3, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord4, player: players.last!))
        gameBoard.addCell(GridCell(coord: cellCoord5, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord6, player: players.last!))
        gameBoard.addCell(GridCell(coord: cellCoord7, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord8, player: players.last!))

   
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testCellCoordGreaterRelation() {
       
        XCTAssertEqual(cellCoord1 > cellCoord0, true)
        XCTAssertEqual(cellCoord2 > cellCoord0, true)
        XCTAssertEqual(cellCoord3 > cellCoord0, true)
        XCTAssertEqual(cellCoord4 > cellCoord0, true)
        XCTAssertEqual(cellCoord0 > cellCoord5, true)
        XCTAssertEqual(cellCoord0 > cellCoord6, true)
        XCTAssertEqual(cellCoord0 > cellCoord7, true)
        XCTAssertEqual(cellCoord0 > cellCoord8, true)
    }
    
    func testCellCoordSort() {
        
        XCTAssertEqual(cellCoordArraySorted0[0], cellCoord5)
        XCTAssertEqual(cellCoordArraySorted0[1], cellCoord0)
        XCTAssertEqual(cellCoordArraySorted0[2], cellCoord1)

        XCTAssertEqual(cellCoordArraySorted1[0], cellCoord6)
        XCTAssertEqual(cellCoordArraySorted1[1], cellCoord0)
        XCTAssertEqual(cellCoordArraySorted1[2], cellCoord2)
        
        XCTAssertEqual(cellCoordArraySorted2[0], cellCoord7)
        XCTAssertEqual(cellCoordArraySorted2[1], cellCoord0)
        XCTAssertEqual(cellCoordArraySorted2[2], cellCoord3)

        XCTAssertEqual(cellCoordArraySorted3[0], cellCoord8)
        XCTAssertEqual(cellCoordArraySorted3[1], cellCoord0)
        XCTAssertEqual(cellCoordArraySorted3[2], cellCoord4)
    }
    
    func testCellCoordAddition() {
        
        XCTAssertEqual(cellCoord2 + CellCoord(indexOfColumn: -1, indexOfRow: -1), cellCoord0)
        XCTAssertEqual(cellCoord4 + CellCoord(indexOfColumn: 0, indexOfRow: -1), cellCoord5)
    }
    
    func testGameBoardSubscripts() {
        XCTAssertEqual(gameBoard[cellCoord1]!.coord == cellCoord1, true)
        let gridCells = gameBoard[[cellCoord0, cellCoord1]]
        XCTAssertEqual(gridCells[0] === gameBoard[cellCoord0], true)
        XCTAssertEqual(gridCells[1] === gameBoard[cellCoord1], true)

        
    }
    
    func testCellNeighborCoords() {
        let neighborCoordsLower = gameBoard[cellCoord0]!.coord.getNeighborCoords(3, orientation: GridCellSeqOrientation.horizontal, bound: GridCellSeqBound.lower)
        let neighborCoordsUpper = gameBoard[cellCoord0]!.coord.getNeighborCoords(3, orientation: GridCellSeqOrientation.horizontal, bound: GridCellSeqBound.upper)
        XCTAssertEqual(neighborCoordsLower[0], cellCoord5)
        XCTAssertEqual(neighborCoordsLower[1], CellCoord(indexOfColumn: -2, indexOfRow: 0))
        XCTAssertEqual(neighborCoordsLower[2], CellCoord(indexOfColumn: -3, indexOfRow: 0))
        XCTAssertEqual(neighborCoordsUpper[0], cellCoord1)
        XCTAssertEqual(neighborCoordsUpper[1], CellCoord(indexOfColumn: 2, indexOfRow: 0))
        XCTAssertEqual(neighborCoordsUpper[2], CellCoord(indexOfColumn: 3, indexOfRow: 0))
    }
    
    func testCellNeighbors() {
       
        let gridCellSeq = GridCellSeq(seq: [gameBoard[cellCoord0]!, gameBoard[cellCoord2]!], gameBoard: gameBoard)
        let neighbors =  gridCellSeq.neighbors
        XCTAssertEqual(neighbors.first!!.coord, cellCoord6)
        XCTAssertEqual(neighbors.last! == nil, true)
    }
    
    func testCellCoordEndsBlocked() {
       
        let gridCellSeq = GridCellSeq(seq:[gameBoard[cellCoord5]!, gameBoard[cellCoord0]!], gameBoard: gameBoard)
        let endsBlocked =  gridCellSeq.endsBlocked
        XCTAssertEqual(endsBlocked.first!, false)
        XCTAssertEqual(endsBlocked.last!, false)
    }
    
    func testFindGridCellSeq() {
        let gridCellSeq0 = GridCellSeq(seq: [gameBoard[cellCoord0]!, gameBoard[cellCoord1]!], gameBoard: gameBoard)
        let gridCellSeq1 = GridCellSeq(seq: [gameBoard[cellCoord0]!, gameBoard[cellCoord5]!], gameBoard: gameBoard)
        players[0].gridCellSeqs = [gridCellSeq0, gridCellSeq1]
        XCTAssertEqual(players[0].findGridCellSeq(GridCellSeqOrientation.horizontal, coord: cellCoord1) === gridCellSeq0, true)
        XCTAssertEqual(players[0].findGridCellSeq(GridCellSeqOrientation.horizontal, coord: cellCoord5) === gridCellSeq1, true)
        XCTAssertEqual(players[0].findGridCellSeq(GridCellSeqOrientation.horizontal, coord: cellCoord3) == nil, true)
    }
    
    func testAddAndRemoveCell() {
        
        XCTAssertEqual(players.first!.cellCoords == [cellCoord1, cellCoord0, cellCoord2, cellCoord3, cellCoord5, cellCoord7], true)
        gameBoard.removeCellAtCoord(cellCoord2)
        XCTAssertEqual(players.first!.cellCoords == [cellCoord1, cellCoord0, cellCoord5, cellCoord3, cellCoord7], true)
        XCTAssertEqual(players.last!.cellCoords == [cellCoord4, cellCoord6, cellCoord8], true)
        gameBoard.removeCellAtCoord(cellCoord6)
        XCTAssertEqual(players.last!.cellCoords == [cellCoord4, cellCoord8], true)
    }
    
    func testGridCellSeqWinnable() {
        let cellCoord9 = CellCoord(indexOfColumn: -2, indexOfRow: 0)
        let cellCoord10 = CellCoord(indexOfColumn: -4, indexOfRow: 0)
        let cellCoord11 = CellCoord(indexOfColumn: 2, indexOfRow: 0)
        gameBoard.addCell(GridCell(coord: cellCoord9, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord10, player: players.last!))
        gameBoard.addCell(GridCell(coord: cellCoord11, player: players.last!))
        //        gameBoard.grid[cellCoord11] = GridCell(coord: cellCoord11, player: players.first!)
        let gridCellSeq0 = GridCellSeq(seq: [gameBoard[cellCoord9]!, gameBoard[cellCoord5]!, gameBoard[cellCoord0]!, gameBoard[cellCoord1]!], gameBoard: gameBoard)
        let gridCellSeq1 = GridCellSeq(seq: [gameBoard[cellCoord5]!, gameBoard[cellCoord0]!], gameBoard: gameBoard)
//        XCTAssertEqual(gridCellSeq0.isWinnable(), true)
        XCTAssertEqual(gridCellSeq1.isCompletable, true)
    }
    
    func testGridCellSeqWinningCoord() {
        let cellCoord9 = CellCoord(indexOfColumn: -2, indexOfRow: 0)
        let cellCoord10 = CellCoord(indexOfColumn: -3, indexOfRow: 0)
        let cellCoord11 = CellCoord(indexOfColumn: 2, indexOfRow: 0)
        let cellCoord12 = CellCoord(indexOfColumn: 3, indexOfRow: 0)
//        gameBoard.grid[cellCoord9] = GridCell(coord: cellCoord9, player: players.first!)
//        gameBoard.grid[cellCoord10] = GridCell(coord: cellCoord10, player: players.first!)
//        gameBoard.grid[cellCoord11] = GridCell(coord: cellCoord11, player: players.first!)
        let gridCellSeq0 = GridCellSeq(seq:  [gameBoard[cellCoord5]!, gameBoard[cellCoord0]!], gameBoard: gameBoard)
        let gridCellSeq1 = GridCellSeq(seq: [gameBoard[cellCoord5]!, gameBoard[cellCoord0]!, gameBoard[cellCoord1]!], gameBoard: gameBoard)
        XCTAssertEqual(gridCellSeq0.winningCoordsDict.count == 0, true)
        XCTAssertEqual(gridCellSeq1.winningCoordsDict[cellCoord9] != nil, true)
        
        gameBoard.addCell(GridCell(coord: cellCoord9, player: players.last!))
//        XCTAssertEqual(gridCellSeq1.winningCoord == nil, true)
        
        gameBoard.removeCellAtCoord(cellCoord9)
        gameBoard.addCell(GridCell(coord: cellCoord10, player: players.last!))
        XCTAssertEqual(gridCellSeq1.winningCoordsDict[cellCoord11] != nil, true)
        
        gameBoard.addCell(GridCell(coord: cellCoord12, player: players.last!))
        XCTAssertEqual(gridCellSeq1.winningCoordsDict.count == 0, true)
        
        gameBoard.addCell(GridCell(coord: cellCoord9, player: players.first!))
        gameBoard.removeCellAtCoord(cellCoord10)
        gameBoard.addCell(GridCell(coord: cellCoord9, player: players.last!))
        let gridCellSeq2 = GridCellSeq(seq: [gameBoard[cellCoord9]!,gameBoard[cellCoord5]!, gameBoard[cellCoord0]!, gameBoard[cellCoord1]!], gameBoard: gameBoard)
        XCTAssertEqual(gridCellSeq2.winningCoordsDict[cellCoord10] != nil, true)
        
    }
    
    
    func testBuildSeq() {
        players[0].gameBoard = gameBoard
        XCTAssertEqual(players[0].gridCellSeqs.count == 0, true)
        let newSeq0 = players[0].buildSeq(gameBoard[cellCoord0]!, orientation: GridCellSeqOrientation.horizontal)
        XCTAssertEqual(players[0].gridCellSeqs.count == 1, true)
        XCTAssertEqual(players[0].gridCellSeqs[0] === newSeq0, true)
        XCTAssertEqual(newSeq0!.seq.count == 3, true)
        XCTAssertEqual(newSeq0!.seq[0] === gameBoard[cellCoord5]!, true)
        XCTAssertEqual(newSeq0!.seq[1] === gameBoard[cellCoord0]!, true)
        XCTAssertEqual(newSeq0!.seq[2] === gameBoard[cellCoord1]!, true)
        
        let newSeq1 = players[0].buildSeq(gameBoard[cellCoord0]!, orientation: GridCellSeqOrientation.diagonalRight)
        XCTAssertEqual(players[0].gridCellSeqs.count == 1, true)
        XCTAssertEqual(players[0].gridCellSeqs[0] === newSeq0, true)
        XCTAssertEqual(newSeq1 == nil, true)
        
        let newSeq2 = players[0].buildSeq(gameBoard[cellCoord0]!, orientation: GridCellSeqOrientation.diagonalLeft)
        XCTAssertEqual(players[0].gridCellSeqs.count == 2, true)
        XCTAssertEqual(players[0].gridCellSeqs[1] === newSeq2, true)
        XCTAssertEqual(newSeq2!.seq.count == 2, true)
        XCTAssertEqual(newSeq2!.seq[0] === gameBoard[cellCoord0]!, true)
        XCTAssertEqual(newSeq2!.seq[1] === gameBoard[cellCoord2]!, true)
        
        
        let cellCoord9 = CellCoord(indexOfColumn: -2, indexOfRow: 0)
        let cellCoord10 = CellCoord(indexOfColumn: -3, indexOfRow: 0)
        let cellCoord11 = CellCoord(indexOfColumn: -4, indexOfRow: 0)
        gameBoard.addCell(GridCell(coord: cellCoord10, player: players.first!))
        gameBoard.addCell(GridCell(coord: cellCoord11, player: players.first!))
        let newSeq3 = players[0].buildSeq(gameBoard[cellCoord10]!, orientation: GridCellSeqOrientation.horizontal)
        XCTAssertEqual(players[0].gridCellSeqs.count == 3, true)
        XCTAssertEqual(newSeq3!.seq[0] === gameBoard[cellCoord11]!, true)
        XCTAssertEqual(newSeq3!.seq[1] === gameBoard[cellCoord10]!, true)
        
        
        gameBoard.addCell(GridCell(coord: cellCoord9, player: players.first!))
        let newSeq4 = players[0].buildSeq(gameBoard[cellCoord9]!, orientation: GridCellSeqOrientation.horizontal)
        XCTAssertEqual(players[0].gridCellSeqs.count == 2, true)
        XCTAssertEqual(newSeq4 === newSeq0, true)
        XCTAssertEqual(newSeq4!.seq.count == 6, true)
        XCTAssertEqual(newSeq4!.seq[0] === gameBoard[cellCoord11]!, true)
        XCTAssertEqual(newSeq4!.seq[1] === gameBoard[cellCoord10]!, true)
        XCTAssertEqual(newSeq4!.seq[2] === gameBoard[cellCoord9]!, true)
        XCTAssertEqual(newSeq4!.seq[3] === gameBoard[cellCoord5]!, true)
        XCTAssertEqual(newSeq4!.seq[4] === gameBoard[cellCoord0]!, true)
        XCTAssertEqual(newSeq4!.seq[5] === gameBoard[cellCoord1]!, true)
        
    }
    
}
