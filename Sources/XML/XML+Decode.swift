import Stream

extension XML.Document {
    public init<T: StreamReader>(from stream: T) throws {
        try stream.consumeWhitespaces(includingNewLine: true)

        guard try stream.consume(sequence: Constants.xmlHeaderStart) else {
            throw XML.Error.invalidXmlHeader
        }

        try stream.consumeWhitespaces(includingNewLine: true)

        while try stream.peek() != .questionMark {
            try consumeAttribute(try Attribute(from: stream))
            try stream.consumeWhitespaces(includingNewLine: true)
        }

        guard try stream.consume(sequence: Constants.xmlHeaderEnd) else {
            throw XML.Error.invalidXmlHeader
        }

        try stream.consumeWhitespaces(includingNewLine: true)

        self.root = try XML.Element(from: stream)
    }

    mutating func consumeAttribute(_ attribute: Attribute) throws {
        switch attribute.name {
        case "version": self.version = attribute.value
        case "encoding": self.encoding = try .init(from: attribute.value)
        case "standalone": self.standalone = try .init(from: attribute.value)
        default: break
        }
    }
}

extension XML.Element {
    struct Name: Equatable {
        let value: String

        init?<T: StreamReader>(from stream: T) throws {
            guard let value = try Name.read(from: stream) else {
                return nil
            }
            self.value = value
        }

        static func read<T: StreamReader>(from stream: T) throws -> String? {
            return try stream.read(allowedBytes: .xmlName) { bytes in
                guard bytes.count > 0 else {
                    return nil
                }
                return String(decoding: bytes, as: UTF8.self)
            }
        }
    }

    public init<T: StreamReader>(from stream: T) throws {
        guard try stream.consume(.angleBracketOpen) else {
            throw XML.Error.invalidOpeningTag
        }
        guard let name = try Name(from: stream) else {
            throw XML.Error.invalidOpeningTagName
        }
        try stream.consumeWhitespaces(includingNewLine: true)

        let attributes = try Attributes(from: stream)

        // check for self-closing tag
        if try stream.consume(.slash) {
            guard try stream.consume(.angleBracketClose) else {
                throw XML.Error.invalidSelfClosingTag
            }
            self.name = name.value
            self.attributes = attributes.values
            self.children = []
            return
        }

        // closing bracket
        guard try stream.consume(.angleBracketClose) else {
            throw XML.Error.invalidOpeningTag
        }

        var children = [XML.Node]()

        // content until child/closing tag
        try stream.read(until: .angleBracketOpen) { bytes in
            if !bytes.isEmptyOrWhitespace {
                let text = String(decoding: bytes, as: UTF8.self)
                children.append(.text(text))
            }
        }

        // read children
        while !(try stream.consume(sequence: [.angleBracketOpen, .slash])) {
            let child = try XML.Element(from: stream)
            children.append(.element(child))
            try stream.consumeWhitespaces(includingNewLine: true)
        }

        // read closing tag
        guard let closingName = try Name(from: stream) else {
            throw XML.Error.invalidClosingTagName
        }
        guard try stream.consume(.angleBracketClose) else {
            throw XML.Error.invalidClosingTag
        }
        guard closingName == name else {
            throw XML.Error.invalidClosingTagNameMismatch
        }
        
        self.name = name.value
        self.attributes = attributes.values
        self.children = children
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

    init<T: StreamReader>(from stream: T) throws {
        func isClosingTag() throws -> Bool {
            switch try stream.peek() {
            case .slash, .angleBracketClose: return true
            default: return false
            }
        }
        var attributes = [String : String]()
        while !(try isClosingTag()) {
            let attribute = try Attribute(from: stream)
            guard attributes[attribute.name] == nil else {
                throw XML.Error.duplicateAttribute
            }
            attributes[attribute.name] = attribute.value
            try stream.consumeWhitespaces(includingNewLine: true)
        }
        self.values = attributes
    }
}

struct Attribute {
    let name: String
    let value: String

    init<T: StreamReader>(from stream: T) throws {
        self.name = try Attribute.readName(from: stream)
        guard try stream.consume(.equal) else {
            throw XML.Error.invalidAttribute
        }
        self.value = try Attribute.readValue(from: stream)
    }

    static func readName<T: StreamReader>(from stream: T) throws -> String {
        return try stream.read(allowedBytes: .xmlName) { bytes in
            guard bytes.count > 0 else {
                throw XML.Error.invalidAttributeName
            }
            return String(decoding: bytes, as: UTF8.self)
        }
    }

    static func readValue<T: StreamReader>(from stream: T) throws -> String {
        guard try stream.consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        let value = try stream.read(allowedBytes: .xmlName) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }
        guard try stream.consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        return value
    }
}

extension StreamReader {
    func consumeWhitespaces(includingNewLine: Bool = false) throws {
        switch includingNewLine {
        case true:
            try consume(while: { byte in
                byte == .whitespace || byte == .cr || byte == .lf
            })
        case false:
            try consume(while: { $0 == .whitespace })
        }
    }
}

extension UnsafeRawBufferPointer {
    var isEmptyOrWhitespace: Bool {
        let index = self.first(where: { byte in
            byte != .whitespace && byte != .cr && byte != .lf
        })
        return index == nil
    }
}
