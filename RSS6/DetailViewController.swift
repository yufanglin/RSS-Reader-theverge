//
//  DetailViewController.swift
//  RSS6
//
//  Created by Yufang Lin on 21/10/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // The article that was selected by users from tableview
    var articleToDisplay: Article?
    
    // The web view that displays the article object
    @IBOutlet weak var webView: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Optional Binding: Check if article been set 
        if let actualArticle = articleToDisplay {
            // create url object on article's linke
            let url = URL(string: actualArticle.articleLink)
            
            // Optional Binding: in case url not found
            if let actualUrl = url {
                // create url request on url
                let request = URLRequest(url: actualUrl)
                
                // Load request to web view
                webView.loadRequest(request)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
