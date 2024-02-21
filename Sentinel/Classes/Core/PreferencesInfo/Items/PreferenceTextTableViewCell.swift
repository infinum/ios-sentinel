import UIKit

class PreferenceTextTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inputField: UITextField!
    
    // MARK: - Private properties

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
        inputValueActionHandler = { item.change(to: $0 ?? "") }
    }
}

extension PreferenceTextTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputValueActionHandler?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputValueActionHandler?(textField.text)
        _ = textField.resignFirstResponder()
        return true
    }
}
