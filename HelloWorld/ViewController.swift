//
//  ViewController.swift
//  HelloWorld
//
//  Created by Janas on 30.12.16.
//  Copyright © 2016 wesum. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let myEa = AETest()
    var frequency = 350
    var volume: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        
        
        // Do any additional setup after loading the view, typically from a nib.
        // phone ("075347239")
        NSLog ("viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog ("memory low");
    }

    @IBOutlet weak var helloButton: UIButton!

    /**
     * This sfunc does ... ta ta
     * parameter: sender Bla bla
     */
    @IBAction func showAlert(_ sender: Any) {
        var alert = UIAlertController (title: "Loss gehts", message: "!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction (title: "Schliessen", style: UIAlertActionStyle.default, handler: nil))
        self.present (alert, animated: true)
        NSLog ("did click")
        //phone ("075347239")
        self.helloButton.setTitle("Hallo!", for: UIControlState.normal)
        myEa.play(carrierFrequency: Float(frequency), modulatorAmplitude: 2)
        // AudioServicesPlaySystemSound (1021)
        //playSound (sound: "tock");
    }
    
    func phone(_ phoneNum: String) {
        if let url = URL(string: "tel://\(phoneNum)") {
            if #available(iOS 100, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    var player: AVAudioPlayer?
    
    func playSound(sound: String) {
        let url = Bundle.main.url(forResource: sound, withExtension: "aiff")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear (animated)
        NSLog ("will appear")
        //phone ("075347239")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog ("did appear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog ("did disappear")
    }
    func didBecomeActive() {
        
        NSLog("did become active")
    }
    
    func willEnterForeground() {
        NSLog("will enter foreground")
    }
    func didEnterBackground () {
        // AudioServicesPlaySystemSound (1024)
        NSLog("did enter background")
    }
    
    @IBOutlet weak var StopButton: UIButton!
    @IBAction func stop(_ sender: UIButton) {
        print ("stop ")
        myEa.stop ()
    }
    
    @IBOutlet weak var Slider1: UISlider!
    
    @IBAction func changc(_ sender: UISlider) {
        let freq = Int (sender.value)
        self.frequency = freq
        print ("freq = \(freq)")
        myEa.play(carrierFrequency: Float(freq), modulatorAmplitude: 2)
    }
    

    @IBOutlet weak var Slider2: UISlider!
    @IBAction func ChangeVolume(_ sender: UISlider) {

        let vol = sender.value
        self.volume = Int(sender.value)
        print ("vol = \(vol)")
        myEa.play(carrierFrequency: Float(frequency), modulatorAmplitude: vol)
    }
 }
