//
//  ViewController.swift
//  TZLuxuryTeam2025.07.18
//
//  Created by Валентин on 18.07.2025.
//

import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private var stocks = [Stock]()
    private var favorites = [Stock]()
    
    private let favoritesKey = "favoritesStock"
    
    private var currentList: [Stock] {
        let baseList = segmentControl.selectedSegmentIndex == 0 ? stocks : favorites
        let searchText = searchBar.text
        
        if let text = searchText {
            if text.isEmpty {
                return baseList
            } else {
                return baseList.filter { stock in
                    stock.name.localizedCaseInsensitiveContains(text) ||
                    stock.symbol.localizedCaseInsensitiveContains(text)
                }
            }
        } else {
            return baseList
        }
    }
    
    private let contentView = UIView()
    private let scrollView = UIScrollView()
    
    private lazy var searchBar: UISearchBar = {
        let element = UISearchBar()
        
        let textField = element.searchTextField
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "calibri_bold", size: 18) ?? UIFont.systemFont(ofSize: 16)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Find company or ticker", attributes: attributes)
        
        textField.layer.cornerRadius = 20
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        
        textField.autocapitalizationType = .none
        
        let searchIcon = UIImageView(image: UIImage(named: "searchIcon"))
        searchIcon.tintColor = .black
        searchIcon.contentMode = .scaleAspectFit
        let searchIconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        searchIcon.frame = CGRect(x: 10, y: 8, width: 15, height: 15)
        searchIconContainer.addSubview(searchIcon)
        textField.leftView = searchIconContainer
        textField.leftViewMode = .always
        
        //убираем верхнюю и нижнюю границы
        element.backgroundImage = UIImage()
        return element
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Stocks", "Favorite"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        loadFavorites()
        setup()
        setupConstraints()
        setupTable()
        fetchStocks()
        print("currentList.count = \(currentList.count)")
    }
    
    private func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(searchBar)
        contentView.addSubview(segmentControl)
        contentView.addSubview(tableView)

        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { 
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.bottom.equalTo(tableView.snp.bottom)
        }
        
        searchBar.snp.makeConstraints { 
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(54)
        }
        
        segmentControl.snp.makeConstraints { 
            $0.top.equalTo(searchBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(15)
        }

        tableView.snp.makeConstraints { 
            $0.top.equalTo(segmentControl.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(400)
        }
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.reuseID)
        
        searchBar.delegate = self
    }
    
    @objc private func segmentChanged() {
        tableView.reloadData()
    }
    
    func toggleFavorite(_ stock: Stock) {
        if let index = favorites.firstIndex(where: { $0.symbol == stock.symbol}) {
            favorites.remove(at: index)
        } else {
            favorites.append(stock)
        }
        saveFavorites()
        tableView.reloadData()
    }
    
    func fetchStocks() {
        let url = URL(string: "https://mustdev.ru/api/stocks.json")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let arr = try? JSONDecoder().decode([Stock].self, from: data) else { return }
            print("arr.count = \(arr.count)")
            
            DispatchQueue.main.async {
                self.stocks = arr
                self.tableView.reloadData()
            }
        }.resume()
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey), let saved = try? JSONDecoder().decode([Stock].self, from: data) {
            self.favorites = saved
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stock = currentList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.reuseID, for: indexPath) as! StockCell
        let isFavorite = favorites.contains(where: { $0.symbol == stock.symbol})
        cell.configure(with: stock,
                        isFavorite: isFavorite,
                        onFavoriteTapped: { [weak self] in
                            self?.toggleFavorite(stock)
                        }
        )
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}
