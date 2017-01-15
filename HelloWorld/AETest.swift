import AVFoundation
import Foundation

// The maximum number of audio buffers in flight. Setting to two allows one
// buffer to be played while the next is being written.
private let kInFlightAudioBuffers: Int = 2

// The number of audio samples per buffer. A lower value reduces latency for
// changes but requires more processing but increases the risk of being unable
// to fill the buffers in time. A setting of 1024 represents about 23ms of
// samples.
private let rate = 44100

private let kSamplesPerBuffer: AVAudioFrameCount = AVAudioFrameCount(rate)

// The single FM synthesizer instance.
private let gFMSynthesizer: AETest = AETest()

public class AETest {
    
    // The audio engine manages the sound system.
    private let engine: AVAudioEngine = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    // Use standard non-interleaved PCM audio.
   
    let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(Float (rate)), channels: 2)
    
    // A circular queue of audio buffers.
    private var audioBuffer  = AVAudioPCMBuffer()
    
    private var audioBuffer2  = AVAudioPCMBuffer()
    
    // The index of the next buffer to fill.
    private var bufferIndex: Int = 0
    
    var distortion = AVAudioUnitDistortion()
    var isPlaying = false
    
    public class func sharedSynth() -> AETest {
        return gFMSynthesizer
    }
    
    init() {
        // Create a pool of audio buffers.
       
        audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: kSamplesPerBuffer)
        
        
        distortion.loadFactoryPreset(.speechCosmicInterference)
        distortion.preGain = 4.0
        engine.attach(distortion)
        
        // Attach and connect the player node.
        engine.attach(playerNode)
        //engine.connect(playerNode, to: distortion, format: audioFormat)
        //engine.connect(distortion, to: engine.mainMixerNode, format: audioFormat)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)
        
        do {
           try engine.start ()
        } catch  {
            NSLog("Error starting audio engine")
        }
    }
    
    public func play(carrierFrequency: Float32, modulatorAmplitude: Float32) {
        print ("sampleRate = \(audioFormat.sampleRate)")
        var sampleTime: Float32 = 0
        
        // Fill the buffer with new samples.
        let leftChannel = audioBuffer.floatChannelData?[0]
        let rightChannel = audioBuffer.floatChannelData?[1]
        var lastSample = Float (0)
        //let cycles = Int (Float (rate) / (2 * Float32(M_PI) * carrierFrequency))
        let cycles = Int (Float (rate) / carrierFrequency)
        //let count: Int =  Int(carrierFrequency * 2.0 * Float32 (M_PI) * Float(cycles))
        let count: Int =  Int(Float(cycles) * carrierFrequency)
        for sampleIndex in 0 ... count {
            
            // let sample = sin(carrierFrequency * sampleTime * Float32(2.0 * M_PI)) * modulatorAmplitude
            let sample = sin((carrierFrequency * sampleTime * Float32(2.0 * M_PI)) / Float (count)) * modulatorAmplitude
            leftChannel?[sampleIndex] = sample
            rightChannel?[sampleIndex] = sample
            if count == 0 {
                print ("sample = \(sample)")

            }
            sampleTime += 1
            lastSample = sample
        }
        audioBuffer.frameLength = AVAudioFrameCount (count)
         print ("cycles = \(cycles)")
        print ("carrierFrequency = \(carrierFrequency)")
        print ("count = \(count)")
        print ("last sample = \(lastSample)")
        
        // Schedule the buffer for playback and release it for reuse after
        // playback has finished.
        playerNode.pan = 0
        playerNode.play()
        self.playerNode.scheduleBuffer(audioBuffer, at: nil, options: [.interruptsAtLoop,.loops ] )
        //playerNode.play()
        
        NSLog ("before play")
        if isPlaying == false {
            // playerNode.pan = 0
            // playerNode.play()
            isPlaying = true
        }
        
        NSLog ("after play")

    }
    public func stop() {
        audioBuffer2 = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: kSamplesPerBuffer)
        
        let leftChannel = audioBuffer2.floatChannelData?[0]
        let rightChannel = audioBuffer2.floatChannelData?[1]
        let sample = Float(0)
        leftChannel?[0] = sample
        rightChannel?[0] = sample
        audioBuffer2.frameLength = 1
        self.playerNode.play()
        self.playerNode.scheduleBuffer(audioBuffer2, at: nil, options: [.interruptsAtLoop,.loops ])
        
        
    }
    
    @objc private func audioEngineConfigurationChange(notification: NSNotification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }
    
}
