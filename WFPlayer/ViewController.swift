//
//  ViewController.swift
//  WFPlayer
//
//  Created by xiantiankeji on 2020/1/10.
//  Copyright © 2020 tomodel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let musicPlayer = WFMusicPlayer()
        
        var musicDataList = [MusicData]()
        
        let musicD = MusicData(url: "http://m10.music.126.net/20200117001343/c24cba1839f537886777572fab1826c5/ymusic/b1c4/b5de/74d0/9158ae4873e10b743790320db9ef9b29.mp3", name: "haha", singer: "我", album: "不知道", image: "http://p1.music.126.net/Ox7lGtp0WmTNJP-6nbpqIw==/2852133162457596.jpg", lyric: "")
        
        musicDataList.append(musicD)
        
        musicPlayer.musicArray = musicDataList
        musicPlayer.play(URL.init(string: musicD.musicUrl!)!)
        
    }

    
    
    
   
}

