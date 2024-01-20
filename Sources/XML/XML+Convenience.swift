extension String {
    public init?(_ node: XML.Node) {
        guard case .text(let string) = node else {
            return nil
        }
        self = string
    }

    public init?(_ node: XML.Node?) {
        guard let node = node else {
            return nil
        }
        self.init(node)
    }
}

extension XML.Node {
    var isText: Bool {
        guard case .text = self else {
            return false
        }
        return true
    }
}

extension XML.Element {
    public var value: String? {
        get {
            let textNodes = children.filter { $0.isText }
            guard textNodes.count > 0 else {
                return nil
            }
            return textNodes.map { $0.value! }.joined(separator: " ")
        }
        set {
            switch newValue {
            case .none: children = []
            case .some(let value): children = [.text(value)]
            }
        }
    }

    public subscript(_ name: String) -> XML.Node? {
        self.children.first(where: { node in
            guard let element = XML.Element(node),
                element.name == name else {
                    return false
            }
            return true
        })
    }

    public init?(_ node: XML.Node) {
        guard case .element(let element) = node else {
            return nil
        }
        self = element
    }

    public init?(_ node: XML.Node?) {
        guard let node = node else {
            return nil
        }
        self.init(node)
    }

    public init(name: String, attributes: [String: String], value: String) {
        self.name = name
        self.attributes = attributes
        self.children = [.text(value)]
    }
}

extension XML.Node {
    public var children: [XML.Node] {
        guard let element = XML.Element(self) else {
            return []
        }
        return element.children
    }

    var value: String? {
        switch self {
        case .text(let string): return string
        case .element(let element): return element.value
        }
    }

    public subscript(_ name: String) -> XML.Node? {
        guard let element = XML.Element(self) else {
            return nil
        }
        return element.children.first(where: { node in
            guard let element = XML.Element(node),
                element.name == name else {
                    return false
            }
            return true
        })
    }
}

extension Optional where Wrapped == XML.Node {
    public var children: [XML.Node] {
        guard let element = XML.Element(self) else {
            return []
        }
        return element.children
    }

    public var value: String? {
        guard let node = self else {
            return nil
        }
        return node.value
    }

    public subscript(_ name: String) -> XML.Node? {
        guard let node = self else {
            return nil
        }
        return node[name]
    }
}

extension Array where Element == XML.Node {
    public mutating func append(name: String, value: String) {
        let element = XML.Element(name: name, children: [.text(value)])
        self.append(.element(element))
    }

    public mutating func append(_ element: XML.Element) {
        self.append(.element(element))
    }
}
