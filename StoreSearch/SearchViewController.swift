//
//  ViewController.swift
//  StoreSearch
//
//  Created by Ike Mattice on 7/5/16.
//  Copyright © 2016 Ike Mattice. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    struct TableViewCellIdentifiers {
        static let searchResultsCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    func kindForDisplay(kind: String) -> String {
        switch kind {
            case "album": 
                return "Album"
            case "audiobook": 
                return "Audio Book"
            case "book": 
                return "Book"
            case "ebook": 
                return "E-Book"
            case "feature-movie": 
                return "Movie"
            case "podcast": 
                return "Podcast"
            case "software": 
                return "App"
            case "song": 
                return "Song"
            case "tv-episode": 
                return "TV Episode"
            default: 
                return kind
        }
    }
    
    func urlWithSearchText(searchText: String) -> NSURL {
    //remove characters that don't work well in urls, such as spaces
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
    //build the url
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    func performStoreRequestWithURL(url: NSURL) -> String? {
        do {
            //return a JSON string from the server
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        //tell the data you are working with UTF-8 encoding
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else {return nil}
        //try to turn the json data into dictonary
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult]{
        //check to make sure there is a results key
        guard let array = dictionary["results"] as? [AnyObject] else {
            print ("Expected 'results' array")
            return []
        }
        var searchResults = [SearchResult]()
        
        for resultDict in array {
            //since this is an objective c api, you need to cast the object as a dictionary instead of an AnyObject
            if let resultDict = resultDict as? [String: AnyObject] {
                
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                        case "track":
                            searchResult = parseTrack(resultDict)
                        case "audiobook" :
                            searchResult = parseAudioBook(resultDict)
                        case "software":
                            searchResult = parseSoftware(resultDict)
                        default:
                            break
                    }
                } else if let kind = resultDict["kind"] as? String
                    where kind == "ebook" {
                    searchResult = parseEBook(resultDict)
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String 
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String 
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String 
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double { 
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult { 
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String 
        searchResult.artistName = dictionary["artistName"] as! String 
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String 
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String 
        searchResult.storeURL = dictionary["trackViewUrl"] as! String 
        searchResult.kind = dictionary["kind"] as! String 
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double { 
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre 
        }
        return searchResult 
    }  
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult { 
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String 
        searchResult.artistName = dictionary["artistName"] as! String 
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String 
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String 
        searchResult.storeURL = dictionary["trackViewUrl"] as! String 
        searchResult.kind = dictionary["kind"] as! String 
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double { 
            searchResult.price = price
        }
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ") 
        }
        return searchResult 
    }
    
    func showNetworkError() {
        //build and show an alert
        let alert = UIAlertController (
            title: "Oops...",
            message: "There was an error reading from the iTunesStore.  Please try again.",
            preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //prompt keyboard to open once app is launched
        searchBar.becomeFirstResponder()
    //register nibs
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultsCell, bundle: nil)
        searchResultsTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultsCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        searchResultsTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        searchResultsTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    //STYLES:
        searchResultsTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        searchResultsTableView.rowHeight = 80
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
        
        //hide the keyboard once the Search button is clicked
            searchBar.resignFirstResponder()
            isLoading = true
            hasSearched = true

            searchResultsTableView.reloadData()
            
        //provide search results
            searchResults = [SearchResult]()
            
            //allow for asychronous requests by building a closure and placing it into the main dispatch queue
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            dispatch_async(queue) {
                let url = self.urlWithSearchText(searchBar.text!)
               
                if let jsonString = self.performStoreRequestWithURL(url),
                    let dictionary = self.parseJSON(jsonString) {
                        
                        self.searchResults = self.parseDictionary(dictionary)
                        
                        /*sort the results alphabetically.  The first method uses a closure inside the localizedStandardCompare method, while the second uses a trailing closure.  The third uses operator overloading and is defined above.
                1
                        searchResults.sortInPlace({ result1, result2 in
                            return result1.name.localizedStandardCompare(result2.name) == .OrderedAscending})
                2
                        searchResults.sortInPlace { $0.name.localizedStandardCompare($1.name) == .OrderedAscending }
                3
                        searchResults.sortInPlace{$0 < $1} */
                        self.searchResults.sortInPlace(<)
                    
                        dispatch_async(dispatch_get_main_queue()){
                            self.isLoading = false
                            self.searchResultsTableView.reloadData()
                        }
                    
                        return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNetworkError()
                }
            }
        }
    }
    
    //STYLES:
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
    if isLoading {
        return 1
    } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
    // if there are no results, show one cell that will contain that message
            return 1
        } else {
            return searchResults.count
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isLoading {
            let cell = searchResultsTableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        
        //no matches are found
        if searchResults.count == 0 {
            return searchResultsTableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        
        //match is found
        } else {
            let cell = searchResultsTableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultsCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
//                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.kind)
                cell.artistNameLabel.text = "\(searchResult.artistName) (\(kindForDisplay(searchResult.kind)))"
            }
            return cell
        }
    }
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView,
                   willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    //ensure you can only select rows with search results
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

