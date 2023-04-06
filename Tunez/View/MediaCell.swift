//
//  MediaCell.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

protocol MediaCellDelegate {
	func mediaCellStartDownload(cell: MediaCell)
	func mediaCellPauseDownload(cell: MediaCell)
	func mediaCellResumeDownload(cell: MediaCell)
	func mediaCellStopDownload(cell: MediaCell)
	func mediaCellPlayDownload(cell: MediaCell)
}

class MediaCell: UITableViewCell {

	struct Cell {
		static let ident = "mediaCell"
	}

	@IBOutlet weak var mediaImageView: UIImageView?
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var producerLabel: UILabel?
	@IBOutlet weak var downloadPlayButton: UIButton?

	var delegate: MediaCellDelegate?

	weak var mediaItem: MediaItem!

	func configureCell(with mediaItem: MediaItem) {
		self.mediaItem = mediaItem

		titleLabel?.text = mediaItem.title
		producerLabel?.text = mediaItem.producer

		mediaImageView?.image = UIImage(named: "nopic")
		if let url = mediaItem.artworkUrl { loadImageFromUrl(url: url) }
	}

	var downloadTask: URLSessionDownloadTask?

	private func loadImageFromUrl(url: URL) {
		MediaDownloadManager.shared.addAsDelegate(self)
		downloadTask = MediaDownloadManager.shared.downloadTask(with: url, previousTask: downloadTask)
	}

	private func fadeButton(out: Bool, button: UIButton, completion: (() -> Swift.Void)? = nil) {
		UIView.animate(withDuration: 0.15, animations: {
			button.alpha = out ? 0.0 : 1.0
		}, completion: { _ in
			completion?()
		})
	}

	@IBAction func onClickDownload(sender: UIButton) {
		if let downloadPlayButton = downloadPlayButton {
			if mediaItem.downloaded {
				delegate?.mediaCellPlayDownload(cell: self)
			}
			else {
				fadeButton(out: true, button: downloadPlayButton, completion: { [weak self] in
                    if let weakSelf = self {
                        weakSelf.delegate?.mediaCellStartDownload(cell: weakSelf)
                    }
				})
			}
		}
	}

	func updateCellForDownloaded(as successful: Bool) {
		if let downloadPlayButton = downloadPlayButton {
			if successful {
				downloadPlayButton.setTitle("Play", for: UIControl.State.normal)
			}
			else {
				downloadPlayButton.setTitle("Download", for: UIControl.State.normal)
			}
			fadeButton(out: false, button: downloadPlayButton, completion: nil)
		}
	}
}


extension MediaCell: MediaDownloadManagerDelegate {
	func downloadTaskIdentifier() -> Int {
		if let downloadTask = downloadTask {
			return downloadTask.taskIdentifier
		}
		else {
			return MediaDownloadManager.noTaskIdent
		}
	}

	func mediaDownloadManager(completedWith image: UIImage?, downloadTask: URLSessionDownloadTask) {
		let ident = self.downloadTaskIdentifier()
		guard
			downloadTask.taskIdentifier == ident,
			let image = image
		else { return }

		self.downloadTask = nil
		DispatchQueue.main.async {
			self.mediaImageView?.image = image
		}
	}
}

