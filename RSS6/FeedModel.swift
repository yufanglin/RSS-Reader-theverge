//
//  FeedModel.swift
//  RSS6
//
//  Created by Yufang Lin on 21/10/2017.
//  Copyright © 2017 Yufang Lin. All rights reserved.
//

import UIKit

protocol FeedModelDelegate {
    func articlesReady()
}

class FeedModel: NSObject, XMLParserDelegate {
    
    // Article Variables
    var url = "https://www.theverge.com/rss/index.xml"
    var articles = [Article]()
    
    // Delegate Variable
    var delegate: FeedModelDelegate?
    
    // Parsing Variables
    var constructingArticle: Article?
    var constructingString = ""
    var linkAttributes = [String:String]()
    
    // ---------- Start Download/Parsing Function ---------- \\
    func getArticles() {
        // ---- Download/Parsing RSS Feed ---- \\
        
        // Create url object on the rss feed link
        let feedUrl = URL(string: url)
        
        // Optional Binding: in case url not found 
        if let actualUrl = feedUrl {
            // Create parser object on url
            let parser = XMLParser(contentsOf: actualUrl)
            
            // Optional Binding: in parser, in case url cannot be parsed
            if let actualParser = parser {
                // set parser delegate to FeedModel
                actualParser.delegate = self
                
                // Start parsing the rss feed
                actualParser.parse()
            }
        }
    }
    
    
    // ---------- Parsing Functions ---------- \\
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // -- Function called when parser found the starting tag -- \\
        // ---- We only care about Entry, Title, Content, and Link tags ---- \\
        
        // Check if Entry starting tag
        if elementName == "entry" {
            // initialize constructing article
            constructingArticle = Article()
        }
        
        // Check if Link starting tag
        else if elementName == "link" {
            // save the attributes
            linkAttributes = attributeDict
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // -- Function called when parser found characters between tags -- \\
        // ---- We only care about Title, Content, and Link tags ---- \\
        
        // Check if there is an article to parse
        if constructingArticle != nil {
            // save the set of characters 
            constructingString += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // -- Function called when parser found ending tags -- \\
        // ---- We only care Entry, Title, Content, and Link tags ---- \\
        
        // Check if Entry tag was found
        if elementName == "title" {
            // trim off the whitespaces/newlines from constructingString
            let title = constructingString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Save the trimmed string as the article's title
            constructingArticle?.articleTitle = title
        }
        
        // Check if Content tag was found
        else if elementName == "content" {
            // Save the constructing string as the article's body
            constructingArticle?.articleBody = constructingString
            
            
            // Optional Binding: find the image url if there is one, by looking for http start range
            if let startRange = constructingString.range(of: "http") {
                // Optional Binding: image found, loop for end range of ".jpg". Might be a different
                if let endRange = constructingString.range(of: ".jpg") {
                    // Get the substring of start/end ranges from constrainting string
                    let substring = constructingString.substring(with: startRange.lowerBound ..< endRange.upperBound)
                    
                    // save substring as the article's image url
                    constructingArticle?.articleImageUrl = substring
                }
                
                // Optional Binding: in case image ends with ".png", find the end range
                else if let endRange = constructingString.range(of: ".png") {
                    // Get substring with start/end ranges from constructing string 
                    let substring = constructingString.substring(with: startRange.lowerBound ..< endRange.upperBound)
                    
                    // save the substring as the article's image url
                    constructingArticle?.articleImageUrl = substring
                }
            }
        }
        
        // Check if Link tag was found
        else if elementName == "link" {
            // Optional Binding: in case href key not found
            if let value = linkAttributes["href"] {
                // save href's value as the article's link
                constructingArticle?.articleLink = value
            }
        }
            
        // Check if Entry tag was found
        else if elementName == "entry" {
            // Optional Binding: In case article object not initialized
            if let actualArticle = constructingArticle {
                // Save article to array
                articles += [actualArticle]
            }
            
            // Reset article object for next article
            constructingArticle = nil
        }
        
        // Reset constructingString for the next set of characters between tags
        constructingString = ""
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // -- Function called when parser finish parsing -- \\
        // ---- We want to notify the delegate (ViewController) of this ---- \\
        
        // Optional Binding: Check if the delegate has been set (in this case, ViewController)
        if let actualDelegate = delegate {
            // Call the delegate's function to set it's array of articles
            actualDelegate.articlesReady()
        }
    }
}
