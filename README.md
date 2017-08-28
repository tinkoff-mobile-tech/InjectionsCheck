# Swift Injections check

[![CI Status](https://travis-ci.org/TinkoffCreditSystems/InjectionsCheck.svg?branch=master)](https://travis-ci.org/TinkoffCreditSystems/InjectionsCheck)
[![Version](https://img.shields.io/cocoapods/v/InjectionsCheck.svg?style=flat)](http://cocoapods.org/pods/InjectionsCheck)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/InjectionsCheck.svg?style=flat)](http://cocoapods.org/pods/InjectionsCheck)
[![Platform](https://img.shields.io/cocoapods/p/InjectionsCheck.svg?style=flat)](http://cocoapods.org/pods/InjectionsCheck)
[![Swift Version](https://img.shields.io/badge/Swift-3.0--4.0-F16D39.svg?style=flat)](https://developer.apple.com/swift)

Small library to check injections into Swift objects.

```
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
func checkInjections<ObjectType>(_ object: ObjectType, ignoring selectorsToIgnore: [SelectorName] = []) throws -> ObjectType

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
@discardableResult public func debugCheckInjections<ObjectType>(_ object: ObjectType, ignoring selectorsToIgnore: [SelectorName] = [], errorClosure: (_ error: Error) -> Void = { fatalError("Injection check error: \($0)") }) -> ObjectType? 
```
