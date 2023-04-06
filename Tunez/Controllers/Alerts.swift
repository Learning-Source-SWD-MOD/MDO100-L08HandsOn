//
//  Alerts.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

extension UIViewController {
	func showAlertMessage(title: String?, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "Close", style: .default, handler: nil)
		alertController.addAction(action)
		self.present(alertController, animated: true, completion: nil)
	}

	func showErrorMessage(message: String) {
		showAlertMessage(title: "Error", message: message)
	}
}

extension UIViewController {
	func localFilePath(for url: URL) -> URL {
		return documentsPath.appendingPathComponent(url.lastPathComponent)
	}
}

extension MediaCell {
	func localFilePath(for url: URL) -> URL {
		return documentsPath.appendingPathComponent(url.lastPathComponent)
	}
}
