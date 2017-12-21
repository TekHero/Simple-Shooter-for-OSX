//
//  GameScene.swift
//  Simple Shooter For OSX
//
//  Created by Brian Lim on 3/26/16.
//  Copyright (c) 2016 codebluapps. All rights reserved.
//

import SpriteKit

var player = SKSpriteNode?()
var projectile = SKSpriteNode?()
var enemy = SKSpriteNode?()

var lblScore = SKLabelNode?()
var lblMain = SKLabelNode?()

var fireProjectileRate = 0.2
var projectileSpeed = 0.9

var enemySpeed = 2.1
var enemySpawnRate = 0.7

var isAlive = true

var score = 0

var textColorHUD = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

struct physicsCategory {
    
    static let player: UInt32 = 1
    static let enemy: UInt32 = 2
    static let projectile: UInt32 = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.backgroundColor = NSColor.blue
        
        resetVariablesOnStart()
        spawnPlayer()
        spawnEnemy()
        spawnProjectile()
        spawnMainLbl()
        spawnScoreLbl()
        
        fireProjectile()
        randomEnemyTimerSpawn()
        hideLbl()
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        
        if isAlive == true {
            player?.position.x = location.x
        } else {
            player?.position.x = -300
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if isAlive == false {
            player?.position.x = -300
        }
    }
    
    func resetVariablesOnStart() {
        isAlive = true
        score = 0
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.projectile) || (firstBody.categoryBitMask == physicsCategory.projectile) && (secondBody.categoryBitMask == physicsCategory.enemy)) {
            
            // Spawn Explosion
            spawnExplosion(firstBody.node as! SKSpriteNode)
            projectileCollision(firstBody.node as! SKSpriteNode, projectileTEMP: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.player) || (firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy)) {
            
            // Spawn Explosion
            enemyPlayerCollision(firstBody.node as! SKSpriteNode, playerTEMP: secondBody.node as! SKSpriteNode)
        }
    }
    
    func projectileCollision(_ enemyTEMP: SKSpriteNode, projectileTEMP: SKSpriteNode) {
        enemyTEMP.removeFromParent()
        projectileTEMP.removeFromParent()
        
        score = score + 1
        updateScore()
    }
    
    func enemyPlayerCollision(_ enemyTEMP: SKSpriteNode, playerTEMP: SKSpriteNode) {
        
        isAlive = false
        lblMain?.fontSize = 50
        lblMain?.alpha = 1.0
        lblMain?.text = "GAMEOVER"
        
        waitThenMoveToGameoverScreen()
        
    }
    
    func spawnExplosion(_ enemyTemp: SKSpriteNode) {
        
        let explosionEmitterPath: NSString = Bundle.main.path(forResource: "Explosion", ofType: "sks")! as NSString
        let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath as String) as! SKEmitterNode
        
        explosion.position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        explosion.zPosition = -1
        explosion.targetNode = self
        
        self.addChild(explosion)
        
        let explosionTimerRemoval = SKAction.wait(forDuration: 0.2)
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        
        self.run(SKAction.sequence([explosionTimerRemoval, removeExplosion]))
        
    }
    
    func updateScore() {
        lblScore?.text = "Score: \(score)"
    }
    
    func waitThenMoveToGameoverScreen() {
        let wait = SKAction.wait(forDuration: 1.0)
        let transition = SKAction.run {
            self.view?.presentScene(GameoverScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        }
        
        let sequence = SKAction.sequence([wait, transition])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    // MARK - SPAWNING
    
    func spawnPlayer() {
        player = SKSpriteNode(color: NSColor.white, size: CGSize(width: 50, height: 50))
        player?.position = CGPoint(x: self.frame.midX, y: 150)
        player?.physicsBody = SKPhysicsBody(rectangleOf: player!.size)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player?.physicsBody?.isDynamic = false
        
        self.addChild(player!)
    }
    
    func spawnEnemy() {
        enemy = SKSpriteNode(color: NSColor.white, size: CGSize(width: 50, height: 50))
        enemy?.position = CGPoint(x: CGFloat(arc4random_uniform(700) + 200), y: 1000)
        enemy?.physicsBody = SKPhysicsBody(rectangleOf: enemy!.size)
        enemy?.physicsBody?.affectedByGravity = false
        enemy?.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy?.physicsBody?.contactTestBitMask = physicsCategory.projectile
        enemy?.physicsBody?.allowsRotation = false
        enemy?.physicsBody?.isDynamic = true
        
        var moveDown = SKAction.moveTo(y: -100, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        
        if isAlive == false {
            moveDown = SKAction.moveTo(y: 1200, duration: 1.0)
        }
        
        enemy?.run(SKAction.sequence([moveDown, destroy]))
        
        self.addChild(enemy!)
    }
    
    func spawnScoreLbl() {
        lblScore = SKLabelNode(fontNamed: "Futura")
        lblScore?.fontSize = 50
        lblScore?.fontColor = textColorHUD
        lblScore?.position = CGPoint(x: self.frame.midX, y: 30)
        lblScore?.text = "Score"
        
        self.addChild(lblScore!)
    }
    
    func spawnMainLbl() {
        lblMain = SKLabelNode(fontNamed: "Futura")
        lblMain?.fontSize = 100
        lblMain?.fontColor = textColorHUD
        lblMain?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        lblMain?.text = "Start"
        
        self.addChild(lblMain!)
    }
    
    func spawnProjectile() {
        projectile = SKSpriteNode(color: NSColor.red, size: CGSize(width: 10, height: 20))
        projectile?.position = CGPoint(x: (player?.position.x)!, y: (player?.position.y)!)
        projectile?.physicsBody = SKPhysicsBody(rectangleOf: (projectile?.size)!)
        projectile?.physicsBody?.affectedByGravity = false
        projectile?.physicsBody?.categoryBitMask = physicsCategory.projectile
        projectile?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        projectile?.physicsBody?.isDynamic = false
        projectile?.zPosition = -1
        
        let moveUp = SKAction.moveTo(y: 800, duration: projectileSpeed)
        let destroy = SKAction.removeFromParent()
        
        projectile?.run(SKAction.sequence([moveUp, destroy]))
        
        self.addChild(projectile!)
    }
    
    // MARK - ACTIONS
    
    func fireProjectile() {
        let fireProjectileTimer = SKAction.wait(forDuration: fireProjectileRate)
        let spawn = SKAction.run {
            self.spawnProjectile()
        }
        
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomEnemyTimerSpawn() {
        let wait = SKAction.wait(forDuration: 1.0)
        let spawn = SKAction.run {
            self.spawnEnemy()
            self.spawnEnemy()
            self.spawnEnemy()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func hideLbl() {
        let wait = SKAction.wait(forDuration: 3.0)
        let hide = SKAction.run {
            lblMain?.alpha = 0.0
        }
        
        let sequence = SKAction.sequence([wait, hide])
        self.run(SKAction.repeat(sequence, count: 1))
    }

    
    
}
