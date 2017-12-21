import Stream

extension UnsafeStreamReader {
    func consume(sequence: [UInt8]) throws -> Bool {
        guard let buffer = try peek(count: sequence.count) else {
            throw StreamError.insufficientData
        }
        guard buffer.elementsEqual(sequence) else {
            return false
        }
        try consume(count: sequence.count)
        return true
    }
}

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

extension UnsafeStreamReader {
    func read(allowedBytes: AllowedBytes) throws -> UnsafeRawBufferPointer {
        let buffer = allowedBytes.buffer
        return try read(while: { buffer[Int($0)] })
    }
}
