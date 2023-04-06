//
//  DownloadItem.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import Foundation

class DownloadItem: NSObject {

	var mediaItem: MediaItem
	var task: URLSessionDownloadTask?
	var downloading = false
	var resumeData: Data?
	var progress: Float = 0.0
	var urlForArtwork = false
	let url: URL?

	init(with mediaItem: MediaItem, artwork: Bool = false) {
		self.mediaItem = mediaItem
		self.urlForArtwork = artwork
		self.url = artwork ? mediaItem.artworkUrl : mediaItem.previewUrl
	}
}
