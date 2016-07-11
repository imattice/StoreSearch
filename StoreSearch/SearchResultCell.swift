//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Ike Mattice on 7/6/16.
//  Copyright © 2016 Ike Mattice. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var downloadTask: NSURLSessionDownloadTask?
    
    func configureForSearchResult(searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.kindForDisplay())
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let url = NSURL(string: searchResult.artworkURL60) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    //STYLES:
        //change color of background when tapped
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        nameLabel.text = nil
        artistNameLabel.text = nil
        artworkImageView.image = nil
    }
}
