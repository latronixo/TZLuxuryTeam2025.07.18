import UIKit

class PopularHistoryButtonCell: UICollectionViewCell {
    static let reuseID = "PopularHistoryButtonCell"
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1)
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? UIColor(red: 0.85, green: 0.89, blue: 0.93, alpha: 1) : UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1)
        }
    }
    func configure(text: String) {
        titleLabel.text = text
    }
} 
