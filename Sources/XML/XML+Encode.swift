import Stream

// TODO: Implement and benchmark raw encoder

extension XML.Document {
    public func encode<T: StreamWriter>(
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
    public func encode<T: StreamWriter>(
        to stream: T,
        prettify: Bool = false
    ) throws {
        try encode(to: stream, prettify: prettify, currentLevel: 0)
    }

    func encode<T: StreamWriter>(
        to stream: T,
        prettify: Bool,
        currentLevel: Int
    ) throws {
        var xml = ""
        encode(to: &xml, prettify: prettify, currentLevel: currentLevel)
        try stream.write(xml: xml)
    }
}

extension StreamWriter {
    func write(xml: String) throws {
        try write([UInt8](xml.utf8))
    }
}
