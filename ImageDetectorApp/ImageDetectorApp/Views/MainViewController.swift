import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    private let imageDetectorService = ImageDetectorService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        subsribeDetectorUpdates()
    }

    // MARK: - Actions
    
    @IBAction func loadBtnPressed(_ sender: Any) {
        showCameraAlert()
    }
    
    @IBAction func checkBtnPressed(_ sender: Any) {
        checkImage()
    }
    
    // MARK: - Internal methods
    
    private func configView() {
        self.imageView.image = nil
        self.resultLabel.text = ""
    }

    private func checkImage() {
        guard let image = imageView.image else {
            print("Image not loaded")
            return
        }
        
        self.imageDetectorService.detectImageType(image)
    }
    
    private func subsribeDetectorUpdates() {
        self.imageDetectorService.detectionCallback = { [weak self] state in
            self?.updateViewForDetectorState(state)
        }
    }
    
    private func updateViewForDetectorState(_ state: ImageDetectorState) {
        switch state {
        case .detectionFailed:
            resultLabel.text = "Detection failed, please try again"
        case .detectionStarted:
            resultLabel.text = "Detection started, please wait a bit"
        case .detectionResultReceived(let detectionResult):
            if detectionResult.isCactus() {
                resultLabel.text = "It's a cactus! 🌵 We are \(detectionResult.getPercentConfidence())% sure!"
            } else {
                resultLabel.text = "Sorry, not a cactus this time 🌼 (\(detectionResult.getPercentConfidence())% for it)"
            }
        }
    }
    
    // MARK: - Camera methods
    
    private func showCameraAlert() {
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = sourceType
        present(imagePickerViewController, animated: true)
    }
    
    private func imageLoaded(_ image: UIImage) {
        self.imageView.image = image
        self.resultLabel.text = ""
    }

}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        let imageKey = UIImagePickerController.InfoKey.originalImage
        guard let image = info[imageKey] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        dismiss(animated: true, completion: nil)
        self.imageLoaded(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

