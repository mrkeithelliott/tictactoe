//
//  GameStateMachine.swift
//  TicTacToe
//
//  Created by Keith Elliott on 7/3/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class StartGameState: GKState{
    var scene: GameScene?
    var winningLabel: SKNode!
    var resetNode: SKNode!
    var boardNode: SKNode!
    
    init(scene: GameScene){
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == ActiveGameState.self
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        resetGame()
        self.stateMachine?.enter(ActiveGameState.self)
    }
    
    func resetGame(){
        let top_left: BoardCell  = BoardCell(value: .none, node: "//*top_left")
        let top_middle: BoardCell = BoardCell(value: .none, node: "//*top_middle")
        let top_right: BoardCell = BoardCell(value: .none, node: "//*top_right")
        let middle_left: BoardCell = BoardCell(value: .none, node: "//*middle_left")
        let center: BoardCell = BoardCell(value: .none, node: "//*center")
        let middle_right: BoardCell = BoardCell(value: .none, node: "//*middle_right")
        let bottom_left: BoardCell = BoardCell(value: .none, node: "//*bottom_left")
        let bottom_middle: BoardCell = BoardCell(value: .none, node: "//*bottom_middle")
        let bottom_right: BoardCell = BoardCell(value: .none, node: "//*bottom_right")
        
        boardNode = self.scene?.childNode(withName: "//Grid") as? SKSpriteNode
        
        winningLabel = self.scene?.childNode(withName: "winningLabel")
        winningLabel.isHidden = true
        
        resetNode = self.scene?.childNode(withName: "Reset")
        resetNode.isHidden = true
        
        
        let board = [top_left, top_middle, top_right, middle_left, center, middle_right, bottom_left, bottom_middle, bottom_right]
        
        self.scene?.gameBoard = Board(gameboard: board)
        
        self.scene?.enumerateChildNodes(withName: "//grid*") { (node, stop) in
            if let node = node as? SKSpriteNode{
                node.removeAllChildren()
            }
        }
    }
}

class EndGameState: GKState{
    var scene: GameScene?
    
    init(scene: GameScene){
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == StartGameState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        updateGameState()
    }
    
    func updateGameState(){
        let resetNode = self.scene?.childNode(withName: "Reset")
        resetNode?.isHidden = false
    }
}

class ActiveGameState: GKState{
    var scene: GameScene?
    var waitingOnPlayer: Bool
    
    init(scene: GameScene){
        self.scene = scene
        waitingOnPlayer = false
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == EndGameState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        waitingOnPlayer = false
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        assert(scene != nil, "Scene must not be nil")
        assert(scene?.gameBoard != nil, "Gameboard must not be nil")
        
        if !waitingOnPlayer{
            waitingOnPlayer = true
            updateGameState()
        }
    }
    
    func updateGameState(){
        assert(scene != nil, "Scene must not be nil")
        assert(scene?.gameBoard != nil, "Gameboard must not be nil")
        
        let (state, winner) = self.scene!.gameBoard!.determineIfWinner()
        if state == .winner{
            let winningLabel = self.scene?.childNode(withName: "winningLabel")
            winningLabel?.isHidden = true
            let winningPlayer = self.scene!.gameBoard!.isPlayerOne(winner!) ? "1" : "2"
            if let winningLabel = winningLabel as? SKLabelNode,
                let player1_score = self.scene?.childNode(withName: "//player1_score") as? SKLabelNode,
                let player2_score = self.scene?.childNode(withName: "//player2_score") as? SKLabelNode{
                winningLabel.text = "Player \(winningPlayer) wins!"
                winningLabel.isHidden = false
                
                if winningPlayer == "1"{
                    player1_score.text = "\(Int(player1_score.text!)! + 1)"
                }
                else{
                    player2_score.text = "\(Int(player2_score.text!)! + 1)"
                }
                
                self.stateMachine?.enter(EndGameState.self)
                waitingOnPlayer = false
            }
        }
        else if state == .draw{
            let winningLabel = self.scene?.childNode(withName: "winningLabel")
            winningLabel?.isHidden = true
            
            
            if let winningLabel = winningLabel as? SKLabelNode{
                winningLabel.text = "It's a draw"
                winningLabel.isHidden = false
            }
            self.stateMachine?.enter(EndGameState.self)
            waitingOnPlayer = false
        }

        else if self.scene!.gameBoard!.isPlayerTwoTurn(){
            //AI moves
            self.scene?.isUserInteractionEnabled = false
            
            assert(scene != nil, "Scene must not be nil")
            assert(scene?.gameBoard != nil, "Gameboard must not be nil")
                
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                self.scene!.ai.gameModel = self.scene!.gameBoard!
                let move = self.scene!.ai.bestMoveForActivePlayer() as? Move
                    
                assert(move != nil, "AI should be able to find a move")
                    
                let strategistTime = CFAbsoluteTimeGetCurrent()
                let delta = CFAbsoluteTimeGetCurrent() - strategistTime
                let  aiTimeCeiling: TimeInterval = 1.0
                    
                let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay) * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
                        
                    guard let cellNode: SKSpriteNode = self.scene?.childNode(withName: self.scene!.gameBoard!.getElementAtBoardLocation(move!.cell).node) as? SKSpriteNode else{
                            return
                    }
                    let circle = SKSpriteNode(imageNamed: "O_symbol")
                    circle.size = CGSize(width: 75, height: 75)
                    cellNode.addChild(circle)
                    self.scene!.gameBoard!.addPlayerValueAtBoardLocation(move!.cell, value: .o)
                    self.scene!.gameBoard!.togglePlayer()
                    self.waitingOnPlayer = false
                    self.scene?.isUserInteractionEnabled = true
                }
            }
        }
        else{
            self.waitingOnPlayer = false
            self.scene?.isUserInteractionEnabled = true
        }
    }
}
