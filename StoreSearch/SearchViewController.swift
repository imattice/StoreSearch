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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var dataTask: NSURLSessionDataTask?
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
    
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        let entityName: String
        switch category {
        case 1:
            entityName = "musicTrack"
        case 2:
            entityName = "software"
        case 3:
            entityName = "ebook"
        default:
            entityName = ""
        }
    //remove characters that don't work well in urls, such as spaces
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
    //build the url
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        return url!
    }
    func parseJSON(data: NSData) -> [String: AnyObject]? {
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
        searchResultsTableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        searchResultsTableView.rowHeight = 80
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }
    
}
extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            searchResultsTableView.reloadData()
            
            hasSearched = true
            searchResults = [SearchResult]()
            
            let url = self.urlWithSearchText(searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in
                
                if let error = error where error.code == -999 {
                    return
                } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                    if let data = data, dictionary = self.parseJSON(data) {
                        self.searchResults = self.parseDictionary(dictionary)
                        self.searchResults.sortInPlace(<)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isLoading = false
                            self.searchResultsTableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.hasSearched = false
                    self.isLoading = false
                    self.searchResultsTableView.reloadData()
                    self.showNetworkError()
                }
            })
            
            dataTask?.resume()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
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

