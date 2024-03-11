import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct AutoResettableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self) else {
            let diagnostic = Diagnostic(
                node: node,
                message: AutoResettableDiagnostic.notAClassNorAStruct,
                fixIt: .replace(
                    message: AutoResettableFixItMessage.notAClassNorAStruct,
                    oldNode: node,
                    newNode: AttributeSyntax(stringLiteral: "")
                )
            )
            context.diagnose(diagnostic)
            return []
        }
        
        let properties = declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variables = properties.filter { $0.bindingSpecifier.text == "var" }
        let separatedBindings = variables.flatMap { $0.bindings }
        
        let autoResetBodyLines: [String] = separatedBindings.map {
            if let identifier = $0.pattern.as(IdentifierPatternSyntax.self)?.identifier {
                if let value = $0.initializer?.as(InitializerClauseSyntax.self)?.value {
                    let id = "\(identifier)".last == " " ? "\(identifier)".dropLast() : "\(identifier)" // for some reason a white space is added to the identifier of properties with omitted types
                    return "\(id) = \(value)"
                } else if let _ = $0.typeAnnotation?.type.as(OptionalTypeSyntax.self) {
                    return "\(identifier) = nil"
                } else if let _ = $0.typeAnnotation?.type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                    return "\(identifier) = nil"
                }
            }
            return nil
        }.compactMap { $0 }
                
        let autoReset = try FunctionDeclSyntax("func autoReset()") {
            for line in autoResetBodyLines {
                "\(raw: line)"
            }
        }
        
        return [DeclSyntax(autoReset)]
    }
}

@main
struct AutoResettablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutoResettableMacro.self
    ]
}

enum AutoResettableDiagnostic: String, DiagnosticMessage {
    case notAClassNorAStruct

    var message: String {
        switch self {
        case .notAClassNorAStruct:
            "@AutoResettable can only be attached to classes and structures"
        }
    }
    
    var diagnosticID: MessageID {
        .init(domain: "AutoResettableMacros", id: rawValue)
    }
    
    var severity: DiagnosticSeverity {
        .error
    }
}

enum AutoResettableFixItMessage: String, FixItMessage {
    case notAClassNorAStruct

    var message: String {
        switch self {
        case .notAClassNorAStruct:
            "Remove '@AutoResettable '"
        }
    }
    
    var fixItID: MessageID {
        .init(domain: "AutoResettableMacros", id: rawValue)
    }
}
