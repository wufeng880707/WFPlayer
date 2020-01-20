//
//  WFMusicPlayerProtocol.swift
//  WFPlayer
//
//  Created by xiantiankeji on 2020/1/20.
//  Copyright © 2020 tomodel. All rights reserved.
//

import Foundation

/// WFMusicPlayer代理
public protocol WFMusicPlayerProtocol: class {
    
    /// 播放状态
    /// - Parameter state: 播放状态
    func wfMusicPlayer(playerStateDidChange state: WFMusicPlayerState)
    
    /// 更新播放进度、播放时间
    /// - Parameter progress: 播放进度
    /// - Parameter currentTime: 当前播放时间
    /// - Parameter currentTimeStr: 当前播放时间字符串
    func wfMusicPlayer(updateProgress progress: Float, currentTime: TimeInterval, currentTimeStr: String?)
    
    /// 更新加载进度、结束时间
    /// - Parameter progress: 加载进度
    /// - Parameter duration: 结束时间
    /// - Parameter totalTime: 结束时间字符串
    func wfMusicPlayer(updateLoadProgress progress: Float, duration: TimeInterval, totalTime: String?)
    
    /// 是否在播放
    /// - Parameter playing: bool
    func wfMusicPlayer(playerIsPlaying playing: Bool)
    
    /// 当前播放 数据
    /// - Parameter playData: 当前播放 数据
    func wfMusicPlayer(playerCurrentPlayData playData: MusicData)
}
