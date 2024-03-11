/// Declares an autoReset() method in the class to which you attach it, which
/// resets all its variables to their declaration-level default value, if any, or
/// to nil if they’re optionals.
///
/// Keep in mind that macros can't see each other's expansions, so, if you
/// use another macro to declare a variable, @AutoResettable will ignore it.
///
/// autoReset() may space closures, IIFEs and shorthand array initializations
/// weird, but still correctly resets them.
///
/// Example usage:
/// ```
///@AutoResettable
///class MyClass {
///    var a = ""
///    var b: Int
///    var c: Bool
///
///    init(a: String, b: Int, c: Bool = false) {
///        self.a = a
///        self.b = b
///        self.c = c
///    }
///
///    func reset() {
///        autoReset()
///        b = .init()
///        c = .init()
///    }
///}
/// ```
/// You still have to reset b and c because they don't have default values
/// at declaration and they are not optionals.
///
/// This allows you to assign expressions to your variables in
/// initializers to which autoReset() might not have access.
///
/// A great use case is to call autoReset() in the tearDown() method of
/// XCTestCase subclasses, since these classes usually don't have
/// initializers:
/// ```
///import XCTest
///
///@AutoResettable
///final class Tests: XCTestCase {
///    let a = A()
///    var id: String!
///
///    override func setUp() {
///        super.setUp()
///        id = "id"
///    }
///
///    override func tearDown() {
///        autoReset()
///        super.tearDown()
///    }
///}
/// ```
@attached(member, names: named(autoReset()))
public macro AutoResettable() = #externalMacro(module: "AutoResettableMacros", type: "AutoResettableMacro")
