//
//  MediaQueryService.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import Foundation

class MediaQueryService {

	let MEDIA_ITEM_LIMIT = 20

	typealias MediaQueryResult = ([MediaItem]?, [String]?) -> ()
	typealias JSONDictionary = [String: Any]

	let mediaType: MediaType
	let session = URLSession(configuration: .default)
	var task: URLSessionDataTask?
	var items = [MediaItem]()
	var errors = [String]()

	private let server = "https://itunes.apple.com/search"

	init(mediaType: MediaType) {
		self.mediaType = mediaType
	}

	func getMediaMatchingSearch(_ search: String, completion: @escaping MediaQueryResult) {
		if search.isEmpty { completion(nil, errors) }

		errors.removeAll()
		task?.cancel()

		// make call
		if var urlComp = URLComponents(string: server) {
			let limit = "&limit=\(MEDIA_ITEM_LIMIT)"
			urlComp.query = "media=\(media())&entity=\(entity())&term=\(search)" + limit
			guard let url = urlComp.url else { return }

			task = session.dataTask(with: url) { [weak self] data, response, error in
                guard let weakSelf = self else { return }
				defer { weakSelf.task = nil }
				if let error = error {
					weakSelf.errors.append(error.localizedDescription)
				}
				else {
					guard
						let data = data,
						let response = response as? HTTPURLResponse,
						response.statusCode == 200
					else { return }

					weakSelf.processResponse(data)
				}
				DispatchQueue.main.async {
                    completion(weakSelf.items, weakSelf.errors.count > 0 ? weakSelf.errors : nil)
                }
			}
			task?.resume()
		}
	}

	private func media() -> String {
		return mediaType == .audio ? "audio" : "video"
	}

	private func entity() -> String {
		return mediaType == .audio ? "song" : "musicVideo"
	}

	private func processResponse(_ data: Data) {
		var response: JSONDictionary?

		do {
			response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
		}
		catch let err as NSError {
			errors.append("JSONSerialization error: \(err.localizedDescription)")
			return
		}

		guard let resp = response, let results = resp["results"] as? [Any] else {
			errors.append("Results dictionary does not contain `results` key")
			return
		}

		extractMediaResults(results: results)
		sortMediaItems()
	}

	private func extractMediaResults(results: [Any]) {
		var index = 0

		for mediaItemDictionary in results {
			if
				let mediaItemDictionary = mediaItemDictionary as? JSONDictionary,
				let previewUrlString = mediaItemDictionary["previewUrl"] as? String,
				let previewUrl = URL(string: previewUrlString),
				let name = mediaItemDictionary["trackName"] as? String,
				let artist = mediaItemDictionary["artistName"] as? String
			{
				var artworkUrl: URL?
				if let artworkUrlString = mediaItemDictionary["artworkUrl30"] as? String {
					artworkUrl = URL(string: artworkUrlString)
				}

				let item = MediaItem(title: name, producer: artist, artworkUrl: artworkUrl, previewUrl: previewUrl, index: index)
				items.append(item)

				index += 1
			}
		}
	}

	private func sortMediaItems() {
		items.sort { $0.title > $1.title }
	}
}
