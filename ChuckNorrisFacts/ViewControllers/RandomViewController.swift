//
//  RandomViewController.swift
//  ChuckNorrisFacts
//
//  Created by Руслан Арыстанов on 03.02.2025.
//

import UIKit

class RandomViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var categiriesPicker: UIPickerView!
    @IBOutlet var getFactButton: UIButton!
    
    @IBOutlet var aboutChuckNorris: UILabel!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private var categoriesChuck: [String] = ["random fact"]
    private var isCategory = false
    private var categoryName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categiriesPicker.delegate = self
        categiriesPicker.dataSource = self
        activityIndicator.isHidden = true
        aboutChuckNorris.text = "About Chuck Norris"
        
        getCategories()
    }

    @IBAction func getFact() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        aboutChuckNorris.text = "Loading..."
        
        if isCategory == false {
            getRandomFact()
        } else {
            getFactFor(category: categoryName)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categoriesChuck.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categoriesChuck[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categoriesChuck[row] == categoriesChuck[0] {
            getFactButton.titleLabel?.text = "get \(categoriesChuck[0])"
            isCategory = false
        } else {
            categoryName = categoriesChuck[row]
            getFactButton.titleLabel?.text = "get fact from \(categoryName) category"
            isCategory = true
        }
    }
    
}

extension RandomViewController {
    private func getCategories(){
        NetworkManager.share.fetchSearchData(url: URLChuckNorris.categoryURL.rawValue) { (categories: [String]) in
            for category in categories {
                self.categoriesChuck.append(category)
            }
            self.categiriesPicker.reloadAllComponents()
        }
    }
    
    private func getFactFor(category name: String){
        NetworkManager.share.fetchRandomData(url: URLChuckNorris.randomURL.rawValue,categoryName: name, isCategory: true) { ChuckNorris in
            self.aboutChuckNorris.text = ChuckNorris.value
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    private func getRandomFact(){
        NetworkManager.share.fetchRandomData(url: URLChuckNorris.randomURL.rawValue) { ChuckNorris in
            self.aboutChuckNorris.text = ChuckNorris.value
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
}
