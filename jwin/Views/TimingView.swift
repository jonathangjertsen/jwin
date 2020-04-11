import SwiftUI

/// A button for timing
struct TimingView: View {
    @State private var metronomeBpm: Double = 120
    private var lastHoldDurationMs: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Unused for now
                Text("Last hold duration: \(self.lastHoldDurationMs)")
                
                Spacer()
                
                HStack {
                    Text("BPM: ").bold()
                    Text("\(self.metronomeBpm, specifier: "%.1f")")
                }
                Slider(
                    value: $metronomeBpm,
                    in: 30...200,
                    step: 0.1
                )
                    .padding()
                
                Spacer()
                
                // MARK: - Unused for now
                WideButton(text: "Reset", color: .yellow, textColor: .black) {
                    
                }
                WideButton(text: "Tap", color: .green, textColor: .white) {
                    
                }
            }
        }
    }
}

struct TimingView_Previews: PreviewProvider {
    static var previews: some View {
        TimingView()
    }
}
