import UIKit
import PhotosUI

class ViewController: UIViewController {

  @IBOutlet weak var nounTextField: UITextField!
  @IBOutlet weak var adjectiveTextField: UITextField!
  @IBOutlet weak var verbTextField: UITextField!
  @IBOutlet weak var numberSlider: UISlider!
  @IBOutlet weak var numberLabel: UILabel!
  @IBOutlet weak var storyPromptImageView: UIImageView!

  let storyPrompt = StoryPromptEntry()

  @IBAction func changeNumber(_ sender: UISlider) {
    numberLabel.text = "Number: \(Int(sender.value))"
    storyPrompt.number = Int(sender.value)
  }

  @IBAction func changeStoryType(_ sender: UISegmentedControl) {
    if let genre = StoryPrompts.Genre(rawValue: sender.selectedSegmentIndex) {
      storyPrompt.genre = genre
    } else {
      storyPrompt.genre = .scifi
    }
  }
  @IBAction func generateStoryPrompt(_ sender: Any) {
    updateStoryPrompt()
    if storyPrompt.isValid() {
        print(storyPrompt)
    } else {
        let alert = UIAlertController(title: "Invalid Story Prompt", message: "Please fill out all of the field", preferredStyle: .alert)
        
        let action  = UIAlertAction(title: "OK", style: .default, handler: {
            action in
        })
        alert.addAction(action)
        present(alert, animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    numberSlider.value = 7.5
    storyPrompt.noun = "toaster"
    storyPrompt.adjective = "smelly"
    storyPrompt.verb = "burps"
    storyPrompt.number = Int(numberSlider.value)
    storyPromptImageView.isUserInteractionEnabled = true
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage))
    storyPromptImageView.addGestureRecognizer(gestureRecognizer)
  }

  func updateStoryPrompt() {
    storyPrompt.noun = nounTextField.text ?? ""
    storyPrompt.adjective = adjectiveTextField.text ?? ""
    storyPrompt.verb = verbTextField.text ?? ""
  }

  @objc func changeImage() {
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.selectionLimit = 1
    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = self
    present(controller, animated: true)
  }

}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    updateStoryPrompt()
    return true
  }
}

extension ViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    if !results.isEmpty {
      let result = results.first!
      let itemProvider = result.itemProvider
      if itemProvider.canLoadObject(ofClass: UIImage.self) {
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
          guard let image = image as? UIImage else {
            return
          }
          DispatchQueue.main.async {
            self?.storyPromptImageView.image = image
          }
        }
      }
    }
  }
}
