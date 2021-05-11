import Stream

extension XML.Document {
    public static func decode(from stream: StreamReader) async throws -> XML.Document {
        var document = XML.Document()
        try await stream.consumeWhitespaces(includingNewLine: true)

        guard try await stream.consume(sequence: Constants.xmlHeaderStart) else {
            throw XML.Error.invalidXmlHeader
        }

        try await stream.consumeWhitespaces(includingNewLine: true)

        while try await stream.peek() != .questionMark {
            try await consumeAttribute(try await Attribute.decode(from: stream), document: &document)
            try await stream.consumeWhitespaces(includingNewLine: true)
        }

        guard try await stream.consume(sequence: Constants.xmlHeaderEnd) else {
            throw XML.Error.invalidXmlHeader
        }

        try await stream.consumeWhitespaces(includingNewLine: true)

        document.root = try await .decode(from: stream)
        return document
    }

    static func consumeAttribute(_ attribute: Attribute, document: inout XML.Document) async throws {
        switch attribute.name {
        case "version": document.version = attribute.value
        case "encoding": document.encoding = try .init(from: attribute.value)
        case "standalone": document.standalone = try .init(from: attribute.value)
        default: break
        }
    }
}

extension XML.Node {
    public static func decode(from stream: StreamReader) async throws -> XML.Node {
        switch try await stream.peek() {
        case .angleBracketOpen: return .element(try await .decode(from: stream))
        default: return .text(try await XML.Node.readText(from: stream))
        }
    }

    static func readText(from stream: StreamReader) async throws -> String {
        return try await stream.read(until: .angleBracketOpen) { bytes in
            return String(decoding: bytes.trimEnd(), as: UTF8.self)
        }
    }
}

extension XML.Element {
    struct Name: Equatable {
        let value: String

        static func decode(from stream: StreamReader) async throws -> XML.Element.Name? {
            guard let value = try await Name.read(from: stream) else {
                return nil
            }
            return .init(value: value)
        }

        static func read(from stream: StreamReader) async throws -> String? {
            return try await stream.read(allowedBytes: .xmlName) { bytes in
                guard bytes.count > 0 else {
                    return nil
                }
                return String(decoding: bytes, as: UTF8.self)
            }
        }
    }

    public static func decode(from stream: StreamReader) async throws -> XML.Element {
        guard try await stream.consume(.angleBracketOpen) else {
            throw XML.Error.invalidOpeningTag
        }
        guard let name = try await Name.decode(from: stream) else {
            throw XML.Error.invalidOpeningTagName
        }
        try await stream.consumeWhitespaces(includingNewLine: true)

        let attributes = try await Attributes.decode(from: stream)

        // check for self-closing tag
        if try await stream.consume(.slash) {
            guard try await stream.consume(.angleBracketClose) else {
                throw XML.Error.invalidSelfClosingTag
            }
            return .init(name: name.value, attributes: attributes.values, children: [])
        }

        // closing bracket
        guard try await stream.consume(.angleBracketClose) else {
            throw XML.Error.invalidOpeningTag
        }

        // read children
        var children = [XML.Node]()
        try await stream.consumeWhitespaces(includingNewLine: true)
        while !(try await stream.consume(sequence: [.angleBracketOpen, .slash])) {
            children.append(try await XML.Node.decode(from: stream))
            try await stream.consumeWhitespaces(includingNewLine: true)
        }

        // read closing tag
        guard let closingName = try await Name.decode(from: stream) else {
            throw XML.Error.invalidClosingTagName
        }
        guard try await stream.consume(.angleBracketClose) else {
            throw XML.Error.invalidClosingTag
        }
        guard closingName == name else {
            throw XML.Error.invalidClosingTagNameMismatch
        }

        return .init(name: name.value, attributes: attributes.values, children: children)
    }
}

extension XML.Encoding {
    init(from string: String) throws {
        let lowercased = string.lowercased()
        guard let encoding = XML.Encoding(rawValue: lowercased) else {
            throw XML.Error.invalidXmlEncoding
        }
        self = encoding
    }
}

extension XML.Standalone {
    init(from string: String) throws {
        let lowercased = string.lowercased()
        guard let standalone = XML.Standalone(rawValue: lowercased) else {
            throw XML.Error.invalidXmlHeader
        }
        self = standalone
    }
}

struct Attributes {
    var values: [String : String]

    subscript(_ name: String) -> String? {
        get { return values[name] }
        set { values[name] = newValue }
    }

    static func decode(from stream: StreamReader) async throws -> Attributes {
        func isClosingTag() async throws -> Bool {
            switch try await stream.peek() {
            case .slash, .angleBracketClose: return true
            default: return false
            }
        }
        var attributes = [String : String]()
        while !(try await isClosingTag()) {
            let attribute = try await Attribute.decode(from: stream)
            guard attributes[attribute.name] == nil else {
                throw XML.Error.duplicateAttribute
            }
            attributes[attribute.name] = attribute.value
            try await stream.consumeWhitespaces(includingNewLine: true)
        }
        return .init(values: attributes)
    }
}

struct Attribute {
    let name: String
    let value: String

    static func decode(from stream: StreamReader) async throws -> Attribute {
        let name = try await Attribute.readName(from: stream)
        guard try await stream.consume(.equal) else {
            throw XML.Error.invalidAttribute
        }
        let value = try await Attribute.readValue(from: stream)
        return .init(name: name, value: value)
    }

    static func readName(from stream: StreamReader) async throws -> String {
        return try await stream.read(allowedBytes: .xmlName) { bytes in
            guard bytes.count > 0 else {
                throw XML.Error.invalidAttributeName
            }
            return String(decoding: bytes, as: UTF8.self)
        }
    }

    static func readValue(from stream: StreamReader) async throws -> String {
        guard try await stream.consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        let value = try await stream.read(allowedBytes: .xmlName) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }
        guard try await stream.consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        return value
    }
}

extension StreamReader {
    func consumeWhitespaces(includingNewLine: Bool = false) async throws {
        switch includingNewLine {
        case true: try await consume(while: { $0.isNewLineOrWhitespace })
        case false: try await consume(while: { $0 == .whitespace })
        }
    }
}

extension UnsafeRawBufferPointer {
    func trimEnd() -> UnsafeRawBufferPointer.SubSequence {
        guard let end = lastIndex(where: { !$0.isNewLineOrWhitespace }) else {
            return self[...]
        }
        return self[...end]
    }
}

extension UInt8 {
    var isNewLineOrWhitespace: Bool {
        switch self {
        case .whitespace, .cr, .lf: return true
        default: return false
        }
    }
}
