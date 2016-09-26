//
//  AudioPlayerView.swift
//  Zing_mp3
//
//  Created by Nguyen Dinh Quan on 9/17/16.
//  Copyright © 2016 Nguyen Dinh Quan. All rights reserved.
//

import UIKit
import AVFoundation
class AudioPlayerView: UIViewController {
let audioPlayer = AudioPlayer.sharedInstance
    @IBOutlet weak var btn_Play: UIButton!
    @IBOutlet weak var lbl_CurrentTime: UILabel!
    @IBOutlet weak var lbl_TotalTime:UILabel!
    @IBOutlet weak var sld_Duration: UISlider!
    @IBOutlet weak var sld_Volume: UISlider!
    @IBOutlet weak var lbl_title:UILabel!
    @IBOutlet weak var sw_repeat: UISwitch!
    var checkAddObserverAudio = false
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_Play.enabled = false
        sld_Duration.enabled = false
        sld_Volume.enabled = false
        sw_repeat.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setupObserverAudio), name: "setupObserverAudio", object: nil)
        setupObserverAudio()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        changeInfoView()
    }
    func changeInfoView()  {
        changeInfoSong()
        addThumbImgForButton()
    }
    func changeInfoSong()  {
        lbl_title.text = audioPlayer.titleSong
    }
    func addThumbImgForButton()  {
        if audioPlayer.playing == true {
            btn_Play.setBackgroundImage(UIImage(named: "pause.png"), forState: .Normal)
        }else{
            btn_Play.setBackgroundImage(UIImage(named: "play.png"), forState: .Normal)
        }
    }
    func setupObserverAudio() {
        if (audioPlayer.playing && !checkAddObserverAudio ){
            checkAddObserverAudio = true
            btn_Play.enabled = true
            sld_Volume.enabled = true
            sld_Duration.enabled = true
            sw_repeat.enabled = true
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidReachEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
        changeInfoView()
    }
    func playerItemDidReachEnd(nitification : NSNotification) {
        if audioPlayer.repeating {
            audioPlayer.player.seekToTime(kCMTimeZero)
            audioPlayer.player.play()
        }
    }
    func timeUpdate()  {
        //CMTime time , timescale => s = time/timescale
        audioPlayer.duration = Float((audioPlayer.player.currentItem?.duration.value)!)/Float((audioPlayer.player.currentItem?.duration.timescale)!)
        
        audioPlayer.currentTime = Float(audioPlayer.player.currentTime().value)/Float(audioPlayer.player.currentTime().timescale)
        
        let m = Int(floor(audioPlayer.currentTime/60))
        let s = Int(round(audioPlayer.currentTime - Float(m)*60))
        if audioPlayer.duration > 0 {
            let mduration = Int(floor(audioPlayer.duration/60))
            let sduration = Int(round(audioPlayer.duration - Float(mduration)*60))
            self.lbl_CurrentTime.text = String(format: "%02d",m) + ":" + String(format: "%02d", s)
            self.lbl_TotalTime.text = String(format: "%02d",mduration) + ":" + String(format: "%02d", sduration)
            self.sld_Duration.value = Float(audioPlayer.currentTime/audioPlayer.duration)
            self.sld_Volume.value = audioPlayer.player.volume

            
        }
        
        
        
        
    }
    //Action
    @IBAction func action_repeatSong(sender: UISwitch)
    {
        audioPlayer.action_repeatSong(sender.on)
    }
    @IBAction func action_PlayPause(sender: AnyObject){
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
    }
    @IBAction func sld_Duration(sender:UISlider)
    {
        audioPlayer.action_sld_Duration(sender.value)
    }
    @IBAction func sld_Volume(sender: UISlider){
        audioPlayer.action_sld_volume(sender.value)
    }

  
}
