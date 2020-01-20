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
        
        
        
    }
    @IBOutlet weak var sliderView: UISlider!
        
    @IBAction func next(_ sender: Any) {
        
    }
    
    @IBAction func previous(_ sender: Any) {
        
    }
    
    @IBAction func puse(_ sender: Any) {
        
    }
    
    @IBAction func startClick(_ sender: Any) {
        
//        let musicPlayer = WFMusicPlayer()
//
//        var musicDataList = [MusicData]()
//
        let musicD = MusicData(url: "http://m10.music.126.net/20200120113758/f0da4f5c1e02f7ae87bc9b53ed5061ef/ymusic/565f/0508/075b/a53a61abbe2b42e2787b011b3d06abbb.mp3", name: "haha", singer: "我", album: "不知道", image: "http://p1.music.126.net/Ox7lGtp0WmTNJP-6nbpqIw==/2852133162457596.jpg", lyric: "")
//
//        musicDataList.append(musicD)
//
//        musicPlayer.musicArray = musicDataList
//        musicPlayer.play(URL.init(string: musicD.musicUrl!)!)
        
//        let musicPlayer = WPY_AVPlayer.playManager
//
//        musicPlayer.playMusic(url: "http://m10.music.126.net/20200119172456/e4a645fcccd319980c7a73485722c075/ymusic/545e/065a/530b/c413a59407100320b8f9da233b35f938.mp3", type: WPY_AVPlayerType.PlayTypeLine)
        
        let musicPlayer = WFMusicPlayer.sharedInstance
        musicPlayer.delegate = self
        musicPlayer.isImmediately = true
        musicPlayer.play(URL.init(string: musicD.musicUrl!)!)
    }
    
    
}


extension ViewController: WFMusicPlayerProtocol {
    
    func wfMusicPlayer(playerStateDidChange state: WFMusicPlayerState) {
        
        print(state)
    }
    
    func wfMusicPlayer(updateProgress progress: Float, currentTime: TimeInterval, currentTimeStr: String?) {
        
        print(progress)
    }
    
    func wfMusicPlayer(updateLoadProgress progress: Float, duration: TimeInterval, totalTime: String?) {
        
        print(progress)
    }
    
    func wfMusicPlayer(playerIsPlaying playing: Bool) {
        
        print(playing)
    }
    
    func wfMusicPlayer(playerCurrentPlayData playData: MusicData) {
        
        print(playData)
    }
    
}
