//
//  ViewController.swift
//  KeyboardNotificationDemo
//
//  Created by Ben Scheirman on 10/26/20.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var chatBar: UIView!
    @IBOutlet weak var safeAreaConstraint: NSLayoutConstraint!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func sendTapped(_ sender: Any) {
        view.endEditing(true)
    }
}
