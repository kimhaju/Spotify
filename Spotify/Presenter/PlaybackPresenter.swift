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
        else if let player = self.playerQueue, !tracks.isEmpty {
            let item = player.currentItem
            let items = player.items()
            guard let index = items.firstIndex(where: { $0 == item }) else {
                return nil
            }
            return tracks[index]
            
        }
        return nil
    }
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    
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
        vc.delegate = self
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
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
                //->url 생성
                guard let url = URL(string: $0.preview_url ?? "") else {
                    return nil
                }
                return AVPlayerItem(url: url)
            }))
        self.playerQueue?.volume = 1
//        self.playerQueue?.volume = 0
        // 여기서 볼륨설정하면 실제로 재생이 가능! 다만 저작권 문제로 인해서 테스트 할때만 볼륨설정하고 평소에는 0으로 맞춰두기
        self.playerQueue?.play()
        
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

//->재생, 다음버튼, 뒤로가기 연결
extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            }
            else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        else if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            }
            else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            // 앨범에 재생목록이 없다.
            player?.pause()
        }
        else if let firstItem = playerQueue?.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            //->저작권 문제를 위해서는 테스트를 제외하고 볼륨을 항상 0으로
            playerQueue?.volume = 1
//            playerQueue?.volume = 0
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            // 앨범에 재생목록이 없다.
            player?.pause()
            player?.play()
        } else if let player = playerQueue {
            playerQueue?.advanceToNextItem()
        }
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
        print("images: \(currentTrack?.album?.images.first)")
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
