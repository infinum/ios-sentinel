import Foundation

///
/// A validator for numeric values.
///
/// Validates if the value is within the provided range.
///
@objcMembers
public final class PreferenceValueValidator<T> where T: Numeric, T: Comparable {
    
    // MARK: - Public properties
    
    public let validationMessage: String?
    
    // MARK: - Private properties
    
    private let min: T?
    private let max: T?
    
    // MARK: - Lifecycle
    
    ///
    /// Initializes a new `PreferenceValueValidator` instance.
    ///
    /// - Parameters:
    ///   - min: The minimum value for the validator.
    ///   - max: The maximum value for the validator.
    ///   - errorMessage: The error message to be used when the value is invalid.
    ///
    /// - Returns: Instance of `PreferenceValueValidator
    /// `.
    public init(min: T?, max: T?, validationMessage: String? = nil) {
        self.min = min
        self.max = max
        self.validationMessage = validationMessage
    }
}

// MARK: - PreferenceValidator

extension PreferenceValueValidator: PreferenceValidator {

    ///
    /// Validates the provided value and returns `true`
    /// if the value is in minimum and maximum range.
    ///
    /// - Parameter value: Value to be validated.
    /// - Returns: `true` if value is valid, `false` otherwise.
    ///
    public func validate(value: T) -> Bool {
        guard
            let min = min ?? T.self.init(exactly: Int.zero),
            let max = max ?? T.self.init(exactly: Int.max)
        else { return false }
        
        return min <= value && value <= max
    }
}
