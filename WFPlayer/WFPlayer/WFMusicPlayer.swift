//
//  WFMusicPlayer.swift
//  WFPlayer
//
//  Created by xiantiankeji on 2020/1/10.
//  Copyright © 2020 tomodel. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class WFMusicPlayer: NSObject {
    
    /// 单例
    static let sharedInstance = WFMusicPlayer()
    /// 代理
    weak var delegate: WFMusicPlayerProtocol?
    /// 播放器类
    var musicPlayer: AVPlayer = {
        
        let player = AVPlayer()
        return player
    }()
    /// 当前播放数据
    var currentMData : MusicData?
    /// AVPlayerItem提供了AVPlayer播放需要的媒体文件，时间、状态、文件大小等信息，是AVPlayer媒体文件的载体
    var playerItem:AVPlayerItem?
    /// AVURLAsset: AVAsset的子类，可以根据一个URL路径创建一个包含媒体信息的AVURLAsset对象
    fileprivate var urlAsset:AVURLAsset?
    var timeObserVer : Any?
    /// 播放类型 (默认s顺序播放)
    var playerMode : WFMusicPlayerMode = .sequential
    /// 播放列表
    var musicArray = [MusicData]()
    /// 当前播放下标
    var currentIndex: Int = 0
    /// 当前播放歌曲的加载进度
    var loadProgress: Float?
    /// 仅在bufferingSomeSecond里面使用  表示正在缓冲中
    fileprivate var isBuffering = false
    /// 当前歌曲播放时间字符串
    var startTimeStr: String?
    /// 当前歌曲结束时间字符串
    var endTimeStr: String?
    /// 当前播放歌曲的进度
    var playProgress: Float = 0.0
    /// 是否正在播放
    var isPlay: Bool = false
    /// 是否正在拖动slide  调整播放时间
    var isSeekingToTime: Bool = false
    
    /// 拖动进度条控制播放进度
    var sliderValue: Float = 0.0 {
        didSet {
            let total = CMTimeGetSeconds(self.musicPlayer.currentItem!.duration)
            let seconds = total * Float64(sliderValue)
            self.musicPlayer.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (finished) in
                
                self.musicPlayer.play()
            }
        }
    }
    
    /// 播放器的几种状态
    fileprivate var state = WFMusicPlayerState.notSetURL {
        didSet {
            if state != oldValue {
                delegate?.wfMusicPlayer(playerStateDidChange: state)
            }
        }
    }
    
    /// 总共时间
    var totalTime: CMTime? {
        get {
            return self.musicPlayer.currentItem?.duration
        }
    }
    
    /// 当前播放时间
    var currentPlayTime: CMTime? {
        get {
            return self.musicPlayer.currentItem?.currentTime()
        }
    }
    /// 应用是否进入后台
    var isEnterBackground : Bool = false
    /// 播放前是否跳到 0
    var seekToZeroBeforePlay : Bool = false
    /// 是否立即播放
    var isImmediately : Bool = false
    /// 后台播放申请ID
    var bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    /// 播放速度    改变播放速度
    var playSpeed : Float = 1.0 {
        didSet{
            if (self.isPlay){
                guard let playerItem = self.playerItem else {return}
                self.enableAudioTracks(enable: true, playerItem: playerItem)
                self.musicPlayer.rate = playSpeed
            }
        }
    }
    /// 为了设置锁屏封面
    var imageView = UIImageView()
    
    
}


// MARK: -- 播放器基本方法 （停止、开始、下一首、上一首 等）
extension WFMusicPlayer {

    /// 开始播放通过
    /// - Parameter url: 文件地址
    func play(url: String!, isImmediately: Bool = false) {
        
        self.isImmediately = isImmediately
        playBase(URL.init(string: url)!)
    }
    
    func play(dataArray: [MusicData], isImmediately: Bool = false) {
        
        self.isImmediately = isImmediately
        self.musicArray = dataArray
        self.currentMData = self.musicArray.first
        playBase(URL.init(string: self.currentMData!.musicUrl!)!)
    }
    
    func play(data: MusicData, isImmediately: Bool = false) {
        
        self.musicArray.append(data)
        self.currentMData = data
        playBase(URL.init(string: self.currentMData!.musicUrl!)!)
    }
    
    fileprivate func playBase(_ url: URL) {
        
        self.removeObserver()
        self.urlAsset = AVURLAsset(url: url)
        // AVPlayerItem提供了AVPlayer播放需要的媒体文件，时间、状态、文件大小等信息，是AVPlayer媒体文件的载体
        let playerItem = AVPlayerItem(asset: self.urlAsset!)
        self.musicPlayer.replaceCurrentItem(with: playerItem)
        self.addObserver()

        if self.musicArray.count > 0 {
            
            delegate?.wfMusicPlayer(playerCurrentPlayData: self.musicArray[self.currentIndex])
        }
    }
    
    
    /// 开始播放
    func play() {
        
        self.musicPlayer.play()
    }
    
    /// 暂停
    func pause() {
        
        self.musicPlayer.pause()
    }
    
    /// 上一首
    func playPrevious() {
        
        if self.currentIndex == 0 {
            
            let pr = self.musicArray.count;
            if pr > 0 {
                
                self.currentIndex = pr - 1
            }
        } else {
            
            self.currentIndex = self.currentIndex - 1
        }
        let music = self.musicArray[self.currentIndex]
        self.playBase(URL.init(string: music.musicUrl!)!)
    }
    
    func playNext() {
        
        if self.currentIndex == self.musicArray.count - 1 {
            
            self.currentIndex = 0
        } else {
            
            let pr = self.musicArray.count;
            
            if pr > 0 {
                
                self.currentIndex = pr + 1
            }
        }
        let music = self.musicArray[self.currentIndex]
        self.playBase(URL.init(string: music.musicUrl!)!)
    }
    
    /// 设置锁屏时 播放中心的播放信息
    func setNowPlayingInfo() {
    
        if self.currentMData != nil {
           
            var info = Dictionary<String,Any>()
            info[MPMediaItemPropertyTitle] = self.currentMData?.musicName ?? ""
            
            if let image = UIImage(named: "AppIcon") {
                
                let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                    
                    return image
                })
                // 显示的图片
                info[MPMediaItemPropertyArtwork] = artwork
            }
                
    //            if  let url = self.currentScenicPoint?.pictureArray?.first ,let image = UIImage(named: "AppIcon"){
    //                imageView.kf.setImage(with: URL(string:url), placeholder: image, options: nil, progressBlock: nil) { (img, _, _, _) in
    //
    //                    if
    //                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image:img)//显示的图片
    //                }
    //            }else{
    //
    //            }
                
                
            info[MPMediaItemPropertyPlaybackDuration] = changeStringForTime(timeInterval: CMTimeGetSeconds(self.totalTime!))  //总时长
            
            if let duration = self.musicPlayer.currentItem?.currentTime() {
                
               info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(duration)
            }
            info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0//播放速率
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
        
    func currentPlayData() -> MusicData {
        
        let music = self.musicArray[self.currentIndex]
        return music
    }
    
    /// 改变播放速率  必实现的方法
    ///
    /// - Parameters:
    ///   - enable:
    ///   - playerItem: 当前播放
    func enableAudioTracks(enable:Bool,playerItem : AVPlayerItem){
        
        for track : AVPlayerItemTrack in playerItem.tracks {
            
            if track.assetTrack?.mediaType == AVMediaType.audio {
                
                track.isEnabled = enable
            }
        }
    }
}

// MARK: -- 系统想状态改变时处理方法
extension WFMusicPlayer {
    
    /// 监测是否靠近耳朵  转换声音播放模式
    @objc fileprivate func sensorStateChange() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            
            if UIDevice.current.proximityState == true {
                
                // 靠近耳朵
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
                } catch { }
            }else {
                
                // 远离耳朵
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
                } catch { }
            }
        }
    }
    
    /// 处理播放音频是被来电 或者 其他 打断音频的处理
    /// - Parameter sender: NSNotification
    @objc fileprivate func handleInterreption(sender: NSNotification) {
        
        let info = sender.userInfo
        guard let type : AVAudioSession.InterruptionType =  info?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType else { return }
        
        if type == AVAudioSession.InterruptionType.began {
            
            self.pause()
        } else {
            guard  let options = info![AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions else {return}
            
            if(options == AVAudioSession.InterruptionOptions.shouldResume){
                self.pause()
            }
        }
    }
    
    /// 单个音频播放结束后的逻辑处理
    @objc func playMusicFinished() {
        
        UIDevice.current.isProximityMonitoringEnabled = true
        self.seekToZeroBeforePlay = true
        self.isPlay = false
        self.state = .end
        
        if (self.playerMode == .sequential) {
            
            self.playNext()
        }
    }
}

// MARK: -- 通知、kvo 监听 AVPlayerItem属性变化
extension WFMusicPlayer {
    
    func addObserver() {
        
        if self.musicPlayer.currentItem != nil {
            
            //监控状态属性
            self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.status, options: NSKeyValueObservingOptions.new, context: nil)
            //监控网络加载情况属性
            self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.loadedTimeRanges, options: NSKeyValueObservingOptions.new, context: nil)
            //监听播放的区域缓存是否为空
            self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.playbackBufferEmpty, options: NSKeyValueObservingOptions.new, context: nil)
            //缓存可以播放的时候调用
            self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.playbackLikelyToKeepUp, options: NSKeyValueObservingOptions.new, context: nil)
            
            //监听是否靠近耳朵
            NotificationCenter.default.addObserver(self, selector: #selector(sensorStateChange), name:UIDevice.proximityStateDidChangeNotification, object: nil)
            
            //播放期间被 电话 短信 微信 等打断后的处理
            NotificationCenter.default.addObserver(self, selector: #selector(handleInterreption(sender:)), name:AVAudioSession.interruptionNotification, object:AVAudioSession.sharedInstance())
            
            // 监控播放结束通知
            NotificationCenter.default.addObserver(self, selector: #selector(playMusicFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.musicPlayer.currentItem)
            
            /// 监控播放进度
            self.timeObserVer = self.musicPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (time) in
                
                guard let `self` = self else { return }

                let currentTime = CMTimeGetSeconds(time)
                self.playProgress = Float(currentTime)
                
                if self.isSeekingToTime {
                    return
                }
                let total =  Float(CMTimeGetSeconds(self.totalTime!))
                
                if total > 0 {
                    self.delegate?.wfMusicPlayer(updateProgress: Float(currentTime) / Float(total), currentTime: currentTime, currentTimeStr: self.changeStringForTime(timeInterval: currentTime))
                }
            }
        }
    }
        
    func removeObserver() {
        
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.status)
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.loadedTimeRanges)
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.playbackBufferEmpty)
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.playbackLikelyToKeepUp)
        
        NotificationCenter.default.removeObserver(self, name:UIDevice.proximityStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if(self.timeObserVer != nil) {
            
            self.musicPlayer.removeTimeObserver(self.timeObserVer!)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem, let keyPath = keyPath {
            
            if item == self.musicPlayer.currentItem {
                
                switch keyPath {
                case ObserverKeyPath.status:
                    
                    if item.status == AVPlayerItem.Status.failed {
                        
                        self.state = WFMusicPlayerState.notPlay
                    }
                    else if item.status == AVPlayerItem.Status.readyToPlay  {
                        
                        if isImmediately {
                            
                            self.play()
                        } else {
                            
                            self.setNowPlayingInfo()
                        }
                    }
                    else if item.status == AVPlayerItem.Status.unknown {
                                           
                        self.state = WFMusicPlayerState.notKnow
                    }
                case ObserverKeyPath.loadedTimeRanges:
                    // 计算缓冲进度
                    if let timeInterVarl = self.availableDuration() {
                        
                        let duration = item.duration
                        let totalDuration = CMTimeGetSeconds(duration)
                        let loadProgress = timeInterVarl/totalDuration
                        let currentTimeStr = changeStringForTime(timeInterval: timeInterVarl)
                        print("-----")
                        print(loadProgress)
                        delegate?.wfMusicPlayer(updateLoadProgress: Float(loadProgress), duration: totalDuration, totalTime: currentTimeStr)
                    }
                case ObserverKeyPath.playbackBufferEmpty:
                    if self.musicPlayer.currentItem!.isPlaybackBufferEmpty {
                        
                        self.bufferingSomeSecond()
                    }
                case ObserverKeyPath.playbackLikelyToKeepUp:
                    if self.musicPlayer.currentItem!.isPlaybackBufferEmpty {
                        if state != WFMusicPlayerState.bufferEmpty {
                            self.state = WFMusicPlayerState.bufferEmpty
                        }
                    }
                default: break
                }
            }
        }
    }
    
    
    /// 缓冲进度
    fileprivate func availableDuration() -> TimeInterval? {
        
        if let loadedTimeRanges = self.musicPlayer.currentItem?.loadedTimeRanges, let first = loadedTimeRanges.first {
            
            let timeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSecound = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSecound
            return result
        }
        return nil
    }
    
    /// 缓冲比较差的时候
    fileprivate func bufferingSomeSecond() {
        
        if self.isBuffering {
            return
        }
        self.isBuffering = true
        self.musicPlayer.pause()
        let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 1.0))
        DispatchQueue.main.asyncAfter(deadline: popTime) { [weak self] in
            
            guard let `self` = self else { return }
            self.isBuffering = false
            if let item = self.musicPlayer.currentItem {
                
                if !item.isPlaybackLikelyToKeepUp {
                    
                    self.bufferingSomeSecond()
                } else {
                    
                    // 如果此时用户已经暂停了，则不再需要开启播放了
                    self.state = WFMusicPlayerState.bufferEmpty
                }
            }
        }
    }
    
    func changeStringForTime(timeInterval: TimeInterval) -> String? {
        
        let date = Date.init(timeIntervalSince1970: timeInterval)
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="mm:ss"
        let dateStr = dfmatter.string(from: date)
        return dateStr
    }
}

/**
播放器监听

- status: AVPlayerItemStatusReadyToPlay的状态下，取CMTimeGetSeconds(playerItem.duration)的值进行了播放总时间的更新，因为后台给的音频总时间不一定是很准确的，可能会丢失一点精度。
- loadedTimeRanges:    网络音频的的缓冲进度 这里需要注意的是，本地数据不会调用，所以在设置的时候本地数据不能依赖这里
- playbackBufferEmpty:      缓冲是否为空，这个值为YES，视频就会暂停，加载圈就会启动
- playbackLikelyToKeepUp:   视频是否可以正常播放，这个值为YES，加载圈就会消失，这里不包含本地音频播放的情况
*/
fileprivate struct ObserverKeyPath {
    
    static let status = "status"
    static let loadedTimeRanges = "loadedTimeRanges"
    static let playbackBufferEmpty = "playbackBufferEmpty"
    static let playbackLikelyToKeepUp = "playbackLikelyToKeepUp"
}
