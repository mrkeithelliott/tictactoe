//
//  AIStrategy.swift
//  TicTacToe
//
//  Created by Keith Elliott on 6/28/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import GameplayKit
import Foundation

@objc(Player)
class Player: NSObject, GKGameModelPlayer{
    let _player: Int
    
    init(player:Int) {
        _player = player
        super.init()
    }
    
    var playerId: Int{
        return _player
    }
}

@objc(Move)
class Move: NSObject, GKGameModelUpdate{
    var value: Int = 0
    var cell: Int
    
    init(cell: Int){
        self.cell = cell
        super.init()
    }
}

@objc(Board)
class Board: NSObject, NSCopying, GKGameModel{
    let _players: [GKGameModelPlayer] = [Player(player: 0), Player(player: 1)]
    var currentPlayer: GKGameModelPlayer?
    var board: [GridCoordinate]
    
    func isPlayerOne()->Bool{
        return currentPlayer?.playerId == _players[0].playerId
    }
    
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject{
//        return self.dynamicType.init(self)
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    required override init() {
        self.currentPlayer = _players[0]
        self.board = []
        super.init()
    }
    
    required init(_ board: Board){
        self.currentPlayer =  board.currentPlayer
        self.board = Array(board.board)
        super.init()
    }
    
    @objc var players: [GKGameModelPlayer]?{
       return self._players
    }
    
    var activePlayer: GKGameModelPlayer?{
        return currentPlayer
    }
    
    func togglePlayer(){
        currentPlayer = currentPlayer?.playerId == _players[0].playerId ? _players[1] : _players[0]
    }
    
    func setGameModel(gameModel: GKGameModel) {
        if let board = gameModel as? Board{
            self.currentPlayer = board.currentPlayer
            self.board = Array(board.board)
        }
    }
    
    func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves:[GKGameModelUpdate] = []
        for (index, _) in self.board.enumerate(){
            if self.board[index].value == .None{
                moves.append(Move(cell: index))
            }
        }
        
        return moves
    }
    
    func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! Move
        self.board[move.cell].value = isPlayerOne() ? .X : .O
        self.togglePlayer()
    
    }

    func getPlayerAtGridCoordinate(gridCoord: GridCoordinate)->GKGameModelPlayer?{
        return gridCoord.value == .X ? self.players?.first: self.players?.last
    }
    
    func isWinForPlayer(player: GKGameModelPlayer) -> Bool {
        let (state, winner) = determineIfWinner()
        if state == .Winner && winner?.playerId == player.playerId{
            return true
        }
        
        return false
    }
    
    func isLossForPlayer(player: GKGameModelPlayer) -> Bool {
        let (state, winner) = determineIfWinner()
        if state == .Winner && winner?.playerId != player.playerId{
            return true
        }
        
        return false
    }
    
    func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        return 0
    }
    
    func determineIfWinner()->(GameState, GKGameModelPlayer?){
        // check rows for a winner
        if board[0].value != .None && (board[0].value == board[1].value && board[0].value == board[2].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[0]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[3].value != .None && (board[3].value == board[4].value && board[3].value == board[5].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[3]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[6].value != .None && (board[6].value == board[7].value && board[6].value == board[8].value) {
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[6]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        // check columns for a winner
        if board[0].value != .None && (board[0].value == board[3].value && board[3].value == board[6].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[0]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[1].value != .None && (board[1].value == board[4].value && board[4].value == board[7].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[1]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[2].value != .None && (board[2].value == board[5].value && board[5].value == board[8].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[2]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        // check diagonals for a winner
        if board[0].value != .None && (board[0].value == board[4].value && board[4].value == board[8].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[0]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[2].value != .None && (board[2].value == board[4].value && board[4].value == board[6].value){
            guard let winner: GKGameModelPlayer = getPlayerAtGridCoordinate(board[2]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        let foundEmptyCells: [GridCoordinate] = board.filter{ (gridCoord) -> Bool in
            return gridCoord.value == .None
        }
        
        if foundEmptyCells.isEmpty{
            return (.Draw, nil)
        }
        
        return (.Playing, nil)
    }
}
