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
        //カスタムセルを定義
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        //記事タイトルを代入(if分はセルの再利用対応)
        if cell.newsTitle.text != items[indexPath.row].title {
            cell.newsTitle.text = items[indexPath.row].title
        }
        //デフォルトの画像を設定
        if cell.newsImage.image == nil {
            cell.newsImage.image = UIImage(named: "defaultImage")
        }
        
        //image_nameはhttp以外のURLの場合はnilとするため条件に含めない
        if items[indexPath.row].site_name != nil {
            //一度セルを利用している場合(セルを生成する際にサイト名と画像を設定している)
            
            //itemクラスで設定したサイト名と画像を設定
            cell.siteName.text = items[indexPath.row].site_name
            if items[indexPath.row].newsImage != nil {
                //image_nameはhttp以外のURLの場合はnilとなるため、取得できる場合のみ設定
                cell.newsImage.sd_setImage(with: items[indexPath.row].newsImage)
            } else {
                //image_nameはhttp以外のURLの場合はnilとなるため、取得できない場合デフォルト画像を設定
                cell.newsImage.image = UIImage(named: "defaultImage")
            }
        } else {
            //新しくセルを利用する場合
            
            //セルが再利用されている場合の初期化 //TODO:サイト名も初期化する
            cell.newsImage.image = UIImage(named: "defaultImage")
            
            //非同期のAPI処理(URL先からサイト名と画像を取得している)
            Alamofire.request(items[indexPath.row].link, method: .get).responseString { response in
                //処理が失敗した場合
                if response.result.isFailure {
                    print(response.result.error!)
                    return
                }
                
                //URL先からHTMLドキュメントを取得
                let html = HTMLDocument(string: response.result.value!)
                //HTMLドキュメントからogタグを取得
                let ogTags:[HTMLElement] = html.nodes(matchingSelector: "meta[property^=\"og:\"]")
                var dict = Dictionary<String, String>()
                
                //ogタグの情報を辞書型で設定
                ogTags.forEach {
                    let property = $0.attributes["property"]!
                    let content = $0.attributes["content"]!
                    dict[property] = content
                }
                
                //取得してきたサイト名をセルに設定
                cell.siteName.text = dict["og:site_name"]
                
                //TODO：サイト名、画像が取得できない場合にエラーとなるため対応必須
                //API処理をもう一度しないように、itemクラスのサイト名を設定
                self.items[indexPath.row].site_name = dict["og:site_name"]
                //imageURLをhttpに限定する(他の場合だと画像を読み込めない場合があるため)
                if (dict["og:image"]?.range(of: "http")) != nil {
                    //取得してきた画像をセルに設定
                    cell.newsImage.sd_setImage(with: URL(string: dict["og:image"]!)!)
                    //API処理をもう一度しないように、itemクラスの画像を設定
                    self.items[indexPath.row].newsImage = URL(string: dict["og:image"]!)!
                }
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
    
    //RSSデータのダウンロード
    func startDownload() {
        self.items = []
        //山と溪谷社のクライミング・ボルダリング総合サイト CLIMBING-net クライミングネット
        if let url = URL(string: "https://www.climbing-net.com/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
        //Mickipedia - ミキペディア｜クライミングをもっと考えたい全ての人へ
        if let url = URL(string: "https://micki-pedia.com/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
        //クライマーズ公式サイト｜CLIMBERSはクライミング、ボルダリングをテーマにした総合WEBサイト
        if let url = URL(string: "https://climbers-web.jp/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
        //ALLEZ〜ボルダリング上達応援ブログ&No. 1サイト
        if let url = URL(string: "https://chums.jp.net/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
        //クライマニア
        if let url = URL(string: "http://climb-mania.com/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
        //Climbing.UP
        if let url = URL(string: "https://climbingup2.net/feed/") {
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
    }
    
    //要素名(elementName)の開始たタグが見つかる毎に呼び出されるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.currentString = ""
        if elementName == "item" {
            self.item = Item()
        }
    }
    //要素(タブ内の内容)が見つかる毎に呼び出されるメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString += string
    }
    
    //要素名(elementName)の終了たタグが見つかる毎に呼び出されるメソッド
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            self.item?.title = currentString
        case "link":
            self.item?.link = currentString
        case "pubDate":
            self.item?.pubDate = currentString
        case "item":
            self.items.append(self.item!)
        default:
            break
        }
    }
    
    //全てのRSSデータの解析が終了した時に呼び出されるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        
        //TODO:コードを綺麗に整形する dateFormatter.localを使う必要があるか？
        //pubDateの降順に設定
        items = items.sorted(by: { (a, b) -> Bool in
                let dateFormatter = DateFormatter()
                // 書式が変わらない固定ロケールで一度値を取得
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
                
                let a_date = dateFormatter.date(from: a.pubDate)
                let b_date = dateFormatter.date(from: b.pubDate)
            return a_date! > b_date!
        })
        self.tableView.reloadData()
    }
    
    //詳細画面へのNavigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let item = items[indexPath.row]
            let controller = segue.destination as! DetailViewController
            controller.title = item.title
            controller.link = item.link
        }
    }
}
