//
//  SearchTableViewController.swift
//  ChuckNorrisFacts
//
//  Created by Руслан Арыстанов on 04.02.2025.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    private var chuckNorrisFacts: [ChuckNorris] = []
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -100)
        ])
        
        tableView.rowHeight = 50
    
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chuckNorrisFacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let chuckNorris = chuckNorrisFacts[indexPath.row]
        
        content.text = chuckNorris.value
        
        cell.contentConfiguration = content
        return cell
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.startAnimating()
        
        NetworkManager.share.fetchSearchData(
            url: URLChuckNorris.searchURL.rawValue,
            searchText: searchBar.text ?? "") { (chuckNorris: Result) in
            
                for result in chuckNorris.result {
                self.chuckNorrisFacts.append(result)
            }
            
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
        searchBar.resignFirstResponder()
        }
}
