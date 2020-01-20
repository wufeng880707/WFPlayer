//
//  WFMusicData.swift
//  WFPlayer
//
//  Created by xiantiankeji on 2020/1/16.
//  Copyright © 2020 tomodel. All rights reserved.
//

import Foundation

/**
 歌曲数据
 
 - musicUrl：        音频地址
 - musicName：   音频名
 - musicSinger：  歌手名
 - musicAlbum：  专辑名
 - musicImage：  专辑图片
 - musicLyric：     歌词
 */
public struct MusicData {
    
    var musicUrl:   String?
    var musicName:  String?
    var musicSinger:String?
    var musicAlbum: String?
    var musicImage: String?
    var musicLyric: String?
    
    init(url: String, name: String, singer: String, album: String, image: String, lyric: String) {
        
        self.musicUrl       = url
        self.musicName      = name
        self.musicSinger    = singer
        self.musicAlbum     = album
        self.musicImage     = image
        self.musicLyric     = lyric
    }
}

/**
 播放器播放状态 emun
 
 - notSetURL:                           没有URL
 - preparing:                              准备播放
 - beigin:                                   开始播放
 - playing:                                 正在播放
 - pause:                                   播放暂停
 - end:                                       播放结束
 - bufferEmpty:                         没有缓存的数据供播放了
 - bufferToKeepUp:                   有缓存的数据可以供播放
 - seekToZeroBeforePlay:        播放器缓冲
 - notPlay:                                 不能播放
 - notKnow:                               未知情况
 */
public enum WFMusicPlayerState {
    
    case notSetURL
    case preparing
    case beigin
    case playing
    case pause
    case end
    case bufferEmpty
    case bufferToKeepUp
    case seekToZeroBeforePlay
    case notPlay
    case notKnow
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
