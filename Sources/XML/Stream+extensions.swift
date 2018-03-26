import Stream

final class AllowedBytes {
    @_versioned
    let buffer: UnsafeBufferPointer<Bool>

    init(byteSet set: Set<UInt8>) {
        let buffer = UnsafeMutableBufferPointer<Bool>.allocate(capacity: 256)
        buffer.initialize(repeating: false)
        for byte in set {
            buffer[Int(byte)] = true
        }
        self.buffer = UnsafeBufferPointer(buffer)
    }
}

extension StreamReader {
    func read<T>(
        allowedBytes: AllowedBytes,
        body: (UnsafeRawBufferPointer) throws -> T) throws -> T {
        let buffer = allowedBytes.buffer
        return try read(while: { buffer[Int($0)] }, body: body)
    }
}
