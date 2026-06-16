import Stream

extension MemoryStream {
    var stringValue: String {
        withUnsafeBufferPointer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
