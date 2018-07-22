//
//  GridCell.swift
//  InfiniteGobang
//
//  Created by zhenduo zhu on 7/15/15.
//  Copyright © 2015 zhenduo zhu. All rights reserved.
//

import Foundation


class GridCell {
    
    let coord: CellCoord
    var player:Player
    
    init(coord: CellCoord, player: Player) {
        self.coord = coord
        self.player = player
    }

}


