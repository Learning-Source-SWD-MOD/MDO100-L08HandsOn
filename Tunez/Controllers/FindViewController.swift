//
//  SearchViewController.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit
import AVKit

class FindViewController: UIViewController {

	@IBOutlet weak var searchBar: UISearchBar?
	@IBOutlet weak var tableView: UITableView?

	var mediaType: MediaType = .audio

	lazy var queryService = { return MediaQueryService(mediaType: self.mediaType) }()
	var searchResults = [MediaItem]()
	var filteredResults = [MediaItem]()
	let searchController = UISearchController(searchResultsController: nil)

	lazy var mediaDownloadService = { return MediaDownloadService() }()

	lazy var downloadSession: URLSession = {
		guard let session = HomeViewController.session else {
			let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
			let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
			HomeViewController.session = session
			return session
		}
		return session
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()

		navigationItem.searchController = searchController

		UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.green
    }

	private func setup() {
		setupSearchController()

		navigationItem.title = "Search for " + ((mediaType == .audio) ? "Music" : "Music Videos")

		searchBar?.delegate = self

		tableView?.dataSource = self
		tableView?.delegate = self

		mediaDownloadService.session = downloadSession
	}

	private func setupSearchController() {
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Filter search results"
		searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.clear, state: UIControl.State.normal)
		definesPresentationContext = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		searchBar?.becomeFirstResponder()
	}

	@IBOutlet weak var coverView: UIView?
	@IBOutlet weak var progressView: UIProgressView?

	internal func progress(show: Bool) {
		DispatchQueue.main.async {
			if show {
				if let coverView = self.coverView {
					self.view.bringSubviewToFront(coverView)
					coverView.isHidden = false
                    self.progressView?.setProgress(0.0, animated: false)
				}
			}
			else {
				self.coverView?.isHidden = true
			}
		}
	}

	internal func updateProgress(to val: Float) {
		DispatchQueue.main.async {
			self.progressView?.setProgress(val, animated: true)
		}
	}

	internal func playMediaItem(_ mediaItem: MediaItem) {
		guard let previewUrl = mediaItem.previewUrl else { return }

		let playerController = AVPlayerViewController()
		playerController.entersFullScreenWhenPlaybackBegins = true
		playerController.exitsFullScreenWhenPlaybackEnds = true
		present(playerController, animated: true, completion: nil)

		let url = localFilePath(for: previewUrl)
		playerController.player = AVPlayer(url: url)
		playerController.player?.play()
	}

	internal func searchIsEmpty() -> Bool {
		return searchBar?.text?.isEmpty ?? true
	}

	internal func filterBarIsEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}

	internal func shouldFilterResults() -> Bool {
		if !filterBarIsEmpty()  { return true }
		return false
	}

	internal func mediaItemFor(indexPath: IndexPath) -> MediaItem {
		let index = appropriateIndexFor(indexPath: indexPath)
		let mediaItem = shouldFilterResults() ? filteredResults[index] : searchResults[index]
		return mediaItem
	}

	internal func appropriateIndexFor(indexPath: IndexPath) -> Int {
		let index = indexPath.row
		return index
	}
} }

