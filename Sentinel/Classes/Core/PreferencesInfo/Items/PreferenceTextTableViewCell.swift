import UIKit

class PreferenceTextTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inputField: UITextField!
    
    // MARK: - Private properties

    private var inputValidator: ((String) -> Bool)?
    private var inputValueActionHandler: ((String?) -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputField.delegate = self
    }
    
    // MARK: - Internal methods
    
    func configure(with item: PreferenceTextItem) {
        titleLabel.text = item.name
        inputField.text = item.getter()
        inputValidator = { value in
            item.validators.reduce(true) { partialResult, validator in
                partialResult && validator.validate(value: value)
            }
        }
        inputValueActionHandler = { item.change(to: $0 ?? "") }
    }
}

extension PreferenceTextTableViewCell: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let proposedString = (textField.text ?? "") + string
        return inputValidator?(proposedString) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputValueActionHandler?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputValueActionHandler?(textField.text)
        _ = textField.resignFirstResponder()
        return true
    }
}
