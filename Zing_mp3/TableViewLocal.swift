//
//  TableViewLocal.swift
//  Zing_mp3
//
//  Created by Nguyen Dinh Quan on 9/16/16.
//  Copyright © 2016 Nguyen Dinh Quan. All rights reserved.
//

import UIKit

class TableViewLocal: UIViewController,UITableViewDelegate,UITableViewDataSource {
var listSongs = [Song]()
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
        getData()

        
    }
    override func viewWillAppear(animated: Bool) {
        getData()
    }
    
    func getData()  {
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH
        {
            do{
               let folders = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
                for folder in folders {
                    if (folder != ".DS_Store") {
                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
                        let title = info!["title"]as! String
                        let artistName = info!["artistName"]as! String
                        let thumbnailPath = info!["localThumbnail"]as!String
                        let sourceLocal = dir + "/\(title)/\(title).mp3"
                        let localThumbnail = dir + thumbnailPath
                        let currentSong = Song(title: title, artistName: artistName, localThumbnail: localThumbnail, localSource: sourceLocal)
                        listSongs.append(currentSong)
                        
                    }
                }
                myTableView.reloadData()
                
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
   //UITableView
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
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "Delete") { (action, index) in
         self.removeSongAtIndex(indexPath.row)
            
                self.myTableView.reloadData()
            
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = listSongs[indexPath.row].sourceLocal
        audioPlay.titleSong = "\(listSongs[indexPath.row].title) Ca Sy: \(listSongs[indexPath.row].artistName)"
        audioPlay.setupAudio()
        NSNotificationCenter.defaultCenter().postNotificationName("setupObserverAudio", object: nil)
        
    }
    func removeSongAtIndex(index: Int){
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do{
                let path = dir + "/\(listSongs[index].title)"
                try NSFileManager.defaultManager().removeItemAtPath(path)
                listSongs.removeAtIndex(index)
                self.myTableView.reloadData()
            }catch let error as NSError{
                print(error)
            }
        }
    }
}
