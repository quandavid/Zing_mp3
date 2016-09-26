//
//  TableViewOnline.swift
//  Zing_mp3
//
//  Created by Nguyen Dinh Quan on 9/15/16.
//  Copyright © 2016 Nguyen Dinh Quan. All rights reserved.
//

import UIKit
let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true).first
class TableViewOnline: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var listSongs = [Song]()
    
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
        getData()
    }
    func getData()  {
        let data = NSData(contentsOfURL:NSURL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html")!)
        let doc = TFHpple(HTMLData: data)//ho tro truy xuat du lieu
        if let elements = doc.searchWithXPathQuery("//h3[@class='title-item']/a") as? [TFHppleElement] {
            //http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\
            for element in elements {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let id = self.getID(element.objectForKey("href"))//get APISong
                    let url = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)//tao duong dan cho phep url chua '?,..'
                    //lay du lieu dang json
                    var stringData = ""
                    do{
                        stringData = try String(contentsOfURL: url!)
                        
                    }catch let error as NSError{
                        print(error)
                    }
                    //convertJson sang Dictionary
                    let json = self.convertStringToDictionary(stringData)
                    if (json != nil){//add du lieu vao mang listSong
                        self.addSongToList(json!)
                    }
                    
                })
            }
        }
        
        
    }
    
    func convertStringToDictionary(string:String) -> [String:AnyObject]? {
        //  chuyen doi string sang nsData
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        {do{//chuyen doi tu NSData sang Dictionary
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
            return json!
        }catch{
            print("error")
            }
            
            
        }
        
        return nil
    }
    
    func addSongToList(json:[String:AnyObject]) {
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = json["source"]!["128"] as! String
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source)
        listSongs.append(currentSong)
        //cac func load giao dien pai chay trong mainThread
        dispatch_async(dispatch_get_main_queue()) { 
            self.myTableView.reloadData()
        }
        

    }
    func getID(path:NSString) -> String {//cat string
        let id = (path.lastPathComponent as NSString).stringByDeletingPathExtension
        return id
    }
    //UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = listSongs[indexPath.row].title
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = listSongs[indexPath.row].sourceOnline
        audioPlay.titleSong = "\(listSongs[indexPath.row].title) Ca Sy: \(listSongs[indexPath.row].artistName)"
        audioPlay.setupAudio()
        NSNotificationCenter.defaultCenter().postNotificationName("setupObserverAudio", object: nil)
        
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "Download") { (action, index) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                self.downloadSong(indexPath.row)
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.myTableView.reloadData()
            }
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func downloadSong(index:Int)  {
        let dataSong = NSData(contentsOfURL: NSURL(string: listSongs[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            //writing
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            do{
                //tao folder
                try NSFileManager.defaultManager().createDirectoryAtPath(pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            //ghi bai hat
            writeDataToPath(dataSong!,path:"\(pathToWriteSong)/\(listSongs[index].title).mp3")
            // ghi ra thong tin bai hat
            writeInfoSong(listSongs[index],path:pathToWriteSong)
            
        }
        
    }
    func writeInfoSong(song: Song,path :String){
        let dicData = NSMutableDictionary()
        dicData.setValue(song.title, forKey: "title")
        dicData.setValue(song.artistName, forKey: "artistName")
        dicData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dicData.setValue(song.sourceOnline, forKey: "sourceOnline")
        //writing info
        writeDataToPath(dicData, path: "\(path)/info.plist")
        //writing thumbnail
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!)
        writeDataToPath(dataThumbnail, path: "\(path)/thumbnail.png")
    }
    func writeDataToPath(data: NSObject,path:String){
        if let dataToWrite = data as? NSData{
        dataToWrite.writeToFile(path, atomically: true)
        }
        else if let dataInfo = data as? NSDictionary{
            dataInfo.writeToFile(path, atomically: true)
        }
    }
}
