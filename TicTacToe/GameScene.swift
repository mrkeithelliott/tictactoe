//
//  GameScene.swift
//  TicTacToe
//
//  Created by Keith Elliott on 6/27/16.
//  Copyright (c) 2016 GittieLabs. All rights reserved.
//

import SpriteKit

enum Player: Int{
    case One
    case Two
}

enum Cell: Int{
    case X
    case O
    case None
}

enum GameState{
    case Winner
    case Draw
    case Playing
}

class GameScene: SKScene {
    var top_left: SKNode!
    var top_middle: SKNode!
    var top_right: SKNode!
    var middle_left: SKNode!
    var center: SKNode!
    var middle_right: SKNode!
    var bottom_left: SKNode!
    var bottom_middle: SKNode!
    var bottom_right: SKNode!
    var winningLabel: SKNode!
    var resetNode: SKNode!
    
    var currentPlayer: Player = .One
    var grid: [Cell] = Array(count: 9, repeatedValue: .None)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        top_left  = self.childNodeWithName("top_left")
        top_middle = self.childNodeWithName("top_middle")
        top_right = self.childNodeWithName("top_right")
        middle_left = self.childNodeWithName("middle_left")
        center = self.childNodeWithName("center")
        middle_right = self.childNodeWithName("middle_right")
        bottom_left = self.childNodeWithName("bottom_left")
        bottom_middle = self.childNodeWithName("bottom_middle")
        bottom_right = self.childNodeWithName("bottom_right")
        
        winningLabel = self.childNodeWithName("winningLabel")
        winningLabel.hidden = true
        
        resetNode = self.childNodeWithName("Reset")
        resetNode.hidden = true
        
        if let top_left = top_left as? SKSpriteNode{
            top_left.color = UIColor.clearColor()
        }
        if let top_middle = top_middle as? SKSpriteNode{
            top_middle.color = UIColor.clearColor()
        }
        if let top_right = top_right as? SKSpriteNode{
            top_right.color = UIColor.clearColor()
        }
        if let middle_left = middle_left as? SKSpriteNode{
            middle_left.color = UIColor.clearColor()
        }
        if let center = center as? SKSpriteNode{
            center.color = UIColor.clearColor()
        }
        if let middle_right = middle_right as? SKSpriteNode{
            middle_right.color = UIColor.clearColor()
        }
        if let bottom_left = bottom_left as? SKSpriteNode{
            bottom_left.color = UIColor.clearColor()
        }
        if let bottom_middle = bottom_middle as? SKSpriteNode{
            bottom_middle.color = UIColor.clearColor()
        }
        if let bottom_right = bottom_right as? SKSpriteNode{
            bottom_right.color = UIColor.clearColor()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
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
            
            if currentPlayer == .One{
                let circle = SKSpriteNode(imageNamed: "X_symbol")
                circle.size = CGSize(width: 75, height: 75)
                node = circle
            }
            else{
                let cross = SKSpriteNode(imageNamed: "O_symbol")
                cross.size = CGSize(width: 75, height: 75)
                node = cross
            }
            
            if let name = selectedNode.name{
                if name == "top_left"{
                    top_left.addChild(node)
                    grid[0] = currentPlayer == .One ? .X : .O
                }
                else if name == "top_middle"{
                    top_middle.addChild(node)
                    grid[1] = currentPlayer == .One ? .X : .O
                }
                else if name == "top_right"{
                    top_right.addChild(node)
                    grid[2] = currentPlayer == .One ? .X : .O
                }
                else if name == "middle_left"{
                    middle_left.addChild(node)
                    grid[3] = currentPlayer == .One ? .X : .O
                }
                else if name == "center"{
                    center.addChild(node)
                    grid[4] = currentPlayer == .One ? .X : .O
                }
                else if name == "middle_right"{
                    middle_right.addChild(node)
                    grid[5] = currentPlayer == .One ? .X : .O
                }
                else if name == "bottom_left"{
                    bottom_left.addChild(node)
                    grid[6] = currentPlayer == .One ? .X : .O
                }
                else if name == "bottom_middle"{
                    bottom_middle.addChild(node)
                    grid[7] = currentPlayer == .One ? .X : .O
                }
                else if name == "bottom_right"{
                    bottom_right.addChild(node)
                    grid[8] = currentPlayer == .One ? .X : .O
                }
                else{
                    return
                }
                
                currentPlayer = currentPlayer == .One ? .Two : .One
                
                let (state, winner) = determineIfWinner()
                
                if state == .Winner{
                    let winningPlayer = winner! == .One ? "1" : "2"
                    if let winningLabel = winningLabel as? SKLabelNode{
                        winningLabel.text = "Player \(winningPlayer) wins!"
                        winningLabel.hidden = false
                        resetNode.hidden = false
                    }
                }
                else if state == .Draw{
                    if let winningLabel = winningLabel as? SKLabelNode{
                        winningLabel.text = "It's a draw"
                        winningLabel.hidden = false
                        resetNode.hidden = false
                    }
                    
                }
                else{
                    winningLabel.hidden = true
                }

            }
            
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func resetGame(){
        grid = Array(count: 9, repeatedValue: .None)
        top_left.removeAllChildren()
        top_middle.removeAllChildren()
        top_right.removeAllChildren()
        middle_left.removeAllChildren()
        center.removeAllChildren()
        middle_right.removeAllChildren()
        bottom_left.removeAllChildren()
        bottom_middle.removeAllChildren()
        bottom_right.removeAllChildren()
        
        currentPlayer = .One
        winningLabel.hidden = true
        resetNode.hidden = true
        
    }
    
    func determineIfWinner()->(GameState, Player?){
        // check rows for a winner
        if grid[0] != .None && (grid[0] == grid[1] && grid[0] == grid[2]){
            let winner: Player = grid[0] == .X ? .One : .Two
            return (.Winner, winner)
         }
        
        if grid[3] != .None && (grid[3] == grid[4] && grid[3] == grid[5]){
            let winner : Player = grid[3] == .X ? .One : .Two
            return (.Winner, winner)
        }
        
        if grid[6] != .None && (grid[6] == grid[7] && grid[6] == grid[8]) {
            let winner: Player = grid[6] == .X ? .One : .Two
            return (.Winner, winner)
        }
    
        // check columns for a winner
        if grid[0] != .None && (grid[0] == grid[3] && grid[3] == grid[6]){
            let winner: Player = grid[0] == .X ? .One : .Two
            return (.Winner, winner)
        }

        if grid[1] != .None && (grid[1] == grid[4] && grid[4] == grid[7]){
            let winner: Player = grid[1] == .X ? .One : .Two
            return (.Winner, winner)
        }
    
        if grid[2] != .None && (grid[2] == grid[5] && grid[5] == grid[8]){
            let winner: Player = grid[2] == .X ? .One : .Two
            return (.Winner, winner)
        }
        
        // check diagonals for a winner
        if grid[0] != .None && (grid[0] == grid[4] && grid[4] == grid[8]){
            let winner: Player = grid[0] == .X ? .One : .Two
            return (.Winner, winner)
        }
        
        if grid[2] != .None && (grid[2] == grid[4] && grid[4] == grid[6]){
            let winner: Player = grid[2] == .X ? .One : .Two
            return (.Winner, winner)
        }
        
        if !grid.contains(.None){
            return (.Draw, nil)
        }
 
    return (.Playing, nil)
    }
}
