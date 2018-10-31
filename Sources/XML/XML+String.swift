extension XML.Document {
    func encodeHeader(to xml: inout String, format: Format) {
        xml += "<?xml"

        if let version = version {
            xml += " version=\""
            xml += version
            xml += "\""
        }

        if let encoding = encoding {
            xml += " encoding=\""
            xml += encoding.rawValue
            xml += "\""
        }

        if let standalone = standalone {
            xml += " standalone=\""
            xml += standalone.rawValue
            xml += "\""
        }

        xml += "?>"

        if format.isPrettify {
            xml += "\n"
        }
    }

    public var xml: String {
        var xml = ""
        encodeHeader(to: &xml, format: .prettify)
        if let root = root {
            root.encode(to: &xml, format: .prettify)
        }
        return xml
    }

    public var xmlCompact: String {
        var xml = ""
        encodeHeader(to: &xml, format: .compact)
        if let root = root {
            root.encode(to: &xml, format: .compact)
        }
        return xml
    }
}

extension XML.Node {
    func encode(to xml: inout String, format: Format) {
        switch self {
        case .text(let string) where format.isPrettify:
            xml += format.prefix
            xml += string
            xml += "\n"
        case .text(let string):
            xml += string
        case .element(let element):
            element.encode(to: &xml, format: format)
        }
    }
}

extension XML.Element {
    func encode(to xml: inout String, format: Format) {
        let prefix = format.prefix

        if format.isPrettify {
            xml += prefix
        }

        xml += "<"
        xml += name

        for (name, value) in attributes {
            xml += " "
            xml += name
            xml += "=\""
            xml += value
            xml += "\""
        }

        guard children.count > 0 else {
            xml += "/>"
            if format.isPrettify {
                xml += "\n"
            }
            return
        }

        xml += ">"

        let childrenFormat: Format
        switch children.count { // don't prettify single text value
        case 1 where children[0].isText: childrenFormat = .compact
        default: childrenFormat = format.nextLevel
        }

        if childrenFormat.isPrettify {
            xml += "\n"
        }

        for child in children {
            child.encode(to: &xml, format: childrenFormat)
        }

        if childrenFormat.isPrettify {
            xml += prefix
        }

        xml += "</"
        xml += name
        xml += ">"

        if format.isPrettify {
            xml += "\n"
        }
    }

    public var xml: String {
        var xml = ""
        encode(to: &xml, format: .prettify)
        return xml
    }

    public var xmlCompact: String {
        var xml = ""
        encode(to: &xml, format: .compact)
        return xml
    }
}

public enum Format {
    case compact
    case prettify
    case prettifyAt(level: Int)

    var isPrettify: Bool {
        switch self {
        case .compact: return false
        case .prettify: return true
        case .prettifyAt: return true
        }
    }

    var level: Int {
        switch self {
        case .compact: return 0
        case .prettify: return 0
        case .prettifyAt(let level): return level
        }
    }

    var nextLevel: Format {
        switch self {
        case .compact: return .compact
        case .prettify: return .prettifyAt(level: 1)
        case .prettifyAt(let level): return .prettifyAt(level: level + 1)
        }
    }

    var prefix: String {
        switch level {
        case 0: return ""
        default: return .init(repeating: " ", count: level * 4)
        }
    }
}
