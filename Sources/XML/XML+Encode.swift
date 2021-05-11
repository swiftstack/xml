import Stream

// TODO: Implement and benchmark raw encoder

extension XML.Document {
    public func encode(
        to stream: StreamWriter,
        format: Format = .compact
    ) async throws {
        var xml = ""
        encodeHeader(to: &xml, format: format)
        if let root = root {
            root.encode(to: &xml, format: format)
        }
        try await stream.write(xml: xml)
    }
}

extension XML.Element {
    public func encode<T: StreamWriter>(
        to stream: T,
        format: Format = .compact
    ) async throws {
        var xml = ""
        encode(to: &xml, format: format)
        try await stream.write(xml: xml)
    }
}

extension StreamWriter {
    func write(xml: String) async throws {
        try await write([UInt8](xml.utf8))
    }
}
