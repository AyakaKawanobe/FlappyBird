//
//  CountdownScene.swift
//  FlappyBird
//
//  Created by aykawano on 2020/12/21.
//  Copyright © 2020 ayaka. All rights reserved.
//

import SpriteKit

class CountdownScene: SKScene {
    
    var background = SKSpriteNode()
    var count = SKLabelNode()

    override func didMove(to view: SKView) {
//        // 各種ノードを初期化
//        background = childNode(withName: "background") as? SKSpriteNode
//        count = childNode(withName: "count") as? SKLabelNode ?? <#default value#>
        // wait するアクションを定義
        let wait = SKAction.wait(forDuration: 1.0)
        // 5 から 1 までカウントダウンするアクションを定義
        let five = SKAction.run({
            self.count.text = "5"
        })
        let four = SKAction.run({
            self.count.text = "4"
        })
        let three = SKAction.run({
            self.count.text = "3"
        })
        let two = SKAction.run({
            self.count.text = "2"
        })
        let one = SKAction.run({
            self.count.text = "1"
        })
        // 背景とカウントダウンのラベルを非表示にするアクションを定義
        let hidden = SKAction.run({
            self.background.isHidden = true
            self.count.isHidden = true
        })
        // アクションを実行
        self.run(SKAction.sequence([wait, five, wait, four, wait, three, wait, two, wait, one, wait, hidden]))
        self.addChild(background)
        self.addChild(count)
    }
}
