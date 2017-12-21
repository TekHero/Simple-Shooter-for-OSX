//
//  TitleScene.swift
//  Simple Shooter For OSX
//
//  Created by Brian Lim on 3/26/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene: SKScene {
    
    var gameTitle: SKLabelNode!
    var playBtn: NSButton!
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = NSColor.blue
        setUpText()
    }
    
    func setUpText() {
        
        gameTitle = SKLabelNode(fontNamed: "Futura")
        gameTitle.fontSize = 50
        gameTitle.fontColor = NSColor.white
        gameTitle.text = "Space Shooter"
        gameTitle.position = CGPoint(x: self.frame.midX, y: 600)
        
        self.addChild(gameTitle)
        
        playBtn = NSButton(frame: NSRect(x: 150, y: 100, width: 500, height: 100))
        playBtn.font = NSFont(name: "Futura", size: 24)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        playBtn.attributedTitle = NSAttributedString(string: "Play", attributes: [NSForegroundColorAttributeName:NSColor.white, NSParagraphStyleAttributeName:style])
        playBtn.target = self
        playBtn.action = #selector(TitleScene.playGame)
        
        self.view?.addSubview(playBtn)
    }
    
    func playGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        gameTitle.removeFromParent()
        playBtn.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "Gamescene") {
            
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }
}
