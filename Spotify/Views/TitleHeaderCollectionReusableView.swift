//
//  TitleHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/16.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
        static let identifier = "TitleHeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = .systemBackground
        //->하위 보기 추가
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    
    func configure(with title: String){
        label.text = title
        
    }
}
