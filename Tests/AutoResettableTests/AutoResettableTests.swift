import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(AutoResettableMacros)
import AutoResettableMacros

let testMacros: [String: Macro.Type] = [
    "AutoResettable": AutoResettableMacro.self
]
#endif

final class AutoResettableTests: XCTestCase {    
    func test_autoReset_withEmptyClass_shouldDeclareEmptyAutoResetInTheClass() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion(
            """
@AutoResettable class MyClass {

}
""",
            expandedSource: """
class MyClass {

    func autoReset() {
    }

}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }


//MARK: --
    func test_autoReset_withEmptySingleLineClass_shouldDeclareEmptyAutoResetInTheClass() throws { // this test exists because I couldn't verify this from the macro's expansion in production
#if canImport(AutoResettableMacros)
        assertMacroExpansion(
            """
@AutoResettable class MyClass {}
""",
            expandedSource: """
class MyClass {

    func autoReset() {
    }}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
//MARK: --
    func test_autoReset_withoutTypeAnnotations_shouldResetTheVariablesToTheirDefaultValue() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion("""
@AutoResettable class MyClass {
    final var a = "Hello"
    let b = 6
    var c = Int()
}
""",
            expandedSource: """
class MyClass {
    final var a = "Hello"
    let b = 6
    var c = Int()

    func autoReset() {
        a = "Hello"
        c = Int()
    }
}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
//MARK: --
    func test_autoReset_withoutTypeAnnotations_withSameLineVariables_shouldResetTheVariablesToTheirDefaultValue() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion("""
@AutoResettable class MyClass {
    var a = "Hello", c = Int(); let b = 6;
}
""",
            expandedSource: """
class MyClass {
    var a = "Hello", c = Int(); let b = 6;

    func autoReset() {
        a = "Hello"
        c = Int()
    }
}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
//MARK: --
    func test_autoReset_withVariablesAfterInit_shouldResetTheVariablesToTheirDefaultValue() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion("""
@AutoResettable class MyClass {
    var a = "Hello"
    let b = 6

    init() {

    }

    var c = Int()
}
""",
            expandedSource: """
class MyClass {
    var a = "Hello"
    let b = 6

    init() {

    }

    var c = Int()

    func autoReset() {
        a = "Hello"
        c = Int()
    }
}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
//MARK: --
    func test_autoReset_withTypeAnnotations_shouldResetTheVariablesToTheirDefaultValueOrToNil() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion("""
@AutoResettable final class SomeClass: MyParentClass, Identifiable {
    @Binding var id: String = .init()
    var nonNilOptional: String? = "o"
    var optionalClosure: (() -> ())?
    var closureWithDefaultValue: () -> () = { }
    var implicitlyUnwrappedBool: Bool! = nil
    private var injectedInt: Int
    var optionalIntWithDefaultValue: Int? = 5
    let o: Int? = 3
    
    var computed: Bool { !self.implicitlyUnwrappedBool }
    /// "Yes" if injectedInt == 0, "No" otherwise
    lazy var injectedIntIsZeroYesOrNo: String = injectedInt == 0 ? "Yes" : "No"
    var iice: UIButton = {
        let b = UIButton()
        return b
    }()
    
    init(injectedInt: Int) {
        self.injectedInt = injectedInt
    }

    var weirdlyPositionedBool: Bool = false
    
    func reset() {
        autoReset()
        // reset the injected properties appropriately
    }
}
""",
            expandedSource: """
final class SomeClass: MyParentClass, Identifiable {
    @Binding var id: String = .init()
    var nonNilOptional: String? = "o"
    var optionalClosure: (() -> ())?
    var closureWithDefaultValue: () -> () = { }
    var implicitlyUnwrappedBool: Bool! = nil
    private var injectedInt: Int
    var optionalIntWithDefaultValue: Int? = 5
    let o: Int? = 3
    
    var computed: Bool { !self.implicitlyUnwrappedBool }
    /// "Yes" if injectedInt == 0, "No" otherwise
    lazy var injectedIntIsZeroYesOrNo: String = injectedInt == 0 ? "Yes" : "No"
    var iice: UIButton = {
        let b = UIButton()
        return b
    }()
    
    init(injectedInt: Int) {
        self.injectedInt = injectedInt
    }

    var weirdlyPositionedBool: Bool = false
    
    func reset() {
        autoReset()
        // reset the injected properties appropriately
    }

    func autoReset() {
        id = .init()
        nonNilOptional = "o"
        optionalClosure = nil
        closureWithDefaultValue = {
        }
        implicitlyUnwrappedBool = nil
        optionalIntWithDefaultValue = 5
        injectedIntIsZeroYesOrNo = injectedInt == 0 ? "Yes" : "No"
        iice = {
                let b = UIButton()
                return b
            }()
        weirdlyPositionedBool = false
    }
}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
// MARK: --
    func test_autoReset_onNestedClass_shouldResetTheVariablesToTheirDefaultValue() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion("""
@AutoResettable class MyClass {
    var a = "Hello"
    let b = 6

    init() {

    }

    var c = Int()

    @AutoResettable class NestedClass {
        var i = true
    }
}
""",
            expandedSource: """
class MyClass {
    var a = "Hello"
    let b = 6

    init() {

    }

    var c = Int()

    class NestedClass {
        var i = true

        func autoReset() {
            i = true
        }
    }

    func autoReset() {
        a = "Hello"
        c = Int()
    }
}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
// MARK: --
    func test_autoReset_inStruct_withTypeAnnotations_shouldResetTheVariablesToTheirDefaultValueOrToNil() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion("""
@AutoResettable struct SomeClass: MyParentClass, Identifiable {
    @Binding var id: String = .init()
    var nonNilOptional: String? = "o"
    var optionalClosure: (() -> ())?
    var closureWithDefaultValue: () -> () = { }
    var implicitlyUnwrappedBool: Bool! = nil
    private var injectedInt: Int
    var optionalIntWithDefaultValue: Int? = 5
    let o: Int? = 3
    
    var computed: Bool { !self.implicitlyUnwrappedBool }
    /// "Yes" if injectedInt == 0, "No" otherwise
    lazy var injectedIntIsZeroYesOrNo: String = injectedInt == 0 ? "Yes" : "No"
    var iice: UIButton = {
        let b = UIButton()
        return b
    }()
    
    init(injectedInt: Int) {
        self.injectedInt = injectedInt
    }

    var weirdlyPositionedBool: Bool = false
    
    func reset() {
        autoReset()
        // reset the injected properties appropriately
    }
}
""",
            expandedSource: """
struct SomeClass: MyParentClass, Identifiable {
    @Binding var id: String = .init()
    var nonNilOptional: String? = "o"
    var optionalClosure: (() -> ())?
    var closureWithDefaultValue: () -> () = { }
    var implicitlyUnwrappedBool: Bool! = nil
    private var injectedInt: Int
    var optionalIntWithDefaultValue: Int? = 5
    let o: Int? = 3
    
    var computed: Bool { !self.implicitlyUnwrappedBool }
    /// "Yes" if injectedInt == 0, "No" otherwise
    lazy var injectedIntIsZeroYesOrNo: String = injectedInt == 0 ? "Yes" : "No"
    var iice: UIButton = {
        let b = UIButton()
        return b
    }()
    
    init(injectedInt: Int) {
        self.injectedInt = injectedInt
    }

    var weirdlyPositionedBool: Bool = false
    
    func reset() {
        autoReset()
        // reset the injected properties appropriately
    }

    func autoReset() {
        id = .init()
        nonNilOptional = "o"
        optionalClosure = nil
        closureWithDefaultValue = {
        }
        implicitlyUnwrappedBool = nil
        optionalIntWithDefaultValue = 5
        injectedIntIsZeroYesOrNo = injectedInt == 0 ? "Yes" : "No"
        iice = {
                let b = UIButton()
                return b
            }()
        weirdlyPositionedBool = false
    }
}
""",
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
// MARK: --
    func test_autoReset_onEnum_shouldProduceTheExpectedDiagnostics() throws {
#if canImport(AutoResettableMacros)
        assertMacroExpansion(
            "@AutoResettable enum A { }",
            expandedSource: "enum A { }",
            diagnostics: [.init(
                id: .init(domain: "AutoResettableMacros", id: "notAClassNorAStruct"),
                message: "@AutoResettable can only be attached to classes and structures",
                line: 1,
                column: 1,
                severity: .error,
                fixIts: [.init(message: "Remove '@AutoResettable '")]
            )],
            macros: testMacros
        )
#else
throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
