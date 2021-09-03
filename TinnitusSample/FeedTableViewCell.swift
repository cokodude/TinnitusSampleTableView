//
//  FeedTableViewCell.swift
//  TinnitusSample
//
//  Created by Cody Huang on 9/2/21.
//

import UIKit
import FeedKit

protocol FeedTableViewCellDelegate: AnyObject {
    func playPodcast(url: URL)
    func pausePodcast()
}

class FeedTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FeedTableViewCellID"
    
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    private var feed: RSSFeedItem?
    private var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                playButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            } else {
                playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            }
        }
    }
    weak var delegate: FeedTableViewCellDelegate?
    
    func configureCell(feed: RSSFeedItem, isPlaying: Bool) {
        self.feed = feed
        self.isPlaying = isPlaying
        titleLabel.text = feed.title
        subtitleLabel.text = feed.iTunes?.iTunesSummary
        
        // Add more labels if you want to show more info like:
        // feed.pubDate
        // feed.iTunes?.iTunesAuthor
        // feed.iTunes?.iTunesSubtitle
        // feed.iTunes?.iTunesDuration
        // etc. (check the rss feed URL in a browser to see what's available)
    }
    
    @IBAction private func playTouchUp(_ sender: Any) {
        if isPlaying {
            isPlaying = false
            delegate?.pausePodcast()
        } else {
            if let urlString = feed?.enclosure?.attributes?.url,
               let url = URL(string: urlString) {
                isPlaying = true
                delegate?.playPodcast(url: url)
            }
        }
    }
    
}
