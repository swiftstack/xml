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
