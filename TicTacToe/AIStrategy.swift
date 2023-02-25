//
//  AIStrategy.swift
//  TicTacToe
//
//  Created by Keith Elliott on 6/28/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import GameplayKit
import Foundation

enum PlayerType: Int{
    case X
    case O
    case None
}

enum GameState: Int{
    case Winner
    case Draw
    case Playing
}

struct BoardCell{
    var value: PlayerType
    var node: String
}

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
    
    private let _players: [GKGameModelPlayer] = [Player(player: 0), Player(player: 1)]
    private var currentPlayer: GKGameModelPlayer?
    private var board: [BoardCell]
    private var currentScoreForPlayerOne: Int
    private var currentScoreForPlayerTwo: Int
    
    func isPlayerOne()->Bool{
        return currentPlayer?.playerId == _players[0].playerId
    }
    
    func playerOne()->GKGameModelPlayer{
        return _players[0]
    }
    
    func playerTwo()->GKGameModelPlayer{
        return _players[1]
    }
    
    func setActivePlayer(player: GKGameModelPlayer){
        currentPlayer = player
    }
    
    func isPlayerOneTurn()->Bool{
        return isPlayerOne(player: activePlayer!)
    }
    
    func isPlayerTwoTurn()->Bool{
        return !isPlayerOneTurn()
    }
    
    func makePlayerOneActive(){
        currentPlayer = _players[0]
    }
    
    func makePlayerTwoActive(){
        currentPlayer = _players[1]
    }
    
    func getElementAtBoardLocation(index:Int)->BoardCell{
        assert(index < board.count, "Location on board must be less than total elements in array")
        return board[index]
    }
    
    func addPlayerValueAtBoardLocation(index: Int, value: PlayerType){
        assert(index < board.count, "Location on board must be less than total elements in array")
        board[index].value = value
    }
    
    @objc func isPlayerOne(player: GKGameModelPlayer)->Bool{
        return player.playerId == _players[0].playerId
    }
    
    
    @objc func copy(with zone: NSZone? = nil) -> Any{
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    required override init() {
        self.currentPlayer = _players[0]
        self.board = []
        self.currentScoreForPlayerOne = 0
        self.currentScoreForPlayerTwo = 0
        
        super.init()
    }
    
    init(gameboard: [BoardCell]){
        self.currentPlayer = _players[0]
        self.board = gameboard
        self.currentScoreForPlayerOne = 0
        self.currentScoreForPlayerTwo = 0
        super.init()
    }
    
    required init(_ board: Board){
        self.currentPlayer =  board.currentPlayer
        self.board = Array(board.board)
        self.currentScoreForPlayerOne = 0
        self.currentScoreForPlayerTwo = 0
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
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board{
            self.currentPlayer = board.currentPlayer
            self.board = Array(board.board)
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves:[GKGameModelUpdate] = []
        for (index, _) in self.board.enumerated(){
            if self.board[index].value == .None{
                moves.append(Move(cell: index))
            }
        }
        
        return moves
    }
    
    func unapplyGameModelUpdate(_ gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! Move
        self.board[move.cell].value = .None
        self.togglePlayer()
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! Move
        self.board[move.cell].value = isPlayerOne() ? .X : .O
        self.togglePlayer()
    
    }

    func getPlayerAtBoardCell(gridCoord: BoardCell)->GKGameModelPlayer?{
        return gridCoord.value == .X ? self.players?.first: self.players?.last
    }
    
    func isWin(player: GKGameModelPlayer) -> Bool {
        let (state, winner) = determineIfWinner()
        if state == .Winner && winner?.playerId == player.playerId{
            return true
        }
        
        return false
    }
    
    func isLoss(player: GKGameModelPlayer) -> Bool {
        let (state, winner) = determineIfWinner()
        if state == .Winner && winner?.playerId != player.playerId{
            return true
        }
        
        return false
    }
    
    
    func score(for player: GKGameModelPlayer) -> Int {
        if isWin(player: player){
            if isPlayerOne(player: player){
                currentScoreForPlayerOne += 4
                return currentScoreForPlayerOne
            }
            else{
                currentScoreForPlayerTwo += 4
                return currentScoreForPlayerTwo
            }
        }
        
        if isLoss(player: player){
            return 0
        }
        
        let opponent = isPlayerOne(player: player) ? playerTwo() : playerOne()
        
        let opponentOneMoveAwayFromWinning = isOneMoveAwayFromWinning(player: opponent)
        if opponentOneMoveAwayFromWinning{
            if isPlayerOne(player: player){
                currentScoreForPlayerOne += 3
                return currentScoreForPlayerOne
            }
            else{
                currentScoreForPlayerTwo += 3
                return currentScoreForPlayerTwo
            }
        }
        
        let playOneMoveAwayFromWinning = isOneMoveAwayFromWinning(player: player)
        if playOneMoveAwayFromWinning{
            if isPlayerOne(player: player){
                currentScoreForPlayerOne += 2
                return currentScoreForPlayerOne
            }
            else{
                currentScoreForPlayerTwo += 2
                return currentScoreForPlayerTwo
            }
        }
        
        if isPlayerOne(player: player){
            currentScoreForPlayerOne += 1
            return currentScoreForPlayerOne
        }
        else{
            currentScoreForPlayerTwo += 1
            return currentScoreForPlayerTwo
        }
    }
    
    func isOneMoveAwayFromWinning(player: GKGameModelPlayer)->Bool {
        
        let row_diagonal_Checker = {(row:ArraySlice<BoardCell>, playerCell: PlayerType)->Bool in
            let numofPlayerTypes = row.filter{$0.value == playerCell}
            let containsBlankCells = row.filter{$0.value == .None}
        
            if containsBlankCells.count == 0{
                return false
            }
        
            if numofPlayerTypes.count == 2 {
                return true
            }
            return false
        }
        
        // check the rows for two in a row
        let row1 = board[0...2]
        let playerCell: PlayerType = isPlayerOne(player: player) ? .X : .O
        let row2 = board[3...5]
        let row3 = board[6...8]
        
        if row_diagonal_Checker(row1,playerCell){
            return true
        }
        
        if row_diagonal_Checker(row2, playerCell){
            return true
        }
        
        if row_diagonal_Checker(row3, playerCell){
            return true
        }
        
        var col1 = ArraySlice<BoardCell>()
        col1.append(board[0])
        col1.append(board[3])
        col1.append(board[6])
        
        if row_diagonal_Checker(col1, playerCell){
            return true
        }
        
        var col2 = ArraySlice<BoardCell>()
        col2.append(board[1])
        col2.append(board[4])
        col2.append(board[7])
        
        if row_diagonal_Checker(col2, playerCell){
            return true
        }
        
        var col3 = ArraySlice<BoardCell>()
        col3.append(board[2])
        col3.append(board[5])
        col3.append(board[8])
        
        if row_diagonal_Checker(col3, playerCell){
            return true
        }
        
        var diag1 = ArraySlice<BoardCell>()
        diag1.append(board[0])
        diag1.append(board[4])
        diag1.append(board[8])
        
        if row_diagonal_Checker(diag1, playerCell){
            return true
        }
        
        var diag2 = ArraySlice<BoardCell>()
        diag2.append(board[2])
        diag2.append(board[4])
        diag2.append(board[6])
        
        if row_diagonal_Checker(diag2, playerCell){
            return true
        }
        
        return false
    }
    
    func determineIfWinner()->(GameState, GKGameModelPlayer?){
        // check rows for a winner
        if board[0].value != .None && (board[0].value == board[1].value && board[0].value == board[2].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[0]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[3].value != .None && (board[3].value == board[4].value && board[3].value == board[5].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[3]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[6].value != .None && (board[6].value == board[7].value && board[6].value == board[8].value) {
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[6]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        // check columns for a winner
        if board[0].value != .None && (board[0].value == board[3].value && board[3].value == board[6].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[0]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[1].value != .None && (board[1].value == board[4].value && board[4].value == board[7].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[1]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[2].value != .None && (board[2].value == board[5].value && board[5].value == board[8].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[2]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        // check diagonals for a winner
        if board[0].value != .None && (board[0].value == board[4].value && board[4].value == board[8].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[0]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        if board[2].value != .None && (board[2].value == board[4].value && board[4].value == board[6].value){
            guard let winner: GKGameModelPlayer = getPlayerAtBoardCell(gridCoord: board[2]) else{ return (.Draw, nil)}
            return (.Winner, winner)
        }
        
        let foundEmptyCells: [BoardCell] = board.filter{ (gridCoord) -> Bool in
            return gridCoord.value == .None
        }
        
        if foundEmptyCells.isEmpty{
            return (.Draw, nil)
        }
        
        return (.Playing, nil)
    }
}
