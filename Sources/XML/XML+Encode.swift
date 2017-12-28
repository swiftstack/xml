import Stream

extension XML.Encoding {
    var rawValue: String {
        switch self {
        case .utf8: return "utf-8"
        }
    }
}

extension XML.Standalone {
    var rawValue: String {
        switch self {
        case .yes: return "yes"
        case .no: return "no"
        }
    }
}

// TODO: Implement and benchmark raw encoder

extension XML.Document {
    public func encode<T: UnsafeStreamWriter>(
        to stream: T,
        prettify: Bool = false
    ) throws {
        var xml = ""
        encodeHeader(to: &xml, prettify: prettify)
        if let root = root {
            root.encode(to: &xml, prettify: prettify)
        }
        try stream.write(xml: xml)
    }
}

extension XML.Element {
    public func encode<T: UnsafeStreamWriter>(
        to stream: T,
        prettify: Bool = false
    ) throws {
        try encode(to: stream, prettify: prettify, currentLevel: 0)
    }

    func encode<T: UnsafeStreamWriter>(
        to stream: T,
        prettify: Bool,
        currentLevel: Int
    ) throws {
        var xml = ""
        encode(to: &xml, prettify: prettify, currentLevel: currentLevel)
        try stream.write(xml: xml)
    }
}

extension UnsafeStreamWriter {
    func write(xml: String) throws {
        try write([UInt8](xml.utf8))
    }
}
