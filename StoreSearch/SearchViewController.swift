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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //STYLES:
        searchResultsTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    //hide the keyboard once the Search button is clicked
        searchBar.resignFirstResponder()
        hasSearched = true

    //provide search results
        searchResults = [SearchResult]()
        
        for i in 0...4 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "False result %d for ", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
        }
        searchResultsTableView.reloadData()
    }
    
    //STYLES:
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
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
    //build cell for table view
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = searchResultsTableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
    //if there is not an available cell to reuse, create a new one
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
      
    //no matches are found
        if searchResults.count == 0 {
            cell.textLabel!.text = "No match found"
            cell.detailTextLabel!.text = ""
    //match is found
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        return cell
    }
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView,
                   willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    //ensure you can only select rows with search results
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

