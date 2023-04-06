//
//  SearchViewController+Session.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

// MARK: - URLSessionDelegate

extension FindViewController: URLSessionDelegate {
	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		DispatchQueue.main.async {
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
				let completionHandler = appDelegate.backgroundSessionCompletionHandler {
				appDelegate.backgroundSessionCompletionHandler = nil
				completionHandler()
			}
		}
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			debugPrint(error.localizedDescription)

			guard
				let sourceUrl = task.originalRequest?.url,
				let download = mediaDownloadService.downloads[sourceUrl]
			else { return }

			DispatchQueue.main.async {
				if let cell = self.tableView?.cellForRow(at: IndexPath(row: download.mediaItem.index, section: 0)) as? MediaCell {
					cell.updateCellForDownloaded(as: false)
				}
			}
		}
	}
}

// MARK: - URLSessionDownloadDelegate

extension FindViewController: URLSessionDownloadDelegate {

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		self.progress(show: false)

		guard
			let sourceUrl = downloadTask.originalRequest?.url,
			let download = mediaDownloadService.downloads[sourceUrl]
		else { return }

		mediaDownloadService.downloads[sourceUrl] = nil

		var downloaded = false
		do {
			let destinationUrl = localFilePath(for: sourceUrl)
			try? FileManager.default.removeItem(at: destinationUrl)
			try FileManager.default.copyItem(at: location, to: destinationUrl)
			download.mediaItem.downloaded = true
			downloaded = true
		}
		catch let error {
			debugPrint("Error copying file: \(error.localizedDescription)")
		}

		DispatchQueue.main.async {
			if let cell = self.tableView?.cellForRow(at: IndexPath(row: download.mediaItem.index, section: 0)) as? MediaCell {
				cell.updateCellForDownloaded(as: downloaded)
			}
		}
	}

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		guard
			let url = downloadTask.originalRequest?.url,
			let download = mediaDownloadService.downloads[url]
		else { return }

		download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
		updateProgress(to: download.progress)
	}
}
