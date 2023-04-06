//
//  MediaDownloadManager.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

// MARK: - MediaDownloadManagerDelegate

@objc protocol MediaDownloadManagerDelegate {
	func downloadTaskIdentifier() -> Int
	func mediaDownloadManager(completedWith image: UIImage?, downloadTask: URLSessionDownloadTask) -> Void
	@objc optional func mediaDownloadManager(progress at: Float, downloadTask: URLSessionDownloadTask) -> Void
}

// MARK: - MediaDownloadSessionDelegate

class MediaDownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

	static var shared = MediaDownloadManager()
	static let noTaskIdent = -9999

	private lazy var session: URLSession = {
		let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
		return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
	}()

	deinit {
		session.finishTasksAndInvalidate()
	}

	// ---

	private var delegates = [MediaDownloadManagerDelegate]()

	func addAsDelegate(_ delegate: MediaDownloadManagerDelegate) {
		delegates.append(delegate)
	}

	func removeAsDelegate(_ delegate: MediaDownloadManagerDelegate) {
		guard let del = findCompletionDelegate(delegate) else { return }
		var index = 0
		for d in delegates {
			if d.downloadTaskIdentifier() == del.downloadTaskIdentifier() {
				delegates.remove(at: index)
				break
			}
			index += 1
		}
	}

	func removeAllDelegates() {
		session.invalidateAndCancel()
		delegates.removeAll()
	}

	private func findCompletionDelegate(_ delegate: MediaDownloadManagerDelegate) -> MediaDownloadManagerDelegate? {
		let taskIdent1 = delegate.downloadTaskIdentifier()
		for del in delegates {
			let taskIdent2 = del.downloadTaskIdentifier()
			if taskIdent1 == taskIdent2 { return del }
		}
		return nil
	}

	// ---

	func downloadTask(with url: URL, previousTask: URLSessionDownloadTask?) -> URLSessionDownloadTask {
		if let previousTask = previousTask {
			previousTask.cancel()
		}

		let task = session.downloadTask(with: url)
		task.resume()
		return task
	}

	// --

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		if totalBytesExpectedToWrite > 0 {
			let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
			for del in delegates {
				del.mediaDownloadManager?(progress: progress, downloadTask: downloadTask)
			}
		}
	}

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		guard
			let data = try? Data(contentsOf: location),
			let image = UIImage(data: data)
		else { return }

		for del in delegates {
			del.mediaDownloadManager(completedWith: image, downloadTask: downloadTask)
		}
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			debugPrint("Task completed: \(task), error: \(error)")
		}
	}
}

