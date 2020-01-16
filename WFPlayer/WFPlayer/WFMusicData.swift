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
