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
final class PlaybackPresenter {
    
    //->정적인 구현 사용
    static let shared = PlaybackPresenter()
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var index = 0
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
//            print("\(tracks.isEmpty)")
            //->비어있는 것을 확인했다. 왜 비었는지 원인을 찾고다녔지만 결국 못찾아서 이문제는 잠시 보류 이거 해결못하면 그냥 조건없이 다음버튼 누르면 넘어가는 식으로 진행하면 될듯
            
            return track
        }
        //->지금 트랙이 비어있어서 트랙을 그대로 반환한다, 왜 트랙이 nil인지 이유를 찾아보자
        else if let player = self.playerQueue, !tracks.isEmpty {
            return tracks[index]
           
        }
        return nil
    }
    
    var playerVC: PlayerViewController?
    
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
        //->테스트 할때만 여기 0.5 그 외네는 0.0
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
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
        self.playerQueue?.volume = 0.0
        self.playerQueue?.play()
        
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
    }
}

//->재생, 다음버튼, 뒤로가기 연결
extension PlaybackPresenter: PlayerViewControllerDelegate {
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
            player?.pause()
        }
        else if let player = playerQueue {
            player.advanceToNextItem()
            index += 1
            print(index)
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            // 앨범에 재생목록이 없다.
            player?.pause()
            player?.play()
            
        } else if let firstItem = playerQueue?.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            //->저작권 문제를 위해서는 테스트를 제외하고 볼륨을 항상 0으로
            playerQueue?.volume = 0
            
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
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
