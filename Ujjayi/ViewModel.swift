//
//  ViewModel.swift
//  test-211211-ujjayi
//
//  Created by Aleksandr Borisov on 12.12.2021.
//

import SwiftUI
import Combine
import AVFoundation

class ViewModel: ObservableObject {
    @Published var timerState: TimerState = .stopped
    
    var timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    var timerCancellable: Cancellable?
    var cancellables = Set<AnyCancellable>()
    
    @Published var pranayama: Pranayama {
        didSet {
            if let encoded = try? JSONEncoder().encode(pranayama) {
                UserDefaults.standard.set(encoded, forKey: Const.pranayamaStore)
            }
        }
    }
    
    var bangCycle = 0
    var bangPhaseIndex = 0
    var bangCount = 0
    
    @Published var count = 0
    @Published var maxCounts = 0
    
    @Published var phaseIndex = 4
    @Published var phaseTitle = ""
    
    @Published var cycle = 1
    @Published var maxCycles = 1
    
    @Published var time = 0
    @Published var totalTime = 0
    
    @Published var timeString = ""
    @Published var totalTimeString = ""
    
    @Published var proportionString = ""
    @Published var startPauseTitle = ""
    
    @Published var hueAnimationValue: Double = 0
    @Published var scaleAnimationValue: Double = 0
    
    var params: [Int] { [pranayama.inhale,
                         pranayama.innerHold,
                         pranayama.exhale,
                         pranayama.outerHold,
                         pranayama.cycles] }
    var phases: Array<Int>.SubSequence { params[...3] }
    
    let synth = AVSpeechSynthesizer()
    let utteranceVoice = AVSpeechSynthesisVoice(language: "en-US")!
    let utteranceRate = AVSpeechUtteranceDefaultSpeechRate
    
    var audioPlayer = AVAudioPlayer()
    
    @Published var saveName = ""
    @Published var saveNameNotUnique = false
    
    @Published var showOpenView = false
    @Published var showSaveView = false
    @Published var showSettingsView = false
    
    @Published var presets: [Preset] = {
        do {
            guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
            let fileURL = documentDirectoryURL.appendingPathComponent(Const.jsonStorageName)
            return try JSONDecoder().decode([Preset].self, from: try Data(contentsOf: fileURL))
        } catch {
            print(error.localizedDescription)
            return []
        }
    }()
    
    @Published var pickersAreVisible = Array(repeating: false, count: 5)
    
    func resetPickersVisibility() {
        pickersAreVisible = Array(repeating: false, count: 5)
    }
    
    init() {
        
        if let saved = UserDefaults.standard.data(forKey: Const.pranayamaStore),
            let decoded = try? JSONDecoder().decode(Pranayama.self, from: saved) {
                pranayama = decoded
        } else {
            pranayama = Pranayama(inhale: 1,
                                  innerHold: 1,
                                  exhale: 1,
                                  outerHold: 1,
                                  cycles: 12)
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: Const.metronome, ofType: nil)!))
            audioPlayer.prepareToPlay()
        } catch {}
        
        $phaseIndex
            .map { self.params[$0] }
            .weakAssign(to: \.maxCounts, on: self)
            .store(in: &cancellables)
        
        $phaseIndex
            .map { Phase.allCases[$0].hueAnimationValue }
            .weakAssign(to: \.hueAnimationValue, on: self)
            .store(in: &cancellables)
        
        $phaseIndex
            .map { Phase.allCases[$0].scaleAnimationValue }
            .weakAssign(to: \.scaleAnimationValue, on: self)
            .store(in: &cancellables)

        $pranayama
//            .map { self.phases[self.phaseIndex] }
            .map { [$0.inhale, $0.innerHold, $0.exhale, $0.outerHold, 0][self.phaseIndex] }
            .weakAssign(to: \.maxCounts, on: self)
            .store(in: &cancellables)
        
        $phaseIndex
            .removeDuplicates()
            .map { Phase.allCases[$0].title }
            .weakAssign(to: \.phaseTitle, on: self)
            .store(in: &cancellables)
        
        $phaseIndex
            .removeDuplicates()
            .filter { $0 < 4 }
            .map { Phase.allCases[$0].title }
            .sink(receiveValue: {
                self.speak(string: $0)
            })
            .store(in: &cancellables)

        $pranayama
            .map { $0.cycles }
            .weakAssign(to: \.maxCycles, on: self)
            .store(in: &cancellables)

        $count
            .map {
                let previousCyclesSeconds = self.phases.reduce(0, +) * (self.cycle - 1)
                let currentCyclesSeconds = (0..<self.phaseIndex % 4)
                    .map { self.phases[$0] }
                    .reduce(0, +)
                return self.totalTime - (previousCyclesSeconds + currentCyclesSeconds + $0)
            }
            .weakAssign(to: \.time, on: self)
            .store(in: &cancellables)
        
        $pranayama
//            .map { [self.phases.reduce(0, +), $0.cycles].reduce(1, *) }
            .map { [[$0.inhale, $0.innerHold, $0.exhale, $0.outerHold].reduce(0, +), $0.cycles].reduce(1, *) }
            .weakAssign(to: \.totalTime, on: self)
            .store(in: &cancellables)

        $time
            .dateStringFromSeconds()
            .weakAssign(to: \.timeString, on: self)
            .store(in: &cancellables)

        $totalTime
            .dateStringFromSeconds()
            .weakAssign(to: \.totalTimeString, on: self)
            .store(in: &cancellables)
        
        $pranayama
            .map { "\($0.inhale) : \($0.innerHold) : \($0.exhale) : \($0.outerHold)" }
            .weakAssign(to: \.proportionString, on: self)
            .store(in: &cancellables)
        
        $timerState
            .map { self.startPauseTitle(state: $0) }
            .weakAssign(to: \.startPauseTitle, on: self)
            .store(in: &cancellables)
        
        $saveName
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { self.presets.map(\.name).contains($0) }
            .weakAssign(to: \.saveNameNotUnique, on: self)
            .store(in: &cancellables)
        
    }
    
    func speak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = utteranceVoice
        utterance.rate = utteranceRate
//        utterance.volume = 1
        synth.speak(utterance)
    }
    
    func connectTimer() {
        timerPublisher
            .share()
            .sink { _ in self.bang() }
            .store(in: &cancellables)
        
        timerCancellable = timerPublisher.connect()
    }
    
    func resetVars() {
        bangPhaseIndex  = 0
        bangCount = 0
        
        phaseIndex = 4
        count = 0
    }
    
    func startPause() {
        timerCancellable?.cancel()
        
        switch timerState {
            
        case .started:
            resetVars()
            timerState = .paused
            UIApplication.shared.isIdleTimerDisabled = false
            
        case .paused:
            timerState = .started
            resetVars()
            print("resume")
            bang()
            connectTimer()
            UIApplication.shared.isIdleTimerDisabled = true
            
        case .stopped:
            timerState = .started
            resetVars()
            print("start")
            connectTimer()
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func stop() {
        timerCancellable?.cancel()
        
        bangCycle = 0
        cycle = 1
        resetVars()
        
        timerState = .stopped
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func bang() {
        loops: while bangCycle < pranayama.cycles {
            while bangPhaseIndex < 4 {
                while bangCount < phases[bangPhaseIndex] {
                    cycle = bangCycle + 1
                    phaseIndex = bangPhaseIndex
                    count = bangCount
                    
                    audioPlayer.play()
                    
                    print("cycle: \(cycle)/\(pranayama.cycles), phase: \(phaseIndex), count: \(count)/\(phases[phaseIndex])")
                    
                    bangCount += 1
                    break loops
                }
                bangCount = 0
                bangPhaseIndex += 1
            }
            bangPhaseIndex = 0
            bangCycle += 1
            print("---")
        }
        if bangCycle >= pranayama.cycles {
            stop()
            speak(string: Const.end)
        }
    }

    func startPauseTitle(state: TimerState) -> String {
        switch state {
        case .stopped:
            return Const.start
        case .started:
            return Const.pause
        case .paused:
            return Const.resume
        }
    }
    
    var animationDuration: Double {
        Double(timerState == .started ? maxCounts : 0)
    }
    
    func savePreset() {
        if !presets.map(\.name).contains(saveName) { // again, because debouncing
            presets.append(Preset(name: saveName, pranayama: pranayama))
            presets.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
            
            saveJSON()
            clearSaveTextfield()
            
            // TODO: visual feedback
        }
    }
    
    func saveJSON() {
        do {
            guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileURL = documentDirectoryURL.appendingPathComponent(Const.jsonStorageName)
            try JSONEncoder().encode(presets).write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearSaveTextfield() {
        saveName = Const.empty
    }
    
    func deletePreset(at indexes: IndexSet) {
        if let first = indexes.first {
            presets.remove(at: first)
            saveJSON()
        }
    }
    
}
