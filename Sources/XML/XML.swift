public struct XML {
    public enum Node {
        case element(Element)
        case text(String)
    }

    public enum Encoding: String {
        case utf8 = "utf-8"
    }

    public enum Standalone: String {
        case yes, no
    }

    public struct Document {
        public var version: String? = nil
        public var encoding: Encoding? = nil
        public var standalone: Standalone? = nil

        public var root: Element? = nil

        public init(
            root: Element? = nil,
            version: String? = "1.0",
            encoding: Encoding? = .utf8,
            standalone: Standalone? = .no
        ) {
            self.root = root
            self.version = version
            self.encoding = encoding
            self.standalone = standalone
        }
    }

    public struct Element {
        public var name: String
        public var attributes: [String : String]
        public var children: [Node]

        public init(
            name: String,
            attributes: [String : String] = [:],
            children: [Node] = []
        ) {
            self.name = name
            self.attributes = attributes
            self.children = children
        }
    }
}

extension XML.Element: Equatable {
    public static func == (lhs: XML.Element, rhs: XML.Element) -> Bool {
        return lhs.name == rhs.name
            && lhs.attributes == rhs.attributes
            && lhs.children == rhs.children
    }
}

extension XML.Node: Equatable {
    public static func == (lhs: XML.Node, rhs: XML.Node) -> Bool {
        switch (lhs, rhs) {
        case let (.element(lhs), .element(rhs)): return lhs == rhs
        case let (.text(lhs), .text(rhs)): return lhs == rhs
        default: return false
        }
    }
}
