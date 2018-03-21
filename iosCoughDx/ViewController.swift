//
//  ViewController.swift
//  CoughDx
//
//  Created by Jaehwan Kim on 3/21/18.
//  Copyright © 2018 Jaehwan Kim. All rights reserved.
//

import UIKit
import AVFoundation

var audioRecorder:AVAudioRecorder!
var audioPlayer:AVAudioPlayer!
class ViewController: UIViewController {

    @IBOutlet weak var recordButton:UIButton!
    @IBOutlet weak var playButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.prepareAudioRecorder()
    }

    
    @IBAction func recordButtonPressed(sender:AnyObject) {
        if !audioRecorder.isRecording {
            // Start Recording
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {
                print(error)
            }
        } else {
            // Stop Recording
            audioRecorder.stop()
            
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
            } catch {
                print(error)
            }
            
            // Check
            if self.verifyFileExists() {
                print("File Exists")
                playButton.isHidden = false
            } else {
                print("There was a problem recording")
                
            }
        }
        
        self.updateRecordButtonTitle()
    }
    
    @IBAction func playButtonPressed(sender:AnyObject) {
        self.playAudio()
    }
    
    // MARK: Main
    func prepareAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: self.audioFileLocation()),
                                                settings: self.audioRecorderSettings())
            
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func playAudio() {
        let audioSession = AVAudioSession.sharedInstance();
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.audioFileLocation()))
            
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        catch{
            print(error)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Helpers
    func audioFileLocation() -> String {
        return
            NSTemporaryDirectory().appending("audioRecording.m4a")
    }
    
    func audioRecorderSettings() -> [String:Any] {
        let settings = [AVFormatIDKey : NSNumber.init(value: kAudioFormatAppleLossless),
                        AVSampleRateKey : NSNumber.init(value: 44100.0),
                        AVNumberOfChannelsKey : NSNumber.init(value: 1),
                        AVLinearPCMBitDepthKey : NSNumber.init(value: 16),
                        AVEncoderAudioQualityKey : NSNumber.init(value: AVAudioQuality.high.rawValue)]
        
        return settings
    }
    
    func updateRecordButtonTitle() {
        if audioRecorder.isRecording{
            recordButton.setTitle("Recording...", for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
    func verifyFileExists() -> Bool {
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: self.audioFileLocation())
    }
}

