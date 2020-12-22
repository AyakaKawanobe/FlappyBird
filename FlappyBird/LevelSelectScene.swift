//
//  LevelSelectScene.swift
//  FlappyBird
//
//  Created by aykawano on 2020/12/21.
//  Copyright © 2020 ayaka. All rights reserved.
//

import SpriteKit

class LevelSelectScene: SKScene {
        override func didMove(to view: SKView) {
        //背景色を指定
        self.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        //タイトル
        let title = SKLabelNode()
        title.text = "Flappy Bird"
        title.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 150)
        title.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title.fontSize = 50
        self.addChild(title)
        
        //鳥
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .nearest
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .nearest
        
        let textureAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        let bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 + 250)
        
        bird.run(flap)
        addChild(bird)
        
        //かんたんボタン作成
        let easyButton = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
        easyButton.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 - 100)
        easyButton.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        easyButton.zPosition = 50
        easyButton.name = "easybtn"
        self.addChild(easyButton)
        
        let easyText = SKLabelNode()
        easyText.text = "かんたん"
        easyText.fontColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        easyText.position = CGPoint(x: easyButton.position.x, y: easyButton.position.y - 10)
        easyText.zPosition = 70
        easyText.fontSize = 20
        easyText.name = "easybtn"
        self.addChild(easyText)
        
        //普通ボタン作成
        let usualButton = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
        usualButton.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        usualButton.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        usualButton.zPosition = 50
        usualButton.name = "usualbtn"
        self.addChild(usualButton)
        
        let usualText = SKLabelNode()
        usualText.text = "ふつう"
        usualText.fontColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        usualText.position = CGPoint(x: usualButton.position.x, y: usualButton.position.y - 10)
        usualText.zPosition = 70
        usualText.fontSize = 20
        usualText.name = "usualbtn"
        self.addChild(usualText)
        
        //難しいボタン作成
        let difficultButton = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
        difficultButton.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 + 100)
        difficultButton.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        difficultButton.zPosition = 50
        difficultButton.name = "difficultbtn"
        self.addChild(difficultButton)
        
        let difficultText = SKLabelNode()
        difficultText.text = "おに"
        difficultText.fontColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        difficultText.position = CGPoint(x: difficultButton.position.x, y: difficultButton.position.y - 10)
        difficultText.zPosition = 70
        difficultText.fontSize = 20
        difficultText.name = "difficultbtn"
        self.addChild(difficultText)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            let location = touch.location(in: self)
            if self.atPoint(location).name == "easybtn"{
                //タッチを検出した時にGameSceneを呼び出す
                let scene = EasyGameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.aspectFill
                self.view?.presentScene(scene)
            }else if self.atPoint(location).name == "usualbtn"{
                //タッチを検出した時にGameSceneを呼び出す
                let scene = UsualGameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.aspectFill
                self.view?.presentScene(scene)
            }else if self.atPoint(location).name == "difficultbtn"{
                //タッチを検出した時にGameSceneを呼び出す
                let scene = DifficultGameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}
