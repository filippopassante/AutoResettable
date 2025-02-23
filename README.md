# AutoResettable
Declares an `autoReset()` method in the class to which it is attached, which
resets all its variables to their declaration-level default value if any,
otherwise to `nil` provided they’re optionals.

Macros can't see each other's expansions, so, if a different macro declares
a variable, `@AutoResettable` will ignore it.

`autoReset()` may space closures, IIFEs and shorthand array initializations
weird, but still correctly resets them.

Example usage:
```
@AutoResettable
class MyClass {
    var a = ""
    var b: Int
    var c: Bool

    init(a: String, b: Int, c: Bool = false) {
        self.a = a
        self.b = b
        self.c = c
    }

    func reset() {
        autoReset()
        b = .init()
        c = .init()
    }
}
```
You still have to reset `b` and `c` because they don't have default values
at declaration and they're not optionals.

This allows you to assign, from inside initializers, expressions to your
variables to which `autoReset()` might not have access.

One use case is to call `autoReset()` in the `tearDown()` of `XCTestCase`
subclasses:
```
import XCTest

@AutoResettable
final class Tests: XCTestCase {
    let a = A()
    var id: String!

    override func setUp() {
        super.setUp()
        id = "id"
    }

    override func tearDown() {
        autoReset()
        super.tearDown()
    }
}
```
