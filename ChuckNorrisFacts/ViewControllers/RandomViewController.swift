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
    
    private var categoriesChuck: [String] = ["random fact"]
    private var isCategory = false
    private var categoryName: String = ""
    
    private let shimmerLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categiriesPicker.delegate = self
        categiriesPicker.dataSource = self
        aboutChuckNorris.text = "About Chuck Norris"
        
        getCategories()
    }

    @IBAction func getFact() {
        setupShimmer()
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
            getFactButton.setTitle("Get \(categoriesChuck[0])", for: .normal)
            isCategory = false
        } else {
            categoryName = categoriesChuck[row]
            getFactButton.setTitle("Get fact from \(categoryName) category", for: .normal)
            isCategory = true
        }
    }
    
}

extension RandomViewController {
    private func getCategories(){
        NetworkManager.share.fetchData(url: URLChuckNorris.categoryURL.rawValue) { (categories: [String]) in
            for category in categories {
                self.categoriesChuck.append(category)
            }
            self.categiriesPicker.reloadAllComponents()
        }
    }
    
    private func getFactFor(category name: String){
        NetworkManager.share.fetchRandomData(url: URLChuckNorris.randomURL.rawValue,categoryName: name, isCategory: true) { ChuckNorris in
            self.aboutChuckNorris.text = ChuckNorris.value
            self.stopShimmer()
        }
    }
    
    private func getRandomFact(){
        NetworkManager.share.fetchRandomData(url: URLChuckNorris.randomURL.rawValue) { ChuckNorris in
            self.aboutChuckNorris.text = ChuckNorris.value
            self.stopShimmer()
        }
    }
    
    private func setupShimmer() {
        shimmerLayer.frame = aboutChuckNorris.bounds
        shimmerLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor
        ]
        shimmerLayer.locations = [0, 0.5, 1]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        aboutChuckNorris.layer.mask = shimmerLayer
            
        animateShimmer()
    }
    
    private func animateShimmer() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 2
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmer")
    }
    
    private func stopShimmer() {
        aboutChuckNorris.layer.mask = .none
        shimmerLayer.removeAnimation(forKey: "shimmer")
    }

}
