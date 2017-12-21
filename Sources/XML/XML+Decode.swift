import Stream

extension XML.Encoding {
    init(_ string: String) throws {
        guard string == "utf-8" else {
            throw XML.Error.invalidXmlEncoding
        }
        self = .utf8
    }
}

extension XML.Standalone {
    init(_ string: String) throws {
        switch string {
        case "yes": self = .yes
        case "no": self = .no
        default: throw XML.Error.invalidXmlHeader
        }
    }
}

extension UnsafeStreamReader {
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
        let buffer = try read(allowedBytes: .xmlName)
        guard buffer.count > 0 else {
            return nil
        }
        return String(decoding: buffer, as: UTF8.self)
    }

    func readAttributeValue() throws -> String {
        guard try consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        let buffer = try read(allowedBytes: .xmlName)
        guard try consume(.doubleQuote) else {
            throw XML.Error.invalidAttributeValue
        }
        return String(decoding: buffer, as: UTF8.self)
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
    public init<T: UnsafeStreamReader>(from stream: T) throws {
        try stream.consumeWhitespaces(includingNewLine: true)

        guard try stream.consume(sequence: Constants.xmlHeaderStart) else {
            throw XML.Error.invalidXmlHeader
        }

        try stream.consumeWhitespaces(includingNewLine: true)

        while let (name, value) = try stream.readAttribute() {
            switch name {
            case "version": self.version = value
            case "encoding": self.encoding = try XML.Encoding(value)
            case "standalone": self.standalone = try XML.Standalone(value)
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
    public init<T: UnsafeStreamReader>(from stream: T) throws {
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
        var buffer = try stream.read(until: .angleBracketOpen)
        if !buffer.isEmptyOrWhitespace {
            let text = String(decoding: buffer, as: UTF8.self)
            children.append(.text(text))
        }

        // read children
        while !(try stream.consume(sequence: [.angleBracketOpen, .slash])) {
            let child = try XML.Element(from: stream)
            children.append(.element(child))
            try stream.consumeWhitespaces(includingNewLine: true)
        }

        // read closing tag
        buffer = try stream.read(until: .angleBracketClose)
        guard buffer.count > 0, try stream.consume(.angleBracketClose) else {
            throw XML.Error.invalidClosingTag
        }
        let closingName = String(decoding: buffer, as: UTF8.self)
        guard closingName == name else {
            throw XML.Error.invalidClosingTagName
        }

        self.name = name
        self.attributes = attributes
        self.children = children
    }
}
