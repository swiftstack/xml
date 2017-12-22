extension XML.Document {
    func encodeHeader(to xml: inout String, prettify: Bool) {
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

        if prettify {
            xml += "\n"
        }
    }

    public var xml: String {
        var xml = ""
        encodeHeader(to: &xml, prettify: true)
        if let root = root {
            root.encode(to: &xml, prettify: true)
        }
        return xml
    }

    public var xmlCompact: String {
        var xml = ""
        encodeHeader(to: &xml, prettify: false)
        if let root = root {
            root.encode(to: &xml, prettify: false)
        }
        return xml
    }
}

extension XML.Element {
    func encode(to xml: inout String, prettify: Bool, currentLevel: Int = 0) {
        let prefix = prettify
            ? String(repeating: " ", count: currentLevel * 4)
            : ""

        if prettify {
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
            if prettify {
                xml += "\n"
            }
            return
        }

        xml += ">"

        // don't prettify single text value
        let prettifyChildren = prettify
            && (children.count > 1 || !children.first!.isText)

        if prettifyChildren {
            xml += "\n"
        }

        for child in children {
            switch child {
            case .text(let string) where prettifyChildren:
                xml += String(repeating: " ", count: (currentLevel + 1) * 4)
                xml += string
                xml += "\n"
            case .text(let string):
                xml += string
            case .element(let element):
                element.encode(
                    to: &xml,
                    prettify: prettify,
                    currentLevel: currentLevel + 1)
            }
        }

        if prettifyChildren {
            xml += prefix
        }

        xml += "</"
        xml += name
        xml += ">"

        if prettify {
            xml += "\n"
        }
    }

    public var xml: String {
        var xml = ""
        encode(to: &xml, prettify: true)
        return xml
    }

    public var xmlCompact: String {
        var xml = ""
        encode(to: &xml, prettify: false)
        return xml
    }
}
