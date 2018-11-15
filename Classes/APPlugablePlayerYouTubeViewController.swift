//
//  APPlugablePlayerYouTubeViewController.swift
//  Pods
//
//  Created by Liviu Romascanu on 16/09/2016.
//
//

import UIKit
import ApplicasterSDK
import youtube_ios_player_helper

class APPlugablePlayerYouTubeViewController: UIViewController, YTPlayerViewDelegate {
    
    var player: YTPlayerView?
    var playItem: ZPPlayable?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    // MARK: - Init
    @objc public convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.player = YTPlayerView(frame: self.view.bounds)
        self.player?.delegate = self
        
        // YouTube Player doesnt handle PIP properly so disable it if in iOS 9
        if #available(iOS 9.0, *) {
            self.player?.webView?.allowsPictureInPictureMediaPlayback = false
        }
        self.addObservers()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: Bundle(for: type(of: self)))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Deallocate
    deinit {
        self.player?.stopVideo()
        self.player?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(self.player!)
        self.player?.matchParent()
    }
    
     // MARK: - YTPlayerDelegate
    public func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.player?.playVideo()
        APAnalyticsManager.trackEvent("Play VOD Item",
                                      withParameters: self.playItem?.analyticsParams(),
                                      timed: true)
    }
    
    public func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
    {
        if state == YTPlayerState.ended {
            finishPlayback()
        }
    }
    
    public func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        finishPlayback()
    }
    
    // MARK: - Private
    func finishPlayback()
    {
        APAnalyticsManager.endTimedEvent("Play VOD Item",
                                         withParameters: self.playItem?.analyticsParams())
        self.dismiss(animated: true, completion: nil)
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWhenPlayingInFullScreen),
                                               name:UIWindow.didBecomeVisibleNotification,
                                               object: self.player?.window)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWhenDoneButtonClick),
                                               name:UIWindow.didBecomeHiddenNotification,
                                               object: self.player?.window)
    }
    
    // MARK: - Observers
    @objc func handleWhenPlayingInFullScreen()
    {
        // video started playing, do nothing
    }
    
    @objc func handleWhenDoneButtonClick()
    {
        // Most likely done button clicked - Youtube hack - https://github.com/youtube/youtube-ios-player-helper/issues/149
        self.player?.stopVideo()
        finishPlayback()
    }
}
