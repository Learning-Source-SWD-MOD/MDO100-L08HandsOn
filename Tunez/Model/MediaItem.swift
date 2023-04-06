//
//  MediaItem.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import Foundation

class MediaItem {
	let title: String
	let producer: String
	let artworkUrl: URL?
	let previewUrl: URL?
	let index: Int
	var downloaded = false

	init(title: String, producer: String, artworkUrl: URL?, previewUrl: URL?, index: Int) {
		self.title = title
		self.producer = producer
		self.artworkUrl = artworkUrl
		self.previewUrl = previewUrl
		self.index = index
	}
}
