//
//  AlbumTrackCollectionViewCell.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/16.
//

import Foundation
import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumTrackCollectionViewCell"
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
                                                         
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
                                                         
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //->이미지 항목 배치. 여길 잘 보면서 계속 디버깅 할것
        // ui가 맞지 않거나 사이즈가 제대로 나오지 않는 경우도 오류에 해당.
        trackNameLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: contentView.width-15,
            height: contentView.height/2
        )
        artistNameLabel.frame = CGRect(
            x: 10,
            y: contentView.height/2,
            width: contentView.width-15,
            height: contentView.height/2
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func configure(with viewModel: AlbumCollectionViewCellViewModel){
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}

