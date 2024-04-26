import UIKit

@objcMembers
public class PreferenceTextItem: NSObject {
    
    // MARK: - Public properties
    
    public let name: String
    public let setter: (String) -> ()
    public let getter: () -> String
    public let validators: [AnyPreferenceValidator<String>]
    public let userDefaults: UserDefaults
    public let userDefaultsKey: String?
    
    // MARK: - Lifecycle
    
    public init(
        name: String,
        setter: @escaping (String) -> Void,
        getter: @escaping () -> String,
        validators: [AnyPreferenceValidator<String>] = [],
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String?
    ) {
        self.name = name
        self.setter = setter
        self.getter = getter
        self.validators = validators
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        super.init()
        loadStoredValue()
    }
    
    // MARK: - Internal methods
    
    /// Changes current enabled state of the feature.
    ///
    /// This is mostly used inside option switch module
    /// but it is also exposed for external change.
    @objc(changeToValue:)
    func change(to value: String) {
        store(newValue: value)
    }
}

// MARK: - PreferenceItem

extension PreferenceTextItem: PreferenceItem {
    
    public func cell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PreferenceTextTableViewCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
    
    public func register(at tableView: UITableView) {
        tableView.registerNib(cellOfType: PreferenceTextTableViewCell.self)
    }
}
