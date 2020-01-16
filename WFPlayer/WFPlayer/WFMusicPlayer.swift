//
//  WFMusicPlayer.swift
//  WFPlayer
//
//  Created by xiantiankeji on 2020/1/10.
//  Copyright © 2020 tomodel. All rights reserved.
//

import UIKit
import MediaPlayer

/**
 播放器播放状态 emun
 
 - notSetURL:           没有URL
 - readyToPlay:         准备播放的播放器
 - buffering:               播放器缓冲
 - bufferFinished:      缓冲区完成
 - playedToTheEnd:  播放到结尾
 - error:                      播放错误
 */
public enum WFMusicPlayerState {
    
    case notSetURL
    case readyToPlay
    case buffering
    case bufferFinished
    case playedToTheEnd
    case error
}

/**
播放器播放方式

- sequential:        顺序播放
- random:           随机播放
- single:               单曲循环
*/
public enum WFMusicPlayerMode {
    
    case sequential
    case random
    case single
}

/// WFMusicPlayer代理
public protocol WFMusicPlayerDelegate: class {
    
    /// 播放状态
    /// - Parameter musicPlayer: 当前播放器对象
    /// - Parameter state: 播放状态
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, playerStateDidChange state: WFMusicPlayerState)
    
    /// 更新播放进度、播放时间
    /// - Parameter musicPlayer: 当前播放器对象
    /// - Parameter progress: 播放进度
    /// - Parameter currentTime: 当前播放时间
    /// - Parameter currentTimeStr: 当前播放时间字符串
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, updateProgress progress: Float, currentTime: TimeInterval, currentTimeStr: String?)
    
    /// 更新加载进度、结束时间
    /// - Parameter musicPlayer: 当前播放器对象
    /// - Parameter progress: 加载进度
    /// - Parameter duration: 结束时间
    /// - Parameter totalTime: 结束时间字符串
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, updateLoadProgress progress: Float, duration: TimeInterval, totalTime: String)
    
    /// 是否在播放
    /// - Parameter musicPlayer: 当前播放器对象
    /// - Parameter playing: bool
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, playerIsPlaying playing: Bool)
    
    /// 当前播放 数据
    /// - Parameter musicPlayer: 当前播放器对象
    /// - Parameter playData: 当前播放 数据
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, playerCurrentPlayData playData: MusicData)
}

open class WFMusicPlayer: NSObject {

    open weak var delegate: WFMusicPlayerDelegate?
    /// 播放类型
    var playerMode : WFMusicPlayerMode?
    /// 播放器类
    lazy var musicPlayer: AVPlayer = {
        
        let player = AVPlayer()
        return player
    }()
    
//    /// AVPlayerItem提供了AVPlayer播放需要的媒体文件，时间、状态、文件大小等信息，是AVPlayer媒体文件的载体
//    var playerItem:AVPlayerItem?
    
    /// AVURLAsset: AVAsset的子类，可以根据一个URL路径创建一个包含媒体信息的AVURLAsset对象
    fileprivate var urlAsset:AVURLAsset?
    /// 播放列表
    var musicArray = [MusicData]()
    /// 当前播放下标
    var currentIndex: Int = 0
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
    
    /// 当前歌曲播放时间字符串
    var startTimeStr: String?
    /// 当前歌曲结束时间字符串
    var endTimeStr: String?
    /// 当前播放歌曲的进度
    var playProgress: Float = 0.0
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
                delegate?.wfMusicPlayer(musicPlayer: self, playerStateDidChange: state)
            }
        }
    }
    
    /// 时长
    var musicDuration: Float?
    /// 当前播放歌曲的加载进度
    var loadProgress: Float?
    /// 是否暂停
    var isPause: Bool?
    // 仅在bufferingSomeSecond里面使用  表示正在缓冲中
    fileprivate var isBuffering = false
}

extension WFMusicPlayer {

    /// 开始播放通过
    /// - Parameter url: 文件地址
    func play(_ url:URL) {
        
        self.removeObserver()
        self.urlAsset = AVURLAsset(url: url)
        // AVPlayerItem提供了AVPlayer播放需要的媒体文件，时间、状态、文件大小等信息，是AVPlayer媒体文件的载体
        let playerItem = AVPlayerItem(asset: self.urlAsset!)
        self.musicPlayer.replaceCurrentItem(with: playerItem)
        self.addObserver()
        if self.musicArray.count > 0 {
            
            delegate?.wfMusicPlayer(musicPlayer: self, playerCurrentPlayData: self.musicArray[self.currentIndex])
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
        self.play(URL.init(string: music.musicUrl!)!)
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
        self.play(URL.init(string: music.musicUrl!)!)
    }
    
    func currentPlayData() -> MusicData {
        
        let music = self.musicArray[self.currentIndex]
        return music
    }
    
}

// kvo 监听 AVPlayerItem属性变化
extension WFMusicPlayer {
    
    func addObserver() {
        
         //监控状态属性
        self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.status, options: NSKeyValueObservingOptions.new, context: nil)
        //监控网络加载情况属性
        self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.loadedTimeRanges, options: NSKeyValueObservingOptions.new, context: nil)
        //监听播放的区域缓存是否为空
        self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.playbackBufferEmpty, options: NSKeyValueObservingOptions.new, context: nil)
        //缓存可以播放的时候调用
        self.musicPlayer.currentItem?.addObserver(self, forKeyPath: ObserverKeyPath.playbackLikelyToKeepUp, options: NSKeyValueObservingOptions.new, context: nil)
    }
        
    func removeObserver() {
        
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.status)
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.loadedTimeRanges)
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.playbackBufferEmpty)
        self.musicPlayer.currentItem?.removeObserver(self, forKeyPath: ObserverKeyPath.playbackLikelyToKeepUp)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem, let keyPath = keyPath {
            
            if item == self.musicPlayer.currentItem {
                
                switch keyPath {
                case ObserverKeyPath.status:
                    let status = change?[NSKeyValueChangeKey.newKey] as! AVPlayerItem.Status
                    
                    if item.status == AVPlayerItem.Status.failed || self.musicPlayer.status == AVPlayer.Status.failed {
                        
                        self.state = WFMusicPlayerState.error
                    }
                    else if status == AVPlayerItem.Status.readyToPlay {
                        
                        
                    }
                    else if status == AVPlayerItem.Status.readyToPlay {
                                           
                                           
                    }
                case ObserverKeyPath.loadedTimeRanges:
                    // 计算缓冲进度
                    if let timeInterVarl = self.availableDuration() {
                        
                        let duration = item.duration
                        let totalDuration = CMTimeGetSeconds(duration)
                        let loadProgress = timeInterVarl/totalDuration
                        let currentTimeStr = changeStringForTime(timeInterval: timeInterVarl)
                        delegate?.wfMusicPlayer(musicPlayer: self, updateProgress: Float(loadProgress), currentTime: timeInterVarl, currentTimeStr: currentTimeStr)
                    }
                case ObserverKeyPath.playbackBufferEmpty:
                    if self.musicPlayer.currentItem!.isPlaybackBufferEmpty {
                        
                        self.bufferingSomeSecond()
                    }
                case ObserverKeyPath.playbackLikelyToKeepUp:
                    if self.musicPlayer.currentItem!.isPlaybackBufferEmpty {
                        if state != WFMusicPlayerState.bufferFinished {
                            self.state = .bufferFinished
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
                    self.delegate?.wfMusicPlayer(musicPlayer: self, playerStateDidChange: WFMusicPlayerState.bufferFinished)
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
