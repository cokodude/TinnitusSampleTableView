//
//  MainViewController.swift
//  TinnitusSample
//
//  Created by Cody Huang on 9/2/21.
//

import UIKit
import FeedKit
import AVKit

class MainViewController: UIViewController {
    
    @IBOutlet private weak var feedTableView: UITableView!
    
    private var feedItems: [RSSFeedItem] = []
    private var playingURL: URL?
    private var player: AVPlayer?
    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        let feedURL = URL(string: "https://feed.podbean.com/tinnitustalk/feed.xml")!
        let parser = FeedParser(URL: feedURL) // or FeedParser(data: data) or FeedParser(xmlStream: stream)

        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let feed):
                    self.feedItems = feed.rssFeed?.items ?? []
                case .failure(let error):
                    print(error)
                }
                self.feedTableView.reloadData()
            }
        }

    }

}

extension MainViewController: UITableViewDelegate {
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseIdentifier, for: indexPath) as? FeedTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let item = feedItems[indexPath.row]
        let cellIsPlaying: Bool
        if let url = item.enclosure?.attributes?.url,
           url == playingURL?.absoluteString,
           self.isPlaying {
            cellIsPlaying = true
        } else {
            cellIsPlaying = false
        }
        cell.configureCell(feed: item, isPlaying: cellIsPlaying)
        
        return cell
    }
}

extension MainViewController: FeedTableViewCellDelegate {
    func playPodcast(url: URL) {
        if let player = player,
           self.playingURL == url {
            player.play()
        } else {
            self.playingURL = url
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem:playerItem)
            player!.volume = 1.0
            player!.play()
        }
        isPlaying = true
        feedTableView.reloadData()
    }
    
    func pausePodcast() {
        isPlaying = false
        player?.pause()
    }
    
}
