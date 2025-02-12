//
//  SearchTableViewController.swift
//  ChuckNorrisFacts
//
//  Created by Руслан Арыстанов on 04.02.2025.
//

import UIKit

protocol SortDelegate {
    func sortSearchResult(sortedMethod: String)
}

class SearchTableViewController: UITableViewController, SortDelegate{
    
    private var chuckNorrisFacts: [ChuckNorris] = []
    private var searchText: String?
    private var activityIndicator: UIActivityIndicatorView!
    let viewControllerToPresent = SortViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -100)
        ])
        
        refresh()
    }
    
    @IBAction func openSortView(_ sender: Any) {
        viewControllerToPresent.delegate = self
        
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        
        present(viewControllerToPresent, animated: true, completion: nil)
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
        searchText = searchBar.text
        guard let textCount = searchBar.text?.count else {
            print("error")
            return
        }
        
        if textCount <= 3 {
            searchBar.text?.removeAll()
            showAlert(text: "Please enter more than 3 characters.")
        } else {
            chuckNorrisFacts.removeAll()
            activityIndicator.startAnimating()
            
            NetworkManager.share.fetchData(
                url: URLChuckNorris.searchURL.rawValue,
                searchText: searchBar.text ?? "") { (chuckNorris: Result) in
                    
                    for result in chuckNorris.result {
                        self.chuckNorrisFacts.append(result)
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    
                    if self.chuckNorrisFacts.isEmpty {
                        searchBar.text?.removeAll()
                        self.showAlert(text: "No results found. Please try a different search.")
                    }
                }
            
            searchBar.resignFirstResponder()
        }
    }
    
    @objc private func fetshData(){
        let text = searchText ?? ""
        
        if text.count <= 3 {
            showAlert(text: "Please enter more than 3 characters.")
            self.refreshControl?.endRefreshing()
        } else {
            NetworkManager.share.fetchData(
                url: URLChuckNorris.searchURL.rawValue,
                searchText: searchText ?? "") { (chuckNorris: Result) in
                    for result in chuckNorris.result {
                        self.chuckNorrisFacts.append(result)
                    }
                    
                    if self.chuckNorrisFacts.isEmpty {
                        self.showAlert(text: "No results found. Please try a different search.")
                    }
                    
                    if self.refreshControl != nil{
                        self.refreshControl?.endRefreshing()
                    }
                    
                    self.tableView.reloadData()
                }
        }
        
    }
    
    func sortSearchResult(sortedMethod: String) {
        switch sortedMethod {
        case "Sort by Length":
            chuckNorrisFacts.sort { $0.value.count < $1.value.count }
        case "Sort Alphabetically":
            chuckNorrisFacts.sort {$0.value.lowercased() < $1.value.lowercased()}
        default:
            print("Not sorted")
        }
        
        tableView.reloadData()
    }
    
    private func showAlert(text: String){
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func refresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableView.refreshControl?.addTarget(self, action: #selector(fetshData), for: .valueChanged)
        
    }
}
