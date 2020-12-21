import Foundation

class CactusDetectionModel {
    private let identifier: String
    private let confidence: Float
    
    required init(identifier: String, confidence: Float) {
        self.identifier = identifier
        self.confidence = confidence
    }
    
    func getPercentConfidence() -> Int {
        return Int((confidence * 100).rounded())
    }
    
    func isCactus() -> Bool {
        return self.identifier == "cactus"
    }
}
