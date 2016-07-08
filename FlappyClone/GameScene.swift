//
//  GameScene.swift
//  FlappyClone
//
//  Created by H on 6/28/16.
//  Copyright (c) 2016 H. All rights reserved.
//

import SpriteKit

struct PhysicsCatagory {
    
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Ghost  = SKSpriteNode()
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions() // so no more walls are generated
        died = false
        gameStarted = false
        score = 0
        createScence()
        
    }
    
    func createScence() {
        
        self.physicsWorld.contactDelegate = self
        
        // background loop
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5) // make the scores label slightly higher than the center
        scoreLbl.text = "\(scoreLbl)"
        scoreLbl.zPosition = 8
        scoreLbl.fontName = "04b_19"
        scoreLbl.fontSize = 55
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5) // scale size for 1080 x 100
        
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        // y = 0 -> set it to the bottom of the scene
        // self.frame.width / 2 -> set it to the middle of the scene
        // 0 + Ground.frame.height / 2 -> set it so the ground is taller
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        
        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        // tests whether two objects i.e. Wall & Ghost have collided
        
        Ground.physicsBody?.affectedByGravity = false // don't want ground moving
        Ground.physicsBody?.dynamic = false // unmoving character --> when hit doesn't move
        Ground.zPosition = 3 // the ground will be top layer over everything
        
        self.addChild(Ground)
        
        Ghost = SKSpriteNode(imageNamed: "Ghost")
        Ghost.size = CGSize(width: 60, height: 70)
        Ghost.position = CGPoint(x: self.frame.width / 2 - Ghost.frame.width, y: self.frame.height / 2)
        
        // add / 2 - Ghost.frame.width to move over slightly to the left
        // self.frame.height / 2 -> set the ghost in the middle on the y axis
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCatagory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        // '|' is a separator-- want Ghost to be able to collide with Ground & Wall
        
        Ghost.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        Ghost.physicsBody?.affectedByGravity = false
        // want ghost to be in middle of screen before game starts
        
        Ghost.physicsBody?.dynamic = true
        
        Ghost.zPosition = 2
        
        self.addChild(Ghost)

        
    }
    override func didMoveToView(view: SKView) {
        
        createScence()
        
    }
    
    func createBTN () {
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 10
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Ghost{
            
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        } else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Score {
            
            // || means if either statement is true then execute what is inside {}
            // Score and Ghost may be either first or second body-- it is unpredictable
            // so it is set up for both instances
            
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
            
            
        }
    
        else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Wall || firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            // want to stop the walls from being created
            enumerateChildNodesWithName("wallPair", usingBlock: {
                
                (node, error) in
                // node = all the nodes from wallPair inside scene 
                
                node.speed = 0
                self.removeAllActions()
            })
            
            if died == false {
                
                died = true
                createBTN()
            }
        }
        
        else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Ground || firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            // want to stop the walls from being created
            enumerateChildNodesWithName("wallPair", usingBlock: {
                
                (node, error) in
                // node = all the nodes from wallPair inside scene
                
                node.speed = 0
            })
            
            if died == false {
                
                died = true
                createBTN()
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if gameStarted == false {
            
            gameStarted = true
            Ghost.physicsBody?.affectedByGravity = true
            scoreLbl.text = "0"
            
            // only want spawn to be called once when the game starts
            let spawn = SKAction.runBlock({
                
                () in
                
                self.createWalls() // calls function to create walls everytime user respawns
            })
            
            let delay = SKAction.waitForDuration(2.0) // 2 seconds wait per wall creation
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.01 * distance))
            
            // -distance because we want the walls to move right to left, not vice versa
            // 0.05 -> make it slower, 0.002 -> make it faster
            
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVectorMake(0, 0)
            Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 85)) // moves up by 85 pixels
            
        } else {
            
            if died == true {
                
            }
            else {
                Ghost.physicsBody?.velocity = CGVectorMake(0, 0)
                Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 85)) // moves up by 85 pixels
            }
            
        }
        
        
        for touch in touches {
            // touches from Set<UITouch>
            
            let location = touch.locationInNode(self)
            
            if died == true {
                
                if restartBTN.containsPoint(location) {
                    
                    // if our touch location is on the restart button
                    // reset the scene
                    
                    restartScene()
                }
            }
        }
    
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0 // don't want it to collide with anything
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        // we want the Ghost to be able to make contact with Score
        scoreNode.color = SKColor.yellowColor()
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        btmWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI) // turn top wall 180 degrees
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1 // the wall will be in the back of the setting
        
        var randomPosition = CGFloat.random(min: -200, max: 200)
        
        // apply random height to walls
        
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
    
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true {
            
            if died == false {
                enumerateChildNodesWithName("background", usingBlock: ({
                    
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    // make the background move slowly --> 2 pixels at a time
                    
                    if bg.position.x <= -bg.size.width {
                        
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                        // have it infinitely scroll
                        // sets a new background to the right
                    }
                }))
            }
            
        }
    }
}
