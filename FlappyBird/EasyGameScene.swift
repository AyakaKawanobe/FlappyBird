//
//  EasyGameScene.swift
//  FlappyBird
//
//  Created by aykawano on 2020/12/21.
//  Copyright © 2020 ayaka. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class EasyGameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode : SKNode!
    var wallNode : SKNode!
    var bird : SKSpriteNode!
    var apple : SKSpriteNode!
    var appleNode : SKNode!
    var button : SKNode!
    
    var player : AVAudioPlayer!
    //バックミュージック
    let bgm = SKAudioNode(fileNamed: "bgm.mp3")
    //効果音
    let appleMusic = SKAction.playSoundFileNamed("apple.mp3", waitForCompletion: true)
    
    //衝突判定カテゴリー
    let birdCategory : UInt32 = 1 << 0    // 0...00001
    let groundCategory : UInt32 = 1 << 1  // 0...00010
    let wallCategory : UInt32 = 1 << 2    // 0...00100
    let scoreCategory : UInt32 = 1 << 3   // 0...01000
    let appleCategory : UInt32 = 1 << 4   // 0...10000
    
    //スコア用
    var score = 0
    var item = 0
    var bestScore = 0
    var scoreLabelNode : SKLabelNode!
    var bestScoreLabelNode : SKLabelNode!
    var itemScoreLabelNode : SKLabelNode!
    let userDefaults : UserDefaults = UserDefaults.standard
    
    //カウントダウン用
    var countdownLabel : SKLabelNode!
    var count = 3

    //SKView上にシーンが表示される時に呼ばれるメソッド
    //画面を構築する処理やゲームの初期設定を行う
    override func didMove(to view: SKView) {
        addChild(bgm)
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //背景色を指定
        backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //アイテム用ノード
        appleNode = SKNode()
        scrollNode.addChild(appleNode)
        
        //ボタン用ノード
        button = SKNode()
        
        //カウントダウンメソッド
        countdown(count: self.count)
        scrollNode.speed = 0
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupApple()
        
        setupScoreLabel()
        
    }
    
    //ゲームスタート前カウントダウン
    func countdown(count: Int){
        countdownLabel = SKLabelNode()
        countdownLabel.text = "\(count)"
        countdownLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        countdownLabel.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        countdownLabel.fontSize = 100
        countdownLabel.zPosition = 120
        
        addChild(countdownLabel)
        
        let countDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0),SKAction.run(countdownAction)])
        run(SKAction.sequence([SKAction.repeat(countDecrement, count: 3),SKAction.run(endCountdown)]))
    }
    
    func countdownAction(){
        count -= 1
        countdownLabel.text = "\(count)"
    }
    
    func endCountdown(){
        countdownLabel.removeFromParent()
        
        //スクロール開始
        scrollNode.speed = 1
        
        //カウントダウン終了したら重力持たせる
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        
    }
    
    func setupGround(){
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スライドさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2)
            
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を指定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリ設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
            
        }
    }
    
    func setupCloud(){
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スライドさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //スプライトを配置する
        for i in 0..<needCloudNumber{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            //スプライトにアニメーションを追加する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall(){
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 4
        
        //隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        //下の壁のY軸下限位置（中央位置から下方向の最大振れ幅で下の壁を表示させる位置）を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        //壁を作成するアクションを作成
        let createWallAnimation = SKAction.run({
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 //雲より手前、地面より奥
            
            //0~random_y_rangeまでランダムの値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //Y軸の下限にランダムな値を足して、下の壁のY座標決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下の壁を生成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないよう設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上の壁を生成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //スプライトに物理演算を指定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないよう設定する
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.size.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            //自身のカテゴリを指定
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            //衝突することを判定する相手のカテゴリを設定
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までのアクション
        let waitAnimation = SKAction.wait(forDuration: 3)
        
        //壁を作成->時間待ち->壁を作成も無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird(){
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear

        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)

        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        
        //衝突時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリ設定
        bird.physicsBody?.categoryBitMask = birdCategory
        
        //当たった時に跳ね返る動作をする相手
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory

        // アニメーションを設定
        bird.run(flap)

        // スプライトを追加する
        addChild(bird)
    }
    
    func setupApple(){
        //リンゴの画像を読み込む
        let appleTexture = SKTexture(imageNamed: "apple")
        appleTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + appleTexture.size().width)
        
        //画面が今で移動するアクションを作成
        let moveApple = SKAction.moveBy(x: -movingDistance, y: 0, duration: 10)
        
        //自身を取り除くアクションを作成
        let removeApple = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクションを作成
        let appleAnimation = SKAction.sequence([moveApple,removeApple])
        
        //リンゴ出現の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = bird.size.height * 5
        let center_y = self.frame.size.height / 2
        
        //リンゴを生成するアクションを作成
        let createAppleAnimation = SKAction.run({
            //スプライトを作成
            self.apple = SKSpriteNode(texture: appleTexture)
            
            //0~random_y_rangeまでのランダムな値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //リンゴのy座標決定
            let apple_y = center_y + random_y
            
            self.apple.size = CGSize(width: self.apple.size.width * 0.05, height: self.apple.size.height * 0.05)
            self.apple.position = CGPoint(x: self.frame.size.width + self.apple.size.width / 2, y: apple_y)
            self.apple.zPosition = -70
            
            //物理演算を指定
            self.apple.physicsBody = SKPhysicsBody(circleOfRadius: self.apple.size.height / 2)
            
            //衝突の時に動かないように設定する
            self.apple.physicsBody?.isDynamic = false
            
            //衝突のカテゴリ設定
            self.apple.physicsBody?.categoryBitMask = self.appleCategory
            self.apple.physicsBody?.contactTestBitMask = self.birdCategory
            
            
            self.apple.run(appleAnimation)
            self.appleNode.addChild(self.apple)
        })
        
        
        let waitAnimation = SKAction.wait(forDuration: 1)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createAppleAnimation, waitAnimation]))
        
        self.appleNode.run(repeatForeverAnimation)
        
    }
    
    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0{
            //鳥の速度を0にする
            bird.physicsBody?.velocity = CGVector.zero
            //      bird.physicsBody?.velocity = CGVector(dx: 100, dy: 0)
            
            //鳥に縦方向の力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }else if bird.speed == 0{
            //ボタン選択
            if let touch = touches.first as UITouch?{
                let location = touch.location(in: self)
                if self.atPoint(location).name == "onemore"{
                    restart()
                }else if self.atPoint(location).name == "level"{
                    //レベル選択画面を呼び出す
                    let scene = LevelSelectScene(size: self.scene!.size)
                    scene.scaleMode = SKSceneScaleMode.aspectFill
                    self.view?.presentScene(scene)
                }
            }
        }
    }
    
    //SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーの時は何もしない
        if scrollNode.speed<=0{
            return
        }
        
        if(contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory{
            print(contact.bodyA.categoryBitMask & scoreCategory)
            print(contact.bodyB.categoryBitMask & scoreCategory)
            print(contact.bodyA.categoryBitMask)
            print(contact.bodyB.categoryBitMask)
            print(scoreCategory)

            //スコア用の物体と衝突した
            print("ScoreUP")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認する
            bestScore = userDefaults.integer(forKey : "easyBest")
            if score + item > bestScore{
                bestScore = score + item
                bestScoreLabelNode.text = "BestScore:\(bestScore)!!!!"
                userDefaults.set(bestScore, forKey: "easyBest")
                //即座に保存する
                userDefaults.synchronize()
            }
            
        }else if (contact.bodyA.categoryBitMask & appleCategory) == appleCategory || (contact.bodyB.categoryBitMask & appleCategory) == appleCategory{
            //アイテムと衝突した
            item += 1
            itemScoreLabelNode.text = "ItemScore:\(item)"
            
            //ベストスコア更新か確認する
            bestScore = userDefaults.integer(forKey : "easyBest")
            if score + item > bestScore{
                bestScore = score + item
                bestScoreLabelNode.text = "BestScore:\(bestScore)!!!!"
                userDefaults.set(bestScore, forKey: "easyBest")
                //即座に保存する
                userDefaults.synchronize()
            }
            
            //衝突したリンゴを抽出
            var apple :SKPhysicsBody
            
            //リンゴか鳥か判別し代入
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask & appleCategory{
                apple = contact.bodyB
            }else{
                apple = contact.bodyA
            }
            
            self.run(appleMusic)
            
            //衝突したリンゴを削除
            apple.node?.removeFromParent()
            
        }else{
            //壁か地面に衝突した
            print("GameOver")
            
            //スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
            
            //レベル選択画面に戻るかもう一度か
            //もう一度ボタン作成
            let onemoreButton = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
            onemoreButton.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 + 100)
            onemoreButton.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            onemoreButton.zPosition = 50
            onemoreButton.name = "onemore"
            button.addChild(onemoreButton)
            
            let onemoreText = SKLabelNode()
            onemoreText.text = "もう一度"
            onemoreText.fontColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            onemoreText.position = CGPoint(x: onemoreButton.position.x, y: onemoreButton.position.y - 10)
            onemoreText.zPosition = 70
            onemoreText.fontSize = 20
            onemoreText.name = "onemore"
            button.addChild(onemoreText)
            
            //レベル選択ボタン作成
            let levelButton = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
            levelButton.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            levelButton.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            levelButton.zPosition = 50
            levelButton.name = "level"
            button.addChild(levelButton)
            
            let levelText = SKLabelNode()
            levelText.text = "レベル変更"
            levelText.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            levelText.position = CGPoint(x: levelButton.position.x, y: levelButton.position.y - 10)
            levelText.zPosition = 70
            levelText.fontSize = 20
            levelText.name = "level"
            button.addChild(levelText)
            
            addChild(button)
            
        }
    }
    
    func restart(){
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        item = 0
        itemScoreLabelNode.text = "ItemScore:\(item)"
        bestScoreLabelNode.text = "BestScore:\(bestScore)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        appleNode.removeAllChildren()
        button.removeFromParent()
        
        bird.speed = 1
        
        scrollNode.speed = 0
        count = 3
        
        countdown(count: count)
    }
    
    func setupScoreLabel(){
        item = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "ItemScore:\(item)"
        self.addChild(itemScoreLabelNode)
        
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "easyBest")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
}

