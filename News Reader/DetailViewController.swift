//
//  DetailViewController.swift
//  News Reader
//
//  Created by riku on 2019/08/14.
//  Copyright © 2019 Riku Takahashi. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var link:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: self.link) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    // シェアボタン
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        let activityItems: Array<String> = [self.link]
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
}
