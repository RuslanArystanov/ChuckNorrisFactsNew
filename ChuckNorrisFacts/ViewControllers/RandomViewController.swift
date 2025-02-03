//
//  RandomViewController.swift
//  ChuckNorrisFacts
//
//  Created by Руслан Арыстанов on 03.02.2025.
//

import UIKit

class RandomViewController: UIViewController {

    @IBOutlet var aboutChuckNorris: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutChuckNorris.text = "About Chuck Norris"
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
        ])
    }

    @IBAction func getRandomFact() {
        activityIndicator.startAnimating()
        aboutChuckNorris.text = "Loading..."
        NetworkManager.share.fetchRandomData(url: URLChuckNorris.randomURL.rawValue) { ChuckNorris in
            self.aboutChuckNorris.text = ChuckNorris.value
            self.activityIndicator.stopAnimating()
        }
    }
    
}
