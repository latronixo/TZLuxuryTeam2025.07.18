//
//  ViewController.swift
//  TZLuxuryTeam2025.07.18
//
//  Created by Валентин on 18.07.2025.
//

import UIKit

class ViewController: UIViewController {
    
    private var stocks = [Stock]()
    private var favorites = [Stock]()
    
    private let favoritesKey = "favoritesStock"
    private let searchHistoryKey = "searchHistory"
    private let maxHistoryCount = 10
    private let popularRequests = [
        "Apple", "Amazon", "Google", "Tesla", "Microsoft", "First Solar", "Alibaba", "FaceBook", "MasterCard"
    ]
    private var searchHistory: [String] = []
    
    private var showingFavorites = false
    private var isSearchMode = false
    private var searchDebounceTimer: Timer?
    
    private var currentList: [Stock] {
        let baseList = showingFavorites ? favorites : stocks
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
    
    private let showMoreLabel: UILabel = {
        let element = UILabel()
        element.text = "Show more"
        element.font = UIFont(name: "Montserrat-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        element.textColor = .black
        element.numberOfLines = 1
        element.textAlignment = .right
        return element
    }()
    
    private let popularLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular requests"
        label.font = UIFont(name: "Montserrat-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    private var popularCollectionView: UICollectionView!
    private var historyCollectionView: UICollectionView!
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "You've searched for this"
        label.font = UIFont(name: "Montserrat-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    private let searchStack = UIStackView()
    
    private lazy var searchBar: UISearchBar = {
        let element = UISearchBar()
        
        let textField = element.searchTextField
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Montserrat-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16)
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
    
    private let stocksButton: UIButton = {
        let element = UIButton()
        element.setTitle("Stocks", for: .normal)
        element.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
        element.setTitleColor(.black, for: .normal)
        return element
    }()
    
    private let favoritesButton: UIButton = {
        let element = UIButton()
        element.setTitle("Favorite", for: .normal)
        element.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        element.setTitleColor(.lightGray, for: .normal)
        return element
    }()
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        loadFavorites()
        loadSearchHistory()
        setup()
        setupConstraints()
        setupTable()
        setupCollections()
        setupSearchUI()
        fetchStocks()
    }
    
    private func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(searchBar)
        contentView.addSubview(stocksButton)
        contentView.addSubview(favoritesButton)
        contentView.addSubview(showMoreLabel)
        showMoreLabel.isHidden = true
        contentView.addSubview(tableView)
        contentView.addSubview(searchStack)
        
        stocksButton.addTarget(self, action: #selector(showStocks), for: .touchUpInside)
        favoritesButton.addTarget(self, action: #selector(showFavorites), for: .touchUpInside)
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
        
        stocksButton.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(15)
        }

        favoritesButton.snp.makeConstraints {
            $0.bottom.equalTo(stocksButton.snp.bottom)
            $0.leading.equalTo(stocksButton.snp.trailing).offset(24)
        }
        
        showMoreLabel.snp.makeConstraints {
            $0.centerY.equalTo(stocksButton.snp.centerY)
            $0.trailing.equalToSuperview().inset(15)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(50)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(800)
        }

        searchStack.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.reuseID)
        
        tableView.separatorStyle = .none
        
        searchBar.delegate = self
    }
    
    private func setupCollections() {
        let layout1 = UICollectionViewFlowLayout()
        layout1.scrollDirection = .vertical
        layout1.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout1.minimumInteritemSpacing = 8
        layout1.minimumLineSpacing = 12
        popularCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout1)
        popularCollectionView.backgroundColor = .clear
        popularCollectionView.register(PopularHistoryButtonCell.self, forCellWithReuseIdentifier: PopularHistoryButtonCell.reuseID)
        popularCollectionView.dataSource = self
        popularCollectionView.delegate = self
        popularCollectionView.isScrollEnabled = false
        popularCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .vertical
        layout2.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout2.minimumInteritemSpacing = 8
        layout2.minimumLineSpacing = 12
        historyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout2)
        historyCollectionView.backgroundColor = .clear
        historyCollectionView.register(PopularHistoryButtonCell.self, forCellWithReuseIdentifier: PopularHistoryButtonCell.reuseID)
        historyCollectionView.dataSource = self
        historyCollectionView.delegate = self
        historyCollectionView.isScrollEnabled = false
        historyCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSearchUI() {
        searchStack.axis = .vertical
        searchStack.spacing = 16
        searchStack.alignment = .fill
        searchStack.distribution = .fill
        searchStack.isHidden = true
        
        searchStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        searchStack.addArrangedSubview(popularLabel)
        searchStack.addArrangedSubview(popularCollectionView)
        let popularRows = max(1, Int(ceil(Double(popularRequests.count) / 3.0)))
        popularCollectionView.snp.remakeConstraints { make in
            make.height.equalTo(popularRows * 48)
        }
        
        searchStack.addArrangedSubview(historyLabel)
        searchStack.addArrangedSubview(historyCollectionView)
        let historyRows = max(1, Int(ceil(Double(max(searchHistory.count, 1)) / 3.0)))
        historyCollectionView.snp.remakeConstraints { make in
            make.height.equalTo(historyRows * 48)
        }
        popularCollectionView.reloadData()
        historyCollectionView.reloadData()
    }
    
    private func updateSearchHistory(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let idx = searchHistory.firstIndex(of: trimmed) {
            searchHistory.remove(at: idx)
        }
        searchHistory.insert(trimmed, at: 0)
        if searchHistory.count > maxHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxHistoryCount))
        }
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
        setupSearchUI()
    }
    private func loadSearchHistory() {
        if let arr = UserDefaults.standard.stringArray(forKey: searchHistoryKey) {
            searchHistory = arr
        }
    }
    
    private func setSearchMode(_ enabled: Bool) {
        guard isSearchMode != enabled else { return } // предотвращаем лишние вызовы
        isSearchMode = enabled
        stocksButton.isHidden = enabled
        favoritesButton.isHidden = enabled
        if searchBar.text != nil {
            tableView.isHidden = enabled
        }
        searchStack.isHidden = !enabled
    }
    
    private func showSearchIcon() {
        let textField = searchBar.searchTextField
        let searchIcon = UIImageView(image: UIImage(named: "searchIcon"))
        searchIcon.tintColor = .black
        searchIcon.contentMode = .scaleAspectFit
        let searchIconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        searchIcon.frame = CGRect(x: 10, y: 8, width: 15, height: 15)
        searchIconContainer.addSubview(searchIcon)
        textField.leftView = searchIconContainer
    }

    private func showBackIcon() {
        let textField = searchBar.searchTextField
        let backImage = UIImage(systemName: "arrow.left")
        let backButton = UIButton(type: .system)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .black
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(searchBarBackTapped), for: .touchUpInside)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        backButton.center = CGPoint(x: 20, y: 15)
        container.addSubview(backButton)
        textField.leftView = container
    }

    @objc private func searchBarBackTapped() {
        searchBar.resignFirstResponder()
        setSearchMode(false)
        showSearchIcon()
        searchBar.text = ""
        showMoreLabel.isHidden = true
        tableView.reloadData()
        
        searchBar.resignFirstResponder()
        
        setSearchMode(false)
        showSearchIcon()
    }
    
    @objc private func showStocks() {
        showingFavorites = false
        updateButtons()
        tableView.reloadData()
    }
    
    @objc private func showFavorites() {
        showingFavorites = true
        updateButtons()
        tableView.reloadData()
    }
    
    private func updateButtons () {
        if showingFavorites {
            stocksButton.setTitleColor(.lightGray, for: .normal)
            stocksButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
            favoritesButton.setTitleColor(.black, for: .normal)
            favoritesButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        } else {
            stocksButton.setTitleColor(.black, for: .normal)
            stocksButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
            favoritesButton.setTitleColor(.lightGray, for: .normal)
            favoritesButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        }
        // Принудительно обновить layout
         stocksButton.layoutIfNeeded()
         favoritesButton.layoutIfNeeded()
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
        cell.backgroundColor = indexPath.row % 2 == 0 ? #colorLiteral(red: 0.9425268769, green: 0.9571763873, blue: 0.9700122476, alpha: 1) : .systemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebounceTimer?.invalidate()
        setSearchMode(false)
        if searchText.isEmpty {
            tableView.reloadData()
            return
        }
        showMoreLabel.isHidden = false

        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.updateSearchHistory(searchText)
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setSearchMode(true)
        showBackIcon()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchDebounceTimer?.invalidate()
        if let text = searchBar.text, !text.isEmpty {
            updateSearchHistory(text)
        }
        tableView.reloadData()
        setSearchMode(false)
        showSearchIcon()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
            updateSearchHistory(text)
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == popularCollectionView {
            return popularRequests.count
        } else {
            return searchHistory.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularHistoryButtonCell.reuseID, for: indexPath) as! PopularHistoryButtonCell
        let text: String
        if collectionView == popularCollectionView {
            text = popularRequests[indexPath.item]
        } else {
            text = searchHistory[indexPath.item]
        }
        cell.configure(text: text)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text: String
        if collectionView == popularCollectionView {
            text = popularRequests[indexPath.item]
        } else {
            text = searchHistory[indexPath.item]
        }
        searchBar.text = text
        setSearchMode(false)
        //showSearchIcon()
        updateSearchHistory(text)
        tableView.reloadData()
    }
}
