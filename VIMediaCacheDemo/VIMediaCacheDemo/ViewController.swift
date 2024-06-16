//
//  ViewController.swift
//  VIMediaCacheDemoSwift
//
//  Created by Sereivoan Yong on 6/16/24.
//

import UIKit
import VIMediaCache

class ViewController: UIViewController {

  var resourceLoaderManager: VIResourceLoaderManager!
  var player: AVPlayer!
  var playerItem: AVPlayerItem!
  var timeObserver: Any?
  var duration: CMTime?

  @IBOutlet weak private var playerView: PlayerView!
  @IBOutlet weak private var slider: UISlider!
  @IBOutlet weak private var totalTimeLabel: UILabel!
  @IBOutlet weak private var currentTimeLabel: UILabel!

  var downloader: VIMediaDownloader!

  deinit {
    NotificationCenter.default.removeObserver(self)
    if let timeObserver {
      player.removeTimeObserver(timeObserver)
    }
    timeObserver = nil
    playerItem.removeObserver(self, forKeyPath: "status")
    player.removeObserver(self, forKeyPath: "timeControlStatus")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    cleanCache()

//    let url = URL(string: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4")!
//    downloader = VIMediaDownloader(url: url, cacheWorker: VIMediaCacheWorker(url: url))
//    downloader.downloadFromStartToEnd()

    setupPlayer()

    NotificationCenter.default.addObserver(self, selector: #selector(mediaCacheDidChanged(_:)), name: .VICacheManagerDidUpdateCache, object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    player.play()
  }

  func cleanCache() {
    let fileSize = VICacheManager.calculateCachedSizeWithError(nil)
    print("file cache size: \(fileSize)")
    var error: NSError?
    VICacheManager.cleanAllCacheWithError(&error)
    if let error {
      print("clean cache failure: \(error)")
    }

    VICacheManager.cleanAllCacheWithError(&error)
  }

  @IBAction private func touchSliderAction(_ sender: UISlider) {
    sender.tag = -1
  }

  @IBAction private func sliderAction(_ sender: UISlider) {
    guard let currentItem = player.currentItem else { return }
    let duration = currentItem.asset.duration
    let seekTo = CMTime(value: CMTimeValue(Double(duration.value) * Double(sender.value)), timescale: duration.timescale)
    print("seekTo \(CMTimeValue(Double(duration.value) * Double(sender.value)) / Int64(duration.timescale))")
    player.pause()
    player.seek(to: seekTo) { [weak self] finished in
      guard let self else { return }
      sender.tag = 0
      player.play()
    }
  }

  @IBAction private func toggleAction(_ sender: Any) {
    cleanCache()

    playerItem.removeObserver(self, forKeyPath: "status")
    player.removeObserver(self, forKeyPath: "timeControlStatus")

    resourceLoaderManager.cancelLoaders()

    let url = URL(string: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4")!
    playerItem = resourceLoaderManager.playerItem(with: url)

    playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
    player.replaceCurrentItem(with: playerItem)
  }

  // MARK: Setup

  func setupPlayer() {
//    let url = URL(string: "http://gedftnj8mkvfefuaefm.exp.bcevod.com/mda-hc2s2difdjz6c5y9/hd/mda-hc2s2difdjz6c5y9.mp4?playlist%3D%5B%22hd%22%5D&auth_key=1500559192-0-0-dcb501bf19beb0bd4e0f7ad30c380763&bcevod_channel=searchbox_feed&srchid=3ed366b1b0bf70e0&channel_id=2&d_t=2&b_v=9.1.0.0")!
//    let url = URL(string: "https://mvvideo5.meitudata.com/56a9e1389b9706520.mp4")!
    let url = URL(string: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4")!

    resourceLoaderManager = VIResourceLoaderManager()

    playerItem = resourceLoaderManager.playerItem(with: url)

    let configuration = VICacheManager.cacheConfiguration(for: url)
    if configuration.progress >= 1.0 {
      print("cache completed")
    }

    player = AVPlayer(playerItem: playerItem)
    player.automaticallyWaitsToMinimizeStalling = false
    playerView.player = player

    timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: DispatchQueue(label: "player.time.queue")) { [weak self] time in
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        if slider.tag == 0 {
          let duration = player.currentItem!.duration.seconds
          totalTimeLabel.text = String(format: "%.f", duration)
          let currentDuration = time.seconds
          currentTimeLabel.text = String(format: "%.f", currentDuration)
          slider.value = Float(currentDuration / duration)
        }
      }
      guard let self else { return }
    }

    playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)

    let tap = UITapGestureRecognizer(target: self, action: #selector(tapPlayerViewAction(_:)))
    playerView.addGestureRecognizer(tap)
  }

  @objc private func tapPlayerViewAction(_ gesture: UITapGestureRecognizer) {
    if gesture.state == .ended {
      if player.rate > 0 {
        player.pause()
      } else {
        player.play()
      }
    }
  }

  // MARK: KVO

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    if object as? AVPlayerItem == playerItem && keyPath == "status" {
      print("player status \(playerItem.status), rate \(player.rate), error: \(playerItem.error)")
      if (playerItem.status == .readyToPlay) {
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          let duration = playerItem.duration.seconds
          totalTimeLabel.text = String(format: "%.f", duration)
        }
      } else if playerItem.status == .failed {
        // something went wrong. player.error should contain some information
        print("player error \(playerItem.error)")
      }
    } else if object as? AVPlayer == player && keyPath == "timeControlStatus" {
      print("timeControlStatus: \(player.timeControlStatus), reason: \(player.reasonForWaitingToPlay?.description ?? "nil"), rate: \(player.rate)")
    }
  }

  // MARK: Notification

  @objc private func mediaCacheDidChanged(_ notification: Notification) {
    guard let userInfo = notification.userInfo, let configuration = userInfo[VICacheConfigurationKey] as? VICacheConfiguration else { return }
    let cachedFragments = configuration.cacheFragments().map(\.rangeValue)
    let contentLength = configuration.contentInfo.contentLength

    let number = 100
    var progressStr = ""

    for (idx, range) in cachedFragments.enumerated() {
      let location = Int(round((Double(range.location) / Double(contentLength)) * Double(number)))

      let progressCount = progressStr.utf16.count
      string(&progressStr, append: "0", muti: location - progressCount)

      let length = Int(round((Double(range.length) / Double(contentLength)) * Double(number)))
      string(&progressStr, append: "1", muti: length)


      if idx == cachedFragments.count - 1 && (location + length) <= number + 1 {
        string(&progressStr, append: "0", muti: number - (length + location))
      }
    }

    print(progressStr)
  }

  func string(_ string: inout String, append appendString: String, muti: Int) {
    for _ in 0..<muti {
      string += appendString
    }
  }
}
