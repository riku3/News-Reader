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
        
        if cell.newsTitle.text != items[indexPath.row].title {
            cell.newsTitle.text = items[indexPath.row].title
        }
        if cell.newsImage.image == nil {
            cell.newsImage.image = UIImage(named: "defaultImage")
        }
        
        if items[indexPath.row].site_name != nil || items[indexPath.row].newsImage != nil {
            cell.siteName.text = items[indexPath.row].site_name
            cell.newsImage.sd_setImage(with: items[indexPath.row].newsImage)
        } else {
            
            //セルが再利用される場合の初期化 //TODO:サイト名も初期化する
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
                cell.newsImage.sd_setImage(with: URL(string: dict["og:image"]!)!)
                
                //TODO サイト名、画像が取得できない場合にエラーとなるため対応必須
                self.items[indexPath.row].site_name = dict["og:site_name"]
                self.items[indexPath.row].newsImage = URL(string: dict["og:image"]!)!
            }
        }
        return cell
    }
    
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
