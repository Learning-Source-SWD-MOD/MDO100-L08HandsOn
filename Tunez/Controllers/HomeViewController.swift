//
//  HomeViewController.swift
//  Tunez
//
//  Copyright © 2018 WOZ-U. All rights reserved.
//

import UIKit

enum MediaType {
	case audio
	case video
}

class HomeViewsController: UIViewController {

	public static var session: URLSession?
    
    @IBOutlet weak var audioButton: UIButton?
    @IBOutlet weak var videoButton: UIButton?

	private let tagAudioButton = 11
	private let tagVideoButton = 22

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Tunez"
		customizeAppearance()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let session = HomeViewController.session {
			session.invalidateAndCancel()
			HomeViewController.session = nil
		}
	}
    
    // MARK: - Appearance

    private func customizeAppearance() {
		audioButton?.setTitle(" ", for: UIControl.State.normal)
		audioButton?.setTitleColor(UIColor.cyan, for: UIControl.State.normal)

		videoButton?.setTitle("Music Videos", for: UIControl.State.normal)
		videoButton?.setTitleColor(UIColor.cyan, for: UIControl.State.normal)

		guard let audioButton = audioButton, let videoButton = videoButton else { return }
		let buttons = [audioButton, videoButton]
		let bnHeight = audioButton.frame.size.height
		let yPos = (view.frame.size.height - bnHeight) / 3.0 + bnHeight / 2.0
        var index: CGFloat = 0
		_ = buttons.map { button in
			button.center.x = view.center.x
			button.frame.origin.y = yPos * (index + 1)
			index += 1
		}
    }
    
    // MARK: - Event handlers

	@IBAction func audioSelected(sender: UIButton) {
        selectSource(sender: sender)
	}

	@IBAction func videoSelected(sender: UIButton) {
        selectSource(sender: sender)
	}

    private func selectSource(sender: UIButton) {
		performSegue(withIdentifier: "showSearch", sender: sender)
	}

	// MARK: - Navigation
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let sender = sender as? UIButton, let lvc = segue.destination as? FindViewController {
            lvc.mediaType = (sender.tag == self.tagVideoButton) ? .video : .audio
		}
	}
}

