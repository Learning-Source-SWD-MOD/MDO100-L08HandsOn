//
//  SearchViewController+CellDelegate.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

// MARK: - MediaCellDelegate

extension FindViewController: MediaCellDelegate {
	func mediaCellStartDownload(cell: MediaCell) {
		do {
			try mediaDownloadService.startDownload(for: cell.mediaItem)
		}
		catch let error {
			debugPrint(error.localizedDescription)
		}
		progress(show: true)
	}

	func mediaCellPauseDownload(cell: MediaCell) {
		mediaDownloadService.pauseDownload(for: cell.mediaItem)
	}

	func mediaCellResumeDownload(cell: MediaCell) {
		mediaDownloadService.resumeDownload(for: cell.mediaItem)
	}

	func mediaCellStopDownload(cell: MediaCell) {
		mediaDownloadService.cancelDownload(for: cell.mediaItem)
	}

	func mediaCellPlayDownload(cell: MediaCell) {
		playMediaItem(cell.mediaItem)
	}
}
