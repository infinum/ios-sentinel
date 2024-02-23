import Foundation

///
/// A validator for collection values.
///
/// It is commonly used to check the size of 
/// any collection like `Array` or a `String`.
///
@objcMembers
public final class PreferenceCountValidator<T>: NSObject where T: Collection {
    
    // MARK: - Public properties
    
    public let validationMessage: String?

    // MARK: - Private properties
    
    private let min: Int?
    private let max: Int?
    
    // MARK: - Lifecycle
    
    ///
    /// Initializes a new `PreferenceCountValidator` instance.
    ///
    /// - Parameters:
    ///   - min: The minimum value for the validator.
    ///   - max: The maximum value for the validator.
    ///   - errorMessage: The error message to be used when the value is invalid.
    ///
    /// - Returns: Instance of `PreferenceCountValidator`.
    ///
    public init(min: Int?, max: Int?, validationMessage: String? = nil) {
        self.min = min
        self.max = max
        self.validationMessage = validationMessage
    }
}

// MARK: - PreferenceValidator

extension PreferenceCountValidator: PreferenceValidator {
    
    ///
    /// Validates the provided value and returns `true`
    /// if the size of the provided value is in minimum
    /// and maximum range.
    ///
    /// - Parameter value: Value to be validated.
    /// - Returns: `true` if value is valid, `false` otherwise.
    ///
    public func validate(value: T) -> Bool {
        return (min ?? Int.zero) <= value.count && value.count <= (max ?? Int.max)
    }
}
