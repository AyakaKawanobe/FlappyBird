//
//  ViewController.swift
//  FlappyBird
//
//  Created by aykawano on 2020/12/14.
//  Copyright © 2020 ayaka. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SKViewに型を変換する
        let skView = self.view as! SKView
        
        //FPSを表示する
        skView.showsFPS = true
        
        //ノード数を表示する
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = LevelSelectScene(size: skView.frame.size)
        
        //ビューにシーンを作成する
        skView.presentScene(scene)
    }
    
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool{
        get {
            return true
        }
    }


}

