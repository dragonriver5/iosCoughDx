//
//  ViewController.swift
//  CoughDx
//
//  Created by Jaehwan Kim on 3/21/18.
//  Copyright © 2018 Jaehwan Kim. All rights reserved.
//

import UIKit
import AVFoundation

//
let recordInterval = 2.0;

var audioRecorder:AVAudioRecorder!
var audioPlayer:AVAudioPlayer!

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var recordButton:UIButton!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    // State variables
    var recordList = [String]()
    var fileCounter = Int(0)
    var isAcquiring  = Bool(false)
    
    var recordFilename = String("audioFile_0.wav")
    var playFilename = String("audioFile_0.wav")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Picker list
        recordList = []
        
        // Connect data to picker:
        self.picker.delegate = self
        self.picker.dataSource = self
        
        self.prepareAudioRecorder()
    }


    // Button Pressed Functions
    @IBAction func recordButtonPressed(sender:AnyObject) {
        //if !audioRecorder.isRecording {
        if !isAcquiring {
            // Start Recording
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                prepareAudioRecorder()
                
                try audioSession.setActive(true)
                
                audioRecorder.record(forDuration: recordInterval)
                
                isAcquiring = true
            } catch {
                print(error)
                isAcquiring = false
            }
        } else {
            // Stop Recording
            isAcquiring = false
            audioRecorder.stop()
            /*
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
            } catch {
                print(error)
            }
            
            // Check if file was generated and recording successful
            print(recordFilename)
            if self.verifyFileExists(filename: recordFilename) {
                print("File Exists")
                playButton.isHidden = false
                picker.isHidden = false
                recordList.append(recordFilename)
                picker.reloadAllComponents()
                
                // Increment file counter
                fileCounter += 1
                recordFilename = "audioFile_"+String(fileCounter)+".wav"
                
            } else {
                print("There was a problem recording")
                
            }*/
        }
        
        self.updateRecordButtonTitle()
    }
    
    @IBAction func playButtonPressed(sender:AnyObject) {
        // Stop recording if it is acquiring
        if isAcquiring {
            self.recordButtonPressed(sender: self)
        }
        self.playAudio()
    }
    
    // MARK: Main
    func prepareAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            // Destroy any previous audioRecorder object
            audioRecorder = nil
            // Create AVAudioRecorder object
            try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: self.audioFileLocation(filename: recordFilename)), settings: self.audioRecorderSettings())
            
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            
        } catch {
            print(error)
        }
    }
    
    func playAudio() {
        let audioSession = AVAudioSession.sharedInstance();
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            //try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.audioFileLocation()))
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.audioFileLocation(filename: playFilename)))
            
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
    func audioFileLocation(filename: String) -> String {
        return
            NSTemporaryDirectory().appending(filename)
    }
    
    func audioRecorderSettings() -> [String:Any] {
        let settings = [AVFormatIDKey : NSNumber.init(value: kAudioFormatLinearPCM),
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
    
    func verifyFileExists(filename: String) -> Bool {
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: self.audioFileLocation(filename: filename))
    }
    
    func deleteFileIfExists (filename: String) {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: self.audioFileLocation(filename: filename)) {
                try fileManager.removeItem(atPath: self.audioFileLocation(filename: filename))
                
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: Handlers for AudioRecorder and AudioPlayer finish events
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
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print(flag)
        print("Audio finished recording")
        
        // Check if file was generated and recording successful
        print(recordFilename)
        if self.verifyFileExists(filename: recordFilename) {
            print("File Exists")
            playButton.isHidden = false
            picker.isHidden = false
            recordList.append(recordFilename)
            picker.reloadAllComponents()
            
            // Increment file counter
            fileCounter += 1
            recordFilename = "audioFile_"+String(fileCounter)+".wav"
            
        } else {
            print("There was a problem recording")
        }
        
        // If is still acquiring than and restart recording
        if isAcquiring {
            // Start Recording
            //let audioSession = AVAudioSession.sharedInstance()
            
            do {
                prepareAudioRecorder()
                
                //try audioSession.setActive(true)
                
                audioRecorder.record(forDuration: recordInterval)
                
                isAcquiring = true
            } catch {
                print(error)
                isAcquiring = false
            }
        }
        else {
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
            } catch {
                print(error)
            }
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
    
    // When user selects a file on the picker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        playFilename = recordList[row]
    }
}

