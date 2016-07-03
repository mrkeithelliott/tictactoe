//
//  GameScene.swift
//  TicTacToe
//
//  Created by Keith Elliott on 6/27/16.
//  Copyright (c) 2016 GittieLabs. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var gameBoard: Board!
    var stateMachine: GKStateMachine!
    var ai: GKMinmaxStrategist!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.enumerateChildNodesWithName("//grid*") { (node, stop) in
            if let node = node as? SKSpriteNode{
                node.color = UIColor.clearColor()
            }
        }
        
        let top_left: BoardCell  = BoardCell(value: .None, node: "//*top_left")
        let top_middle: BoardCell = BoardCell(value: .None, node: "//*top_middle")
        let top_right: BoardCell = BoardCell(value: .None, node: "//*top_right")
        let middle_left: BoardCell = BoardCell(value: .None, node: "//*middle_left")
        let center: BoardCell = BoardCell(value: .None, node: "//*center")
        let middle_right: BoardCell = BoardCell(value: .None, node: "//*middle_right")
        let bottom_left: BoardCell = BoardCell(value: .None, node: "//*bottom_left")
        let bottom_middle: BoardCell = BoardCell(value: .None, node: "//*bottom_middle")
        let bottom_right: BoardCell = BoardCell(value: .None, node: "//*bottom_right")
        
        let board = [top_left, top_middle, top_right, middle_left, center, middle_right, bottom_left, bottom_middle, bottom_right]
        
        gameBoard = Board(gameboard: board)
        
        ai = GKMinmaxStrategist()
        ai.maxLookAheadDepth = 9
        ai.randomSource = GKARC4RandomSource()
        
        let beginGameState = StartGameState(scene: self)
        let activeGameState = ActiveGameState(scene: self)
        let endGameState = EndGameState(scene: self)
        
        stateMachine = GKStateMachine(states: [beginGameState, activeGameState, endGameState])
        stateMachine.enterState(StartGameState.self)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {        
        for touch in touches {
            let location = touch.locationInNode(self)
            let selectedNode = self.nodeAtPoint(location)
            var node: SKSpriteNode
            
            if let name = selectedNode.name {
                if name == "Reset" || name == "reset_label"{
                    self.stateMachine.enterState(StartGameState.self)
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
                guard let cellNode: SKSpriteNode = self.childNodeWithName(gameBoard.getElementAtBoardLocation(i).node) as? SKSpriteNode else{
                    return
                }
                if selectedNode.name == cellNode.name{
                    cellNode.addChild(node)
                    gameBoard.addPlayerValueAtBoardLocation(i, value: gameBoard.isPlayerOne() ? .X : .O)
                    gameBoard.togglePlayer()
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.stateMachine.updateWithDeltaTime(currentTime)
    }
}
