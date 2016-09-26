//
//  Song.swift
//  Zing_mp3
//
//  Created by Nguyen Dinh Quan on 9/15/16.
//  Copyright © 2016 Nguyen Dinh Quan. All rights reserved.
//
import Foundation
import UIKit

struct Song {
    var title = ""
    var artistName = ""
    var thumbnail: UIImage
    var sourceOnline = ""
    var sourceLocal = ""
    var localThumbnail = ""
    let baseThumbnail = "http://image.mp3.zdn.vn//thumb/240_240/"
    //lay du lieu online
    init(title: String,artistName:String,thumbnail:String,source:String){
        self.title = title
        self.artistName = artistName
        let thumbnailURL = baseThumbnail + thumbnail
        let dataImage = NSData(contentsOfURL: NSURL(string: thumbnailURL)!)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceOnline = source
        
    }
    //lay du lieu local
    init(title:String,artistName:String,localThumbnail:String,localSource:String){
        self.title = title
        self.artistName = artistName
        self.localThumbnail = localThumbnail
        let dataImage = NSData(contentsOfFile: self.localThumbnail)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceLocal = localSource
    }
}