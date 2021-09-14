//
//  FeaturedPlaylistCollectionViewCell.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/11.
//

import UIKit

//->재생목록 플레이 리스트
class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistsCoverImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
                                                         
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
                                                         
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        contentView.addSubview(playlistsCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //->플레이 리스트 목록
        
        /*
         이미지 사이즈 조정하면서 생각이 든거: 계속 이미지 사이즈랑, 보여지는 화면, 간격을 수시로 확인해서 맞추는 수밖에 없다.
         상수로 맞춰놔도 안맞는 값이 생기기 때문.
         */
        
        creatorNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height-30,
            width: contentView.width-6,
            height: 30
        )
        // 이름
        playlistNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height-60,
            width: contentView.width-6,
            height: 30
        )
        let imageSize = contentView.height-70
        playlistsCoverImageView.frame = CGRect(
            x: (contentView.width-imageSize)/2,
            y: 3,
            width: imageSize,
            height: imageSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        playlistsCoverImageView.image = nil
        creatorNameLabel.text = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel){
        playlistNameLabel.text = viewModel.name
        playlistsCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        creatorNameLabel.text = viewModel.creatorName
    }
}
