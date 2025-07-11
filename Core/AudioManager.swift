import AVFoundation

class AudioManager {
    private let engine = AVAudioEngine()
    var onLoudSound: ((Float) -> Void)?

    func startMonitoring() {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let pointer = buffer.floatChannelData?[0] else { return }

            let frameLength = Int(buffer.frameLength)
            let bufferPointer = UnsafeBufferPointer(start: pointer, count: frameLength)
            let data = Array(bufferPointer)

            let squares = data.map { $0 * $0 }
            let sum = squares.reduce(0, +)
            let avg = sqrt(sum / Float(buffer.frameLength))
            let db = 20 * log10(avg)

            if db > -50 {
                DispatchQueue.main.async {
                    self?.onLoudSound?(db)
                }
            }
        }

        try? engine.start()
    }

    func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
    }
}
