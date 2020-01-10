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
 
 - notSetURL:      没有URL
 - readyToPlay:    准备播放的播放器
 - buffering:      播放器缓冲
 - bufferFinished:  缓冲区完成
 - playedToTheEnd: 播放到结尾
 - error:          播放错误
 */
public enum WFMusicPlayerState {
    
    case notSetURL
    case readyToPlay
    case buffering
    case bufferFinished
    case playedToTheEnd
    case error
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
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, updateProgress progress: Float, currentTime: TimeInterval, currentTimeStr: String)
    
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
    func wfMusicPlayer(musicPlayer: WFMusicPlayer, playerCurrentPlayData playData: Any)
}

open class WFMusicPlayer: NSObject {

    open weak var delegate: WFMusicPlayerDelegate?
    
    /// 播放器类
    lazy var musicPlayer: AVPlayer? = {
        
        let player = AVPlayer()
        return player
    }()
    
    
    
    
    
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
