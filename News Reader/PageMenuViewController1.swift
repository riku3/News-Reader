//
//  PageMenuViewController2.swift
//  News Reader
//
//  Created by riku on 2019/09/07.
//  Copyright © 2019 Riku Takahashi. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class PageMenuViewController1: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListViewController.articles1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //カスタムセルを定義
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        cell.newsTitle.text = ListViewController.articles1[indexPath.row].title
        cell.newsImage.sd_setImage(with: URL(string: ListViewController.articles1[indexPath.row].image)!)
        cell.siteName.text = ListViewController.articles1[indexPath.row].site_name
        return cell
    }

    //詳細画面へのNavigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let article = ListViewController.articles1[indexPath.row]
            let controller = segue.destination as! DetailViewController
            controller.modalPresentationStyle = .fullScreen
            controller.title = article.site_name
            controller.link = article.link
        }
    }
}
