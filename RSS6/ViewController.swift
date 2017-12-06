//
//  ViewController.swift
//  RSS6
//
//  Created by Yufang Lin on 21/10/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FeedModelDelegate, UITableViewDelegate, UITableViewDataSource{
    
    // Article Variables
    var model = FeedModel()
    var articles = [Article]()
    var selectedArticle: Article?
    
    // Table View Variable
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set ViewController's tableView's delegate/dataSource to ViewController
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set FeedMode's delegate to ViewController so FeedModel can notify it when parsing is done
        model.delegate = self
        
        // Start parsing/downloading the articles
        model.getArticles()
        
        // create title icon
        createTitleIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ---------- ViewController Function ---------- \\
    func createTitleIcon() {
        // Create image view object, this is our icon without image set
        let imageView = UIImageView()
        
        // Set imageView's autolayout defaults to false, set manually
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create height constraint of 33 for imageView
        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 33)
        
        // Create width constraint of 41 for imageView
        let widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 41)
        
        // Add constraints to imageView
        imageView.addConstraints([heightConstraint, widthConstraint])
        
        // set the image
        imageView.image = UIImage(named: "vergeicon")
        
        // add imageview to navigation title
        navigationItem.titleView = imageView
    }

    // ---------- FeedModel Function ---------- \\
    func articlesReady() {
        // -- Called when FeedModel finish parsing and set's ViewController's article array -- \\
        articles = model.articles
    }
    
    // ---------- Table View Function ---------- \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of table entries, in this case, number of articles 
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a cell to reuse with an identy of BasicCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        
        // Get the article at row index from the articles array
        let article = articles[indexPath.row]
        
        
        // Get label and imageView from cell (tag 1 & 2)
        let label = cell.viewWithTag(1) as? UILabel
        let imageView = cell.viewWithTag(2) as? UIImageView
        
        
        // Optional Binding: in case label not found
        if let actualLabel = label {
            // set the label's text with the Article's title
            actualLabel.text = article.articleTitle
        }
        
        
        // Optional Binding: in case imageView not found
        if let actualImageView = imageView {
            // Check if article has an image to display
            if article.articleImageUrl != nil {
                // Create url object on the image url
                let url = URL(string: article.articleImageUrl)
                
                // Optional Binding: in case url not found
                if let actualUrl = url {
                    // create request object on url
                    let request = URLRequest(url: actualUrl)
                    
                    // Get the current url session
                    let session = URLSession.shared
                    
                    // Create session data task with request object and data, response, error as arguments
                    let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                        // Move task to main thread for faster loading
                        DispatchQueue.main.async {
                            // Optional binding: check if there is data to pass
                            if let actualData = data {
                                // set the image to display with data
                                actualImageView.image = UIImage(data: actualData)
                            }
                        }
                    })
                    
                    // Fire off data task
                    dataTask.resume()
                }
            }
            else {
                // -- No image to display, so prevent cell from reusing other article's images when tableview is being scrolled
                
                // set the image to nil
                actualImageView.image = nil
            }
        }
        
        // Return the set cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // -- Called when user taps on an article -- \\
        
        // Keep track of tapped article entry
        selectedArticle = articles[indexPath.row]
        
        // Trigger segue to display the article, which is show in the DetailViewController class
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // -- Called before segue is performed -- \\
        
        // Get the destination of the segue
        let dvc = segue.destination as! DetailViewController
        
        // set the tapped article to be displayed in DetailViewController
        dvc.articleToDisplay = selectedArticle
    }
}

