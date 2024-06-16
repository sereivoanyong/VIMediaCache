//
//  PlayerView.swift
//  VIMediaCacheDemoSwift
//
//  Created by Sereivoan Yong on 6/16/24.
//

import UIKit
import AVFoundation

extension AVPlayerItem.Status: CustomStringConvertible {

  public var description: String {
    switch self {
    case .unknown:
      return ".unknown"
    case .readyToPlay:
      return ".readyToPlay"
    case .failed:
      return ".failed"
    }
  }
}

extension AVPlayer.Status: CustomStringConvertible {

  public var description: String {
    switch self {
    case .unknown:
      return ".unknown"
    case .readyToPlay:
      return ".readyToPlay"
    case .failed:
      return ".failed"
    }
  }
}

extension AVPlayer.TimeControlStatus: CustomStringConvertible {

  public var description: String {
    switch self {
    case .paused:
      return ".paused"
    case .waitingToPlayAtSpecifiedRate:
      return ".waitingToPlayAtSpecifiedRate"
    case .playing:
      return ".playing"
    }
  }
}

extension AVPlayer.WaitingReason: CustomStringConvertible {

  public var description: String {
    return rawValue
  }
}

class PlayerView: UIView {

  override class var layerClass: AnyClass {
    return AVPlayerLayer.self
  }

  override var layer: AVPlayerLayer {
    return super.layer as! AVPlayerLayer
  }

  var player: AVPlayer? {
    get { return layer.player }
    set { layer.player = newValue }
  }
}
