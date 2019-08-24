//
//  File.swift
//  News Reader
//
//  Created by riku on 2019/08/14.
//  Copyright © 2019 Riku Takahashi. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Alamofire
import HTMLReader

class ListViewController: UITableViewController, XMLParserDelegate {
    
    var parser :XMLParser!
    var items = [Item]()
    var item :Item?
    var currentString = ""
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        cell.newsTitle.text = items[indexPath.row].title
        cell.newsImage!.contentMode = .scaleAspectFill

        
//        var imageURL = URL(string: "https://placehold.jp/150x150.png")
//        cell.newsImage.sd_setImage(with: imageURL)
        cell.newsImage.image = UIImage(named: "defaultImage")
        
        Alamofire.request(items[indexPath.row].link, method: .get).responseString { response in
            if response.result.isFailure {
                print(response.result.error!)
                return
            }
            
            let html = HTMLDocument(string: response.result.value!)
            let ogTags:[HTMLElement] = html.nodes(matchingSelector: "meta[property^=\"og:\"]")
            var dict = Dictionary<String, String>()
            
            ogTags.forEach {
                let property = $0.attributes["property"]!
                let content = $0.attributes["content"]!
                dict[property] = content
            }
            
            cell.siteName.text = dict["og:site_name"]
            cell.newsImage.sd_setImage(with: URL(string: dict["og:image"]!))
        }
        return cell
    }
    
//    func getImageUrl(_ url: String) -> URL {
//        //ロックの取得
////        var keepAlive = true
//
//        var imageURL = URL(string: "https://placehold.jp/150x150.png")
//        Alamofire.request(url, method: .get).responseString { response in
//            if response.result.isFailure {
//                print(response.result.error!)
////                keepAlive = false
//                return
//
//            }
//
//            let html = HTMLDocument(string: response.result.value!)
//
//            let ogTags:[HTMLElement] = html.nodes(matchingSelector: "meta[property^=\"og:image\"]")
//
//            var dict = Dictionary<String, String>()
//            ogTags.forEach {
//                let property = $0.attributes["property"]!
//                let content = $0.attributes["content"]!
//                dict[property] = content
//            }
//            imageURL = URL(string: dict["og:image"]!)
////            self.tableView.reloadData()
////            keepAlive = false
//        }
//        //ロックが解除されるまで待つ
////        let runLoop = RunLoop.current
////        while keepAlive &&
////            runLoop.run(mode: RunLoop.Mode.default, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
////                // 0.1秒毎の処理なので、処理が止まらない
////        }
//        return imageURL!
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        startDownload()
    }
    
    func startDownload() {
        self.items = []
        if let url = URL(string: "https://www.climbing-net.com/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
//        if let url = URL(string: "https://micki-pedia.com/feed/") {
//            if let parser = XMLParser(contentsOf: url) {
//                self.parser = parser
//                self.parser.delegate = self
//                self.parser.parse()
//            }
//        }
//        if let url = URL(string: "https://bouldering-club.com/feed/") {
//            if let parser = XMLParser(contentsOf: url) {
//                self.parser = parser
//                self.parser.delegate = self
//                self.parser.parse()
//            }
//        }
//        if let url = URL(string: "http://bouldering-style.com/feed//") {
//            if let parser = XMLParser(contentsOf: url) {
//                self.parser = parser
//                self.parser.delegate = self
//                self.parser.parse()
//            }
//        }
//        if let url = URL(string: "https://climbers-web.jp/feed/") {
//            if let parser = XMLParser(contentsOf: url) {
//                self.parser = parser
//                self.parser.delegate = self
//                self.parser.parse()
//            }
//        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.currentString = ""
        if elementName == "item" {
            self.item = Item()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            self.item?.title = currentString
        case "link":
            self.item?.link = currentString
        case "item":
            self.items.append(self.item!)
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let item = items[indexPath.row]
            let controller = segue.destination as! DetailViewController
            controller.title = item.title
            controller.link = item.link
        }
    }
}
//extension UIImageView {
//    func loadWebImage(url:NSURL!){
//        self.sd_setImageWithURL(url)
//    }
//
//    func loadWebImage(url:NSURL!, placeholderImage:UIImage!) {
//        self.sd_setImageWithURL(url, placeholderImage: placeholderImage)
//    }
//
//    func loadWebImage(url:NSURL!, placeholderImage:UIImage!,completeion:SDWebImageCompletionBlock){
//        self.sd_setImageWithURL(url, placeholderImage: placeholderImage, completed: completeion)
//    }
//}
