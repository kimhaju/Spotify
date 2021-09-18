//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/18.
//

import AVFoundation
import Foundation
import UIKit

//->데이터 소스 프로토콜 생성(재생할때 뜨는 이미지 연결)
protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get } 
}

//->재생을 구현해보자. 실제로 재생할수 있도록
// 9.19: 재생은 저작권 문제로 인해서 불가능... 재생하려면 일부 오디오 파일을 저장해서 에셋에 담아야 한다. 원하는 곡 한두개 정도 담아서 테스트 하기
final class PlaybackPresenter {
    
    //->정적인 구현 사용
    static let shared = PlaybackPresenter()
    
    private var track: AudioTrack?
    private var tracks =  [AudioTrack]()
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if !tracks.isEmpty {
            return tracks.first
        }
        return nil
    }
    
    var player: AVPlayer?
    
     func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ){
        guard let url = URL(string: track.preview_url ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.0
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self]  in
            self?.player?.play()
        }
    }
    
    func startPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ){
        self.tracks = tracks
        self.track = nil
        let vc = PlayerViewController()
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
