import Foundation

public protocol PreferenceItem: ToolTableItem {
    associatedtype T
    
    /// Name of the item
    var name: String { get }

    /// This function is called when value is changed.
    ///
    /// It should be used to change the current variable value.
    var setter: (T) -> () { get }
    
    /// This function is called when value needs to be read.
    ///
    /// It should be used to provide the current variable value.
    var getter: () -> T { get }

    /// Default storage used for storing information if the key is provided.
    var userDefaults: UserDefaults { get }
    
    /// Defines key for storing information.
    ///
    /// If the value is not provided, the information won't be stored.
    var userDefaultsKey: String? { get }
}

// MARK: - Private methods

extension PreferenceItem {
    
    func store(newValue: T) {
        if let key = userDefaultsKey {
            userDefaults.set(newValue, forKey: key)
        }
        setter(newValue)
    }
    
    func loadStoredValue() {
        guard let key = userDefaultsKey,
              let value = userDefaults.object(forKey: key) as? T
        else { return }
        setter(value)
    }
}
