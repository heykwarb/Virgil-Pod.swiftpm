//
//  playerModel.swift
//  nea2k music
//
//  Created by Yohey Kuwabara on 2022/02/20.
//

import Foundation
import SwiftUI
import MusicKit
import MediaPlayer
import WidgetKit

class playerModel: ObservableObject{
    @Published var showPicker = false
    @Published var isPicked = false
    
    ///@Published var songTitle = "Song Title"
   /// @Published var artistName = "Artist Name"
    @Published var albumArt: UIImage?
    @Published var progress: CGFloat = 0
    @Published var progressOffset: CGFloat = 0
    @Published var progressBar: CGFloat = 260
    @Published var cPTime = " "
    @Published var pDuration = " "
    
    @Published var playbackStateImage = ""
    ///@Published var playStatusIcon = "pause.fill"
    ///@Published var playbackState = MPMusicPlayerController.systemMusicPlayer.playbackState
    
    @Published var collection: MPMediaItemCollection?
    @Published var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    ///@Published var mediaItem = MPMediaItem()
    
    @Published var batteryValue: Int = 100
    @Published var batteryLevel = " "
    ///@Published var batterySymbol = "battery.100"
    
    var timer: Timer!
    
    @AppStorage("songTitle", store: UserDefaults(suiteName: "group.com.heykwarb.nea2k-music")) var songTitle = "song title"
    @AppStorage("artistName", store: UserDefaults(suiteName: "group.com.heykwarb.nea2k-music")) var artistName = "artist name"
    @AppStorage("albumTitle", store: UserDefaults(suiteName: "group.com.heykwarb.nea2k-music")) var albumtitle = "album title"
    @AppStorage("isPlaying", store: UserDefaults(suiteName: "group.com.heykwarb.nea2k-music")) var isPlaying = false
    @AppStorage("batterySymbol", store: UserDefaults(suiteName: "group.com.heykwarb.nea2k-music")) var batterySymbol = ""
    
    func picker(){
        if isPicked == true{
            musicPlayer.setQueue(with: collection!)
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            songTitle = musicPlayer.nowPlayingItem?.title ?? "song title"
            albumtitle = musicPlayer.nowPlayingItem?.albumTitle ?? "album title"
            artistName = musicPlayer.nowPlayingItem?.artist ?? "artist name"
            albumArt = musicPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 200, height: 200))
            
        }else{
            
        }
        print("isPicked: \(isPicked)")
        getMediaInfo()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getMediaInfo(){
        albumArt = musicPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 200, height: 200))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { Timer in
            if self.musicPlayer.playbackState == .playing{
                self.getBatteryLevel()
                self.getPlayBackTime()
                self.playbackStateImage = "pause.fill"
                self.isPlaying = true
                print("get info")
            }else if self.musicPlayer.playbackState == .paused{
                self.playbackStateImage = "play.fill"
            }else if self.musicPlayer.playbackState == .stopped{
                ///self.playbackStateImage = "stop.fill"
            }
        }
    }
    
    func getPlayBackTime(){
        progress = musicPlayer.currentPlaybackTime/musicPlayer.nowPlayingItem!.playbackDuration*progressBar
        progressOffset = -progressBar/2 + CGFloat(musicPlayer.currentPlaybackTime /  musicPlayer.nowPlayingItem!.playbackDuration)*progressBar/2
        
        let durMin = String(format: "%02d", Int(musicPlayer.nowPlayingItem!.playbackDuration)/60)
        let durSec = String(format: "%02d", Int(musicPlayer.nowPlayingItem!.playbackDuration)%60)
        let cPTmin = String(format: "%02d", Int(musicPlayer.currentPlaybackTime)/60)
        let cPTsec = String(format: "%02d", Int(musicPlayer.currentPlaybackTime)%60)
        
        cPTime = "\(cPTmin):\(cPTsec)"
        pDuration = "\(durMin):\(durSec)"
    }
    
    func getBatteryLevel(){
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryValue = Int(UIDevice.current.batteryLevel * 100)
        batteryLevel = String(format: "%0.1f", UIDevice.current.batteryLevel * 100)
        if batteryValue > 75{
            batterySymbol = "battery.100"
        }else if batteryValue > 50{
            batterySymbol = "battery.75"
        }else if batteryValue > 25{
            batterySymbol = "battery.50"
        }else if batteryValue > 5{
            batterySymbol = "battery.25"
        }else {
            batterySymbol = "battery.0"
        }
    }
    
    func playButton(){
        if musicPlayer.playbackState == .playing{
            getMediaInfo()
            musicPlayer.pause()
            print("pause")
        }else {
            ///getMediaInfo()
            musicPlayer.play()
            print("play")
        }
    }
    
    func forward(){
        musicPlayer.skipToNextItem()
        ///getMediaInfo()
        print("forward")
    }
    
    func backward(){
        musicPlayer.skipToPreviousItem()
        ///getMediaInfo()
        print("backward")
    }
}

struct MusicPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var collection: MPMediaItemCollection?
    
    @Binding var isPicked: Bool

    class Coordinator: NSObject, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
        var parent: MusicPicker
        init(_ parent: MusicPicker) {
            self.parent = parent
        }
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            if (mediaItemCollection.items.count) > 0 {
                parent.collection = mediaItemCollection
                mediaPicker.dismiss(animated: true, completion: nil)
                parent.isPicked = true
                
            }else{
                parent.isPicked = false
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<MusicPicker>) -> MPMediaPickerController {
        let picker = MPMediaPickerController()
        picker.allowsPickingMultipleItems = true
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: UIViewControllerRepresentableContext<MusicPicker>) {
    }
}
