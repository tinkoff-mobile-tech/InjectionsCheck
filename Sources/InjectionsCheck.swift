//
//  InjectionsCheck.swift
//
import Foundation

/// This protocol wraps possible values, used as selectors
/// By defailt can be used:
/// - String
/// - #selector(getter: ClassName.propertyName) - only for obj-c exposed properties
/// - #keypath(ClassName.propertyName) - only for obj-c exposed properties
///
/// Protocol can be used to create enums with keys.
///
public protocol SelectorName {
    var stringValue: String { get }
}

/// Injection Check errors enum
enum InjectionCheckError: Error {
    
    /// This error throws whe uninjected dependencies foint in object
    case notInjected(properties: [String], in: Any)
}

/// Injection check function.
///
/// Looks through all object properties using Mirror and checks property value.
///
/// Throws error if something is nil.
///
/// Accepts array of properties to ignore.
///
/// - parameter object: object to check no ininjected dependencies
/// - parameter selectorsToIgnore: array of properties selectors to ignore during check.
/// Should conform to IgnorableSelector protocol.
/// String, #Selector(getter:) and #keyPath are accepted out of the box.
///
/// - returns original object
///
/// - throws InjectionsCheckError.uninjectedVars - found uninjected properties.
///
public func checkInjections<ObjectType>(
    _ object: ObjectType,
    ignoring selectorsToIgnore: [SelectorName] = []
    ) throws -> ObjectType {
    
    let selectorsSet = Set<String>(selectorsToIgnore.flatMap { $0.stringValue } )
    let mirror = Mirror(reflecting: object)
    var uninjectedProperties: [String] = []
    for child in mirror.children {
        guard let label = child.label, !selectorsSet.contains(label), unwrap(child.value) == nil else {
            continue
        }
        
        uninjectedProperties.append(label)
    }
    
    guard uninjectedProperties.count == 0 else {
        let error = InjectionCheckError.notInjected(properties: uninjectedProperties, in: object)
        throw error
    }
    
    return object
}

/// Injection check function.
///
/// Looks through all object properties using Mirror and checks property value.
///
/// Throws error if something is nil.
///
/// Accepts array of properties to ignore.
///
/// **This methods only works if there's DEBUG or INJECTION_CHECK_ENABLED is defined in swift.**
/// Use -DDEBUG or -DINJECTION_CHECK_ENABLED in OTHER_SWIFT_FLAGS
///
/// - parameter object: object to check no ininjected dependencies
/// - parameter selectorsToIgnore: array of properties selectors to ignore during check.
/// Should conform to IgnorableSelector protocol.
/// String, #Selector(getter:) and #keyPath are accepted out of the box.
///
/// - returns original object
///
/// - throws InjectionsCheckError.uninjectedVars - found uninjected properties.
///
@discardableResult public func debugCheckInjections<ObjectType>(
    _ object: ObjectType,
    ignoring selectorsToIgnore: [SelectorName] = [],
    errorClosure: (_ error: Error) -> Void = { fatalError("Injection check error: \($0)") }
    ) -> ObjectType? {

    do {
        let object = try checkInjections(object, ignoring: selectorsToIgnore)
        return object
    }
    catch {
        #if DEBUG || INJECTION_CHECK_ENABLED
            errorClosure(error)
        #else
            print("Injection check error: \(error)")
        #endif
        return nil
    }
}


/// Helper function used to unwrap ANY to optional of any depth
///
/// - parameter object: Object to unwrap
///
/// - returns: unwrapped object or nil
///
fileprivate func unwrap<ObjectType: Any>(_ object: ObjectType) -> ObjectType? {
    
    let mirror = Mirror(reflecting: object)
    
    guard mirror.displayStyle == .optional else {
        return object
    }
    
    guard let child = mirror.children.first else {
        return nil
        
    }
    return unwrap(any: child.value) as? ObjectType
}


// This extension is makes String work as Ignorable Selector
extension String: SelectorName {
    public var stringValue: String {
        return self
    }
}
// This extension is makes selector work as ignorable selector
extension Selector: SelectorName {
    public var stringValue: String {
        return String(describing: self)
    }
}

// This extension makes String Raw enum work as ignorable selector
extension SelectorName where Self: RawRepresentable, Self.RawValue == String {
    public var stringValue: String {
        return self.rawValue
    }
}
