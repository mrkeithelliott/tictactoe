//
//  GameScene.swift
//  TicTacToe
//
//  Created by Keith Elliott on 6/27/16.
//  Copyright (c) 2016 GittieLabs. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Cell: Int{
    case X
    case O
    case None
}

enum GameState: Int{
    case Winner
    case Draw
    case Playing
}

struct GridCoordinate{
    var value: Cell
    var node: String
}

class GameScene: SKScene {
    var winningLabel: SKNode!
    var resetNode: SKNode!
    var boardNode: SKNode!
    var gameBoard: Board!
    var ai: GKMinmaxStrategist!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        ai = GKMinmaxStrategist()
        ai.maxLookAheadDepth = 8
        ai.randomSource = GKARC4RandomSource()
        self.enumerateChildNodesWithName("//grid*") { (node, stop) in
            if let node = node as? SKSpriteNode{
                node.color = UIColor.clearColor()
            }
        }
        
        resetGame()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if !gameBoard.isPlayerOne(){
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let selectedNode = self.nodeAtPoint(location)
            var node: SKSpriteNode
            
            if let name = selectedNode.name {
                if name == "Reset" || name == "reset_label"{
                    resetGame()
                    return
                }
            }
            
            if gameBoard.isPlayerOne(){
                let cross = SKSpriteNode(imageNamed: "X_symbol")
                cross.size = CGSize(width: 75, height: 75)
                cross.zRotation = CGFloat(M_PI / 4.0)
                node = cross
            }
            else{
                let circle = SKSpriteNode(imageNamed: "O_symbol")
                circle.size = CGSize(width: 75, height: 75)
                node = circle
            }
            
            for i in 0...8{
                guard let cellNode: SKSpriteNode = self.childNodeWithName(gameBoard.board[i].node) as? SKSpriteNode else{
                    return
                }
                if selectedNode.name == cellNode.name{
                    cellNode.addChild(node)
                    gameBoard.board[i].value = gameBoard.isPlayerOne() ? .X : .O
                    gameBoard.togglePlayer()
                }
            }
            
            updateGameState()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    func updateGameState(){
       let (state, winner) = gameBoard.determineIfWinner()
        if state == .Winner{
            let winningPlayer = winner!.playerId == gameBoard._players[0].playerId ? "1" : "2"
            if let winningLabel = winningLabel as? SKLabelNode,
                let player1_score = self.childNodeWithName("//player1_score") as? SKLabelNode,
                let player2_score = self.childNodeWithName("//player2_score") as? SKLabelNode{
                winningLabel.text = "Player \(winningPlayer) wins!"
                winningLabel.hidden = false
                
                if winningPlayer == "1"{
                    player1_score.text = "\(Int(player1_score.text!)! + 1)"
                }
                else{
                    player2_score.text = "\(Int(player2_score.text!)! + 1)"
                }
                resetNode.hidden = false
                gameBoard.currentPlayer = gameBoard._players[0]
            }
        }
        else if state == .Draw{
            if let winningLabel = winningLabel as? SKLabelNode{
                winningLabel.text = "It's a draw"
                winningLabel.hidden = false
                resetNode.hidden = false
                gameBoard.currentPlayer = gameBoard._players[0]
            }
            
        }
        else{
            winningLabel.hidden = true
            
            if gameBoard.activePlayer!.playerId == gameBoard._players[1].playerId{
                //AI moves
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.ai.gameModel = self.gameBoard
                    let move = self.ai.bestMoveForPlayer(self.gameBoard.currentPlayer!) as! Move?
                    
                    assert(move != nil, "AI should be able to find a move")
                    
                    let strategistTime = CFAbsoluteTimeGetCurrent()
                    let delta = CFAbsoluteTimeGetCurrent() - strategistTime
                    let  aiTimeCeiling: NSTimeInterval = 2.0
                        
                    let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            
                        guard let cellNode: SKSpriteNode = self.childNodeWithName(self.gameBoard.board[move!.cell].node) as? SKSpriteNode else{
                                return
                        }
                        let circle = SKSpriteNode(imageNamed: "O_symbol")
                        circle.size = CGSize(width: 75, height: 75)
                        cellNode.addChild(circle)
                        self.gameBoard.board[move!.cell].value = .O
                        self.gameBoard.togglePlayer()
                        self.updateGameState()
                    }
                }
            }

        }
    }
    
    func resetGame(){
        let top_left: GridCoordinate  = GridCoordinate(value: .None, node: "//*top_left")
        let top_middle: GridCoordinate = GridCoordinate(value: .None, node: "//*top_middle")
        let top_right: GridCoordinate = GridCoordinate(value: .None, node: "//*top_right")
        let middle_left: GridCoordinate = GridCoordinate(value: .None, node: "//*middle_left")
        let center: GridCoordinate = GridCoordinate(value: .None, node: "//*center")
        let middle_right: GridCoordinate = GridCoordinate(value: .None, node: "//*middle_right")
        let bottom_left: GridCoordinate = GridCoordinate(value: .None, node: "//*bottom_left")
        let bottom_middle: GridCoordinate = GridCoordinate(value: .None, node: "//*bottom_middle")
        let bottom_right: GridCoordinate = GridCoordinate(value: .None, node: "//*bottom_right")
        
        boardNode = self.childNodeWithName("//Grid") as? SKSpriteNode
        
        winningLabel = self.childNodeWithName("winningLabel")
        winningLabel.hidden = true
        
        resetNode = self.childNodeWithName("Reset")
        resetNode.hidden = true
        
        
        let board = [top_left, top_middle, top_right, middle_left, center, middle_right, bottom_left, bottom_middle, bottom_right]
        
        gameBoard = Board()
        gameBoard.board = board
        
        self.enumerateChildNodesWithName("//grid*") { (node, stop) in
            if let node = node as? SKSpriteNode{
                node.removeAllChildren()
            }
        }
    }
}
