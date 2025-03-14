//
//  ContentView.swift
//  DTCProject
//
//  Created by Finn McMillan on 2/18/25.
//

import SwiftUI
import AVFoundation
import SwiftData
@Model
class Settings {
     var yesSound: String
     var noSound: String
     var yesIcon: String
     var noIcon: String
    
    init(yesSound: String, noSound: String, yesIcon: String, noIcon: String) {
        self.yesSound = yesSound
        self.noSound = noSound
        self.yesIcon = yesIcon
        self.noIcon = noIcon
    }
}
class AppManager: ObservableObject {
    @Published var yesSound: String
    @Published var noSound: String
    @Published var yesIcon: String
    @Published var noIcon: String
    @Published var player: AVAudioPlayer?
    
    init(yesSound: String, noSound: String, yesIcon: String, noIcon: String, player: AVAudioPlayer? = nil) {
        self.yesSound = yesSound
        self.noSound = noSound
        self.yesIcon = yesIcon
        self.noIcon = noIcon
        self.player = player
    }
    
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                player?.play()
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            } catch {
                print("ERROR")
            }
        }
    }
}
struct ContentView: View {
    @State var soundPlayed = ""
    @State private var isAnimatingGreen: Bool = false
    @State private var isAnimatingRed: Bool = false
    @State private var orientation = UIDevice.current.orientation
    @State private var showSettings = false
    @State var isLoading = true
    
    @Environment(\.modelContext) private var context
    @Query var settings: [Settings]
    @ObservedObject var appManager = AppManager(yesSound: "yes-female", noSound: "no-female", yesIcon: "circle", noIcon: "xmark")
    var body: some View {
        NavigationStack{
            //Landscape view
            ZStack {
                if !isLoading{
                    Rectangle()
                        .frame(maxHeight: 20)
                    VStack {
                        ZStack{
                            Button {
                                soundPlayed = "yes"
                                isAnimatingGreen = true
                                appManager.playSound(sound: appManager.yesSound, type: "mp3")
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    withAnimation(.bouncy) {
                                        isAnimatingRed = false  // Smoothly shrink back
                                        isAnimatingGreen = false
                                    }
                                }
                                
                                // Reset soundPlayed AFTER the shrink animation is done
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    soundPlayed = ""
                                }
                            } label: {
                                
                                ZStack{
                                    Color(.green)
                                        .ignoresSafeArea()
                                        .frame(width: 420, height: 450)
                                        .scaleEffect(x: 1, y: isAnimatingGreen ? 3 : 1)  // Scale changes based on `isAnimating`
                                        .animation(.bouncy, value: isAnimatingGreen)
                                    Image(appManager.yesIcon)
                                        .resizable()
                                        .frame(width: 290, height: 290)
                                        .rotationEffect(Angle(degrees: -90))
                                        .offset(y: isAnimatingGreen ? 230 : 0)
                                    
                                }
                                
                            }
                            .disabled(isAnimatingRed || isAnimatingGreen)
                            VStack {
                                HStack{
                                    Spacer()
                                    HoldDownButton(duration: 1.5, background: isAnimatingGreen ? .green : .black, loadingTint: .white.opacity(0.5), action: {
                                        showSettings = true
                                    })
                                    .padding(.trailing, 35)
                                    .padding(.top, 60)
                                    .font(.title)
                                    .foregroundStyle(.black)
                                    .zIndex(isAnimatingRed || isAnimatingGreen ? -1 : 4)
                                    .navigationDestination(isPresented: $showSettings){
                                        SettingsView(appManager: appManager, settings:  settings[0])
                                            .modelContext(context)
                                        
                                    }
                                    
                                }
                                Spacer()
                            }
                        }
                        .zIndex(isAnimatingGreen ? 1 : 0)
                        Button {
                            soundPlayed = "no"
                            isAnimatingRed = true
                            appManager.playSound(sound: appManager.noSound, type: "mp3")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                withAnimation(.bouncy) {
                                    isAnimatingRed = false  // Smoothly shrink back
                                    isAnimatingGreen = false
                                }
                            }
                            
                            // Reset soundPlayed AFTER the shrink animation is done
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                soundPlayed = ""
                            }
                        } label: {
                            ZStack{
                                Color(.red)
                                    .ignoresSafeArea()
                                    .frame(width: 420, height: 450)
                                    .scaleEffect(x: 1, y: isAnimatingRed ? 3 : 1) // Scale only along the x-axis
                                
                                    .animation(.bouncy, value: isAnimatingRed)
                                Image(appManager.noIcon)
                                    .resizable()
                                    .frame(width: 290, height: 290)
                                    .rotationEffect(Angle(degrees: -90))
                                    .offset(y: isAnimatingRed ? -230 : 0)
                            }
                        }
                        .zIndex(isAnimatingRed ? 1 : 0)
                        .disabled(isAnimatingRed || isAnimatingGreen)
                        
                        
                    }
                    .padding()
                }
                else{
                    ProgressView()
                }
            }
        }
        .onAppear() {
        ensureDefaultSettings()
  }
        
    }
    private func ensureDefaultSettings() {
        isLoading = true
        if settings.isEmpty {
            context.insert(Settings(yesSound: "yes-female", noSound: "no-female", yesIcon: "circle", noIcon: "xmark"))
            try? context.save()
        }
        appManager.yesIcon = settings[0].yesIcon
        appManager.noIcon =  settings[0].noIcon
        appManager.yesSound =  settings[0].yesSound
        appManager.noSound =  settings[0].noSound
        isLoading = false
        }
    }
struct HoldDownButton: View {
    var duration: CGFloat
    var background: Color
    var loadingTint: Color
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    @State private var timerCount: CGFloat = 0
    @State private var progress: CGFloat = 0
    @State private var isHolding = false
    @State private var isCompleted = false
    @State  var action: () -> ()


    var body: some View {
        Image(systemName: "gear")
            .font(.largeTitle)
            .foregroundStyle(background)
            .background {
                GeometryReader {
                    let size = $0.size
                    
                  
                    
                    Rectangle()
                        .fill(loadingTint)
                        .frame(width: size.width * progress)
                }
            }
            .clipShape(Capsule())
            .contentShape(Circle())
            .onLongPressGesture(minimumDuration: duration, perform: {
                isHolding = false
                cancelTimer()
                withAnimation(.easeInOut(duration: 0.2)) {
                    isCompleted = true
                }
                action()
            }, onPressingChanged: { status in
                if status {
                    isCompleted = false
                    reset()
                    isHolding = true
                    addTimer()
                }
            })
            .simultaneousGesture(dragGesture)
            .onReceive(timer) { _ in
                if isHolding && progress != 1{
                    timerCount += 0.01
                    progress = max(min(timerCount / duration, 1), 0)
                }
            }
            .onAppear(perform: cancelTimer)
            .onDisappear(perform: reset)
    }
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onEnded { _ in
                guard !isCompleted else { return }
                withAnimation(.snappy){
                    reset()
                }
            }
    }
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged {
                isHolding = $0
                addTimer()
            }.onEnded { status in
                 
            }
    }
    func addTimer() {
        timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    }
    func cancelTimer(){
        timer.upstream.connect().cancel()
    }
    func reset(){
        isHolding = false
        progress = 0
        timerCount = 0
    }
}
//#Preview {
//    ContentView(appManager: AppManager())
//}
