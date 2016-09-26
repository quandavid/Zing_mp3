//
//  AudioPlayer.swift
//  Zing_mp3
//
//  Created by Nguyen Dinh Quan on 9/17/16.
//  Copyright © 2016 Nguyen Dinh Quan. All rights reserved.
//

import UIKit
import AVFoundation
class AudioPlayer: NSObject {

    class var sharedInstance: AudioPlayer {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AudioPlayer? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = AudioPlayer()
        }
        return Static.instance!
    }
    var pathString = ""
    var repeating = false
    var playing = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = ""
    var player = AVPlayer()
    func setupAudio(){
        var url = NSURL()
        if let checkURL = NSURL(string: pathString)
        {
            url = checkURL
        }else{
                url = NSURL(fileURLWithPath: pathString)
        }
        let playerItem = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.volume = 0.5
        player.play()
        playing = true
        repeating = true
       
    }
    func action_repeatSong(repeatSong:Bool){
        if repeatSong == true {
            repeating = true
        }
        else{
            repeating = false
        }
    }
    func action_PlayPause()  {
        if playing == false{
            player.play()
            playing = true
        }else{
            player.pause()
            playing = false
        }
    }
    func action_sld_Duration(value:Float){
        let timeToSeek = value * duration        //1 10 -> 1/10 = 0.1
        let time = CMTime(value: Int64(timeToSeek), timescale: 1)
        player.seekToTime(time)
    }
    func action_sld_volume(value:Float)  {
        player.volume = value
        
    }
    
}
