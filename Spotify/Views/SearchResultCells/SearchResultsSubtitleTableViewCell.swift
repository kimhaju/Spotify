//
//  SearchResultsSubtitleTableViewCell.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/18.
//

import UIKit
import SDWebImage

//->검색결과가 없을시 보여주는 화면
class SearchResultSubtitleTableViewCell: UITableViewCell {
    
    //->아이덴티 파이어가 중복으로 떠서 누락된 항목이 생겼다. 잘 확인할것
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    private let label: UILabel = {
       let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType  = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10
        iconImageView.frame = CGRect(
            x: 10,
            y: 5,
            width: imageSize,
            height: imageSize
        )
        iconImageView.layer.cornerRadius = imageSize/2
        iconImageView.layer.masksToBounds = true
        let labelHeight = contentView.height/2
        label.frame = CGRect(
            x: iconImageView.right+10,
            y: 0,
            width: contentView.width-iconImageView.right-15,
            height: labelHeight
        )
        
        subtitleLabel.frame = CGRect(
            x: iconImageView.right+10,
            y: label.bottom,
            width: contentView.width-iconImageView.right-15,
            height: labelHeight
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel){
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL,placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
}
