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

class ViewController: UIViewController, AVAudioPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    @IBOutlet weak var recordButton:UIButton!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    var recordList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Picker list
        recordList = ["test1", "test2"]
        
        // Connect data to picker:
        self.picker.delegate = self
        self.picker.dataSource = self
        
        self.prepareAudioRecorder()
    }


    // Button Pressed Functions
    @IBAction func recordButtonPressed(sender:AnyObject) {
        if !audioRecorder.isRecording {
            // Start Recording
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                prepareAudioRecorder()
                
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
            if audioRecorder == nil {
                try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: self.audioFileLocation()),
                                                     settings: self.audioRecorderSettings())
            }
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
            
            audioPlayer.delegate = self
            
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                playButton.setTitle("Play", for: .normal)
                
                try audioSession.setActive(false)
            }
            else {
                try audioSession.setActive(true)
                
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                playButton.setTitle("Stop", for: .normal)
            }
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
    
    func deleteFileIfExists () {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: self.audioFileLocation()) {
                try fileManager.removeItem(atPath: self.audioFileLocation())
                
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: Handlers for AudioPlayer events
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        print(flag)
        print("Audio playing done")
        
        playButton.setTitle("Play", for: .normal)
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            try audioSession.setActive(false)
        }
        catch {
            print(error)
        }
    }
    
    // PickerView Delegate functions
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recordList.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recordList[row]
    }
}

