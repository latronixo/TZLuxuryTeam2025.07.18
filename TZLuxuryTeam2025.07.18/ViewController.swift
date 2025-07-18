//
//  ViewController.swift
//  TZLuxuryTeam2025.07.18
//
//  Created by Валентин on 18.07.2025.
//

import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private lazy var searchBar: UISearchBar = {
        let element = UISearchBar()
        //element.placeholder = "Find company or ticker"
        
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
        
        // Замена иконки лупы на SF Symbol
        let searchIcon = UIImageView(image: UIImage(named: "searchIcon"))
        searchIcon.tintColor = .black
        searchIcon.contentMode = .scaleAspectFit
        let searchIconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        searchIcon.frame = CGRect(x: 10, y: 8, width: 15, height: 15)
        searchIconContainer.addSubview(searchIcon)
        textField.leftView = searchIconContainer
        
        //убираем верхнюю и нижнюю границы
        element.backgroundImage = UIImage()
        return element
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setup()
        setupConstraints()
    }
    
    private func setup() {
        view.addSubview(searchBar)
        

    }
    
    private func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(15)
            
        }
    }


}

