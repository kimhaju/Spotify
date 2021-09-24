//
//  PlayerControllView.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/18.
//

import Foundation
import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    //->프로토콜의 필수 메서드 채택해야 하는 타입은 이걸 구현해줘야함.
    // 함수가 1개 이상이라면 클로저를 두세개 쓰는 것보다 프로토콜이 이득.
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    
    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView)
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

struct PlayerControlsViewViewModel {
    let title: String?
    let subtitle: String?
}

final class PlayerControlsView: UIView {
    
    private var isPlaying = true
    
    // -> 버튼을 볼수 있게 구현
    weak var delegate: PlayerControlsViewDelegate?
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
//        label.text = "This is my Songs"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
       let label = UILabel()
//        label.text = "피쳐링"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        // 라벨컬러는 다크모드 라이트 모드에 따라 유동적으로 색상이 변한다.
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        // 라벨컬러는 다크모드 라이트 모드에 따라 유동적으로 색상이 변한다.
        button.tintColor = .label
        let image = UIImage(systemName: "forward.fill" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        // 라벨컬러는 다크모드 라이트 모드에 따라 유동적으로 색상이 변한다.
        button.tintColor = .label
        let image = UIImage(systemName: "pause" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        
        addSubview(volumeSlider)
        volumeSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        
        //이전
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        // 다음
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        //일시중지
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didSlideSlider(_ slider: UISlider){
        let value = slider.value
        delegate?.playerControlsView(self, didSlideSlider: value)
    }
    // 뒤로가기 버튼 클릭시
    @objc private func didTapBack() {
        delegate?.playerControlsViewDidTapBackwardsButton(self)
    }
    //->다음버튼 클릭시
    @objc private func didTapNext() {
        delegate?.playerControlsViewDidTapForwardButton(self)
    }
    //->플레이 버튼 클릭시
    @objc private func didTapPlayPause() {
        self.isPlaying = !isPlaying
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
        
        // 업데이트 아이콘
        let pause = UIImage(systemName: "pause" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        
        let play = UIImage(systemName: "play.fill" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        
        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 이름
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        // 설명
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom + 10, width: width, height: 50)
        // 볼륨 슬라이더
        volumeSlider.frame = CGRect(x: 10, y: subtitleLabel.bottom+20, width: width-20, height: 44)
        let buttonSize: CGFloat = 60
        // 플레이 버튼 설정
        playPauseButton.frame = CGRect(x: (width - buttonSize)/2, y: volumeSlider.bottom + 30, width: buttonSize, height: buttonSize)
        // 뒤로가기
        backButton.frame = CGRect(x: playPauseButton.left-80-buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        // 다음곡 재생
        nextButton.frame = CGRect(x: playPauseButton.right+80, y: playPauseButton.top, width: buttonSize, height: buttonSize)
    }
    
    func configure(with viewModel: PlayerControlsViewViewModel){
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}

