import UIKit
import Vision

enum ImageDetectorState {
    case detectionStarted, detectionFailed, detectionResultReceived(result: CactusDetectionModel)
}

final class ImageDetectorService {
    
    var detectionCallback: ((ImageDetectorState) -> Void)?
    
    func detectImageType(_ image: UIImage) {
        
        detectionCallback?(.detectionFailed)

        guard let coreModel = configCoreMLModel(), let image = CIImage(image: image) else {
            detectionCallback?(.detectionFailed)
            print("Cannot init core ML model or image is empty")
            return
        }
        
        makeImageDetectorRequest(model: coreModel, image: image)
    }
    
    private func configCoreMLModel() -> VNCoreMLModel? {
        return try? VNCoreMLModel(for: CactusClassifier(configuration: MLModelConfiguration()).model)
    }
    
    private func makeImageDetectorRequest(model: VNCoreMLModel, image: CIImage) {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.handleRequestResults(request.results)
        }
        makeImageRequestHandler(image: image, request: request)
    }
    
    private func makeImageRequestHandler(image: CIImage, request: VNCoreMLRequest) {
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print("Image request handler error: \(error.localizedDescription)")
                self.detectionCallback?(.detectionFailed)
            }
        }
    }
    
    private func handleRequestResults(_ results: [Any]?) {
        guard let results = results as? [VNClassificationObservation],
              let firstResult = results.first else {
            print("Cannot observe detetion result")
            self.detectionCallback?(.detectionFailed)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            let cactusResultModel =  CactusDetectionModel(identifier: firstResult.identifier,
                                                          confidence: firstResult.confidence)
            self?.detectionCallback?(.detectionResultReceived(result: cactusResultModel))
        }
    }
}
