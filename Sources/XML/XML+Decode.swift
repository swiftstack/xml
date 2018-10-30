import Stream

extension XML.Encoding {
    public init(from string: String) throws {
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

    func readAttributeName() throws -> String? {
        return try read(allowedBytes: .xmlName) { bytes in
            guard bytes.count > 0 else {
                return nil
            }
            return String(decoding: bytes, as: UTF8.self)
        }
    }

    func readAttributeValue() throws -> String {
        guard try consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        let value = try read(allowedBytes: .xmlName) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }
        guard try consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        return value
    }

    func readAttribute() throws -> (String, String)? {
        guard let name = try readAttributeName() else {
            return nil
        }
        guard try consume(.equal) else {
            throw XML.Error.invalidAttribute
        }
        let value = try readAttributeValue()

        return (name, value)
    }

    func readAttributes() throws -> [String : String] {
        var attributes = [String : String]()
        while let (name, value) = try readAttribute() {
            guard attributes[name] == nil else {
                throw XML.Error.duplicateAttribute
            }
            attributes[name] = value
            try consumeWhitespaces(includingNewLine: true)
        }
        return attributes
    }
}

extension XML.Document {
    public init<T: StreamReader>(from stream: T) throws {
        try stream.consumeWhitespaces(includingNewLine: true)

        guard try stream.consume(sequence: Constants.xmlHeaderStart) else {
            throw XML.Error.invalidXmlHeader
        }

        try stream.consumeWhitespaces(includingNewLine: true)

        while let (name, value) = try stream.readAttribute() {
            switch name {
            case "version": self.version = value
            case "encoding": self.encoding = try XML.Encoding(from: value)
            case "standalone": self.standalone = try XML.Standalone(from: value)
            default: break
            }
            try stream.consumeWhitespaces(includingNewLine: true)
        }

        guard try stream.consume(sequence: Constants.xmlHeaderEnd) else {
            throw XML.Error.invalidXmlHeader
        }

        try stream.consumeWhitespaces(includingNewLine: true)

        self.root = try XML.Element(from: stream)
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

extension XML.Element {
    public init<T: StreamReader>(from stream: T) throws {
        guard try stream.consume(.angleBracketOpen) else {
            throw XML.Error.invalidOpeningTag
        }
        guard let name = try stream.readAttributeName() else {
            throw XML.Error.invalidOpeningTagName
        }

        try stream.consumeWhitespaces(includingNewLine: true)

        // read attributes
        let attributes = try stream.readAttributes()

        // check for self closing tag
        if try stream.consume(.slash) {
            guard try stream.consume(.angleBracketClose) else {
                throw XML.Error.invalidClosedTag
            }
            self.name = name
            self.attributes = attributes
            self.children = []
            return
        }

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
        let closingName = try stream.read(until: .angleBracketClose)
        { bytes -> String in
            guard bytes.count > 0 else {
                throw XML.Error.invalidClosingTag
            }
            return String(decoding: bytes, as: UTF8.self)
        }
        guard try stream.consume(.angleBracketClose) else {
            throw XML.Error.invalidClosingTag
        }
        guard closingName == name else {
            throw XML.Error.invalidClosingTagName
        }

        self.name = name
        self.attributes = attributes
        self.children = children
    }
}
