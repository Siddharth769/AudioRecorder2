//
//  ViewController.swift
//  AudioRecorder2
//
//  Created by siddharth on 30/01/19.
//  Copyright © 2019 clarionTechnologies. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {

    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var numberOfRecords: Int = 0
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAudioSession()
        retrieveNumberOfRecordings()
    }
}



extension ViewController {
    
    func getDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }
    
    func initializeAudioSession(){
        recordingSession = AVAudioSession.sharedInstance()
    }
    
    func recordOneSession(){
        let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        let audioSettings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100.0,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            startButton.setTitle("Stop Recording", for: .normal)
        } catch {
            displayAlert(title: "Failure", message: "Recording Failed")
        }
    }
    
    func retrieveNumberOfRecordings(){
        if let number = UserDefaults.standard.object(forKey: "RecordingNumber") as? Int {
            numberOfRecords = number
        }
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}



extension ViewController {
    
    @IBAction func startButtonAction(_ sender: Any) {
        if audioRecorder == nil {
            numberOfRecords += 1
            recordOneSession()
        }else {
            audioRecorder?.stop()
            audioRecorder = nil
            
            UserDefaults.standard.set(numberOfRecords, forKey: "RecordingNumber")
            tableView.reloadData()
            startButton.setTitle("Start Recording", for: .normal)
        }
    }
}



extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Recording Number #\(String(indexPath.row + 1))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pathToAudio = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: pathToAudio)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            print("Error Playing Audio: \(error.localizedDescription)")
        }
    }   
}
