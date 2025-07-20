//
//  StockCell.swift
//  TZLuxuryTeam2025.07.18
//
//  Created by Валентин on 19.07.2025.
//

import SnapKit
import UIKit

class StockCell: UITableViewCell {
    static let reuseID = "StockCell"
    
    private let logoImageView: UIImageView = {
        let element = UIImageView()
        element.layer.cornerRadius = 8
        element.clipsToBounds = true
        return element
    }()
    private lazy var symbolLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.boldSystemFont(ofSize: 16)
        return element
    }()
    private lazy var nameLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.systemFont(ofSize: 14)
        element.textColor = .gray
        return element
    }()
    private lazy var favoriteButton: UIButton = {
        let element = UIButton()
        element.setImage(UIImage(systemName: "star"), for: .normal)
        element.setImage(UIImage(systemName: "star.fill"), for: .selected)
        element.tintColor = .lightGray
        element.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
        return element
    }()
    private lazy var priceLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.boldSystemFont(ofSize: 16)
        element.textAlignment = .right
        return element
    }()
    private lazy var changeLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.systemFont(ofSize: 12)
        element.textAlignment = .right
        return element
    }()
    
    private var favoriteButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    private func setup() {
        [logoImageView, symbolLabel, nameLabel, favoriteButton, priceLabel, changeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupContraints() {
        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        symbolLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView)
            $0.leading.equalTo(logoImageView.snp.trailing).offset(8)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(symbolLabel.snp.bottom).offset(2)
            $0.leading.equalTo(symbolLabel)
        }
        favoriteButton.snp.makeConstraints {
            $0.centerY.equalTo(symbolLabel)
            $0.leading.equalTo(symbolLabel.snp.trailing).offset(6)
            $0.width.height.equalTo(20)
        }
        priceLabel.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(8)
            $0.top.equalTo(symbolLabel)
        }
        changeLabel.snp.makeConstraints {
            $0.trailing.equalTo(priceLabel)
            $0.top.equalTo(priceLabel.snp.bottom).offset(2)
        }
    }
    
    @objc private func favTapped() {
        favoriteButtonAction?()
    }
    
    func configure(with stock: Stock, isFavorite: Bool, onFavoriteTapped: @escaping () -> Void) {
        symbolLabel.text = stock.symbol
        nameLabel.text = stock.name
        priceLabel.text = String(format: "$%.2f", stock.price)
        
        changeLabel.text = String(format: "%@%.2f (%.2f%%)",
                                  stock.change >= 0 ? "+" : "",
                                  stock.change,
                                  stock.changePercent)
        changeLabel.textColor = stock.change >= 0 ? .systemGreen : .systemRed
        
        favoriteButton.isSelected = isFavorite
        favoriteButton.tintColor = isFavorite ? .systemYellow : .lightGray
        favoriteButtonAction = onFavoriteTapped
        
        logoImageView.image = nil
        
        URLSession.shared.dataTask(with: stock.logo) { data, _, _ in
            guard let d = data, let img = UIImage(data: d) else { return }
            DispatchQueue.main.async {
                self.logoImageView.image = img
            }
        }.resume()
    }
}
