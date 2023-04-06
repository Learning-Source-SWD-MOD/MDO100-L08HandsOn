//
//  SearchViewController+Table.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

// MARK: - UITableViewDataSource

extension FindViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldFilterResults() {
			return filteredResults.count
		}
        return searchResults.count
    }
}

// MARK: - UITableViewDelegate

extension FindViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: MediaCell.Cell.ident, for: indexPath) as? MediaCell  else {
			fatalError("The dequeued cell is not an instance of MediaCell.")
		}

		cell.delegate = self

		let mediaItem = mediaItemFor(indexPath: indexPath)
		cell.configureCell(with: mediaItem)

		return cell
    }

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let mediaItem = searchResults[indexPath.row]
		if mediaItem.downloaded { playMediaItem(mediaItem) }
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
