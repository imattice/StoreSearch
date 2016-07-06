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
    
    struct TableViewCellIdentifiers {
        static let searchResultsCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //register nibs
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultsCell, bundle: nil)
        searchResultsTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultsCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        searchResultsTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
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
        //no matches are found
        if searchResults.count == 0 {
            return searchResultsTableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        
        //match is found
        } else {
            let cell = searchResultsTableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultsCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
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
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

