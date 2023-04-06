//
//  SearchViewController+Search.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

// MARK: - UISearchBarDelegate

extension FindViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let sb = self.searchBar, sb.isEqual(searchBar) {
			searchMediaFor(searchText: searchBar.text ?? "")
		}
	}

	func searchMediaFor(searchText: String) {
		defer { searchBar?.resignFirstResponder() }

		if searchText.isEmpty { return }

		self.searchResults.removeAll()
		self.filteredResults.removeAll()

		queryService.getMediaMatchingSearch(searchText) { [weak self] results, errors in
            guard let weakSelf = self else { return }
			defer {
				weakSelf.tableView?.reloadData()
				weakSelf.tableView?.setContentOffset(CGPoint.zero, animated: false)
			}
			if let errors = errors, errors.count > 0 {
				weakSelf.showErrorMessage(message: errors.joined(separator: "\n"))
				return
			}
			if let items = results { weakSelf.searchResults = items }
		}
	}
}

// MARK: - UISearchResultsUpdating Delegate

extension FindViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		if let searchText = searchController.searchBar.text {
			filterContentForSearchText(searchText)
		}
	}

	func filterContentForSearchText(_ searchText: String) {
		if filterBarIsEmpty() { return }

		filteredResults = searchResults.filter { mediaItem in
			if mediaItem.title.lowercased().contains(searchText.lowercased()) { return true }
			if mediaItem.producer.lowercased().contains(searchText.lowercased()) { return true }
			return false
		}
		tableView?.reloadData()
	}
}

// MARK: - UISearchBar - text color

public extension UISearchBar {
    func setTextColor(color: UIColor) {
		let svs = subviews.flatMap { $0.subviews }
		guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
		tf.textColor = color
	}
}

