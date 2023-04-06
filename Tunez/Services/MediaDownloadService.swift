//
//  MediaDownloadService.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import Foundation

enum MediaDownloadServiceError: Error {
	case noSession
	case noUrl
}

class MediaDownloadService {

	var session: URLSession?
	var downloads: [URL: DownloadItem] = [:]

	func downloadAvatar(for mediaItem: MediaItem) throws {
		guard let session = session else { throw MediaDownloadServiceError.noSession }
		guard let url = mediaItem.artworkUrl else { throw MediaDownloadServiceError.noUrl }

		let download = DownloadItem(with: mediaItem)
		let task = session.downloadTask(with: url)

		download.downloading = true
		download.task = task
		download.task?.resume()

		downloads[url] = download
	}

	func startDownload(for mediaItem: MediaItem) throws {
		guard let session = session else { throw MediaDownloadServiceError.noSession }
		guard let url = mediaItem.previewUrl else { throw MediaDownloadServiceError.noUrl }

		let download = DownloadItem(with: mediaItem)
		let task = session.downloadTask(with: url)

		download.downloading = true
		download.task = task
		download.task?.resume()

		downloads[url] = download
	}

	func pauseDownload(for mediaItem: MediaItem) {
		guard
			let url = mediaItem.previewUrl,
			let download = downloads[url]
		else { return }

		if download.downloading {
			download.task?.cancel(byProducingResumeData: { data in
				download.resumeData = data
			})
			download.downloading = false
		}
	}

	func cancelDownload(for mediaItem: MediaItem) {
		if let url = mediaItem.previewUrl, let download = downloads[url] {
			download.task?.cancel()
			downloads[url] = nil
		}
	}

	func resumeDownload(for mediaItem: MediaItem) {
		guard
			let session = session,
			let url = mediaItem.previewUrl,
			let download = downloads[url],
			let downloadUrl = download.url
		else { return }

		if let resumeData = download.resumeData {
			download.task = session.downloadTask(withResumeData: resumeData)
		}
		else {
			download.task = session.downloadTask(with: downloadUrl)
		}
		download.task!.resume()
		download.downloading = true
	}
}

