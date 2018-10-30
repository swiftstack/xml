import Test
import Stream
@testable import XML

extension InputByteStream {
    convenience init(_ string: String) {
        self.init([UInt8](string.utf8))
    }
}

class XMLDecodeTests: TestCase {
    func testDocument() {
        scope {
            let stream = InputByteStream("""
                <?xml version="1.0" encoding="utf-8" standalone="no"?>
                <root>
                    <element>text</element>
                </root>
                """)
            let document = try XML.Document(from: stream)

            assertEqual(document.version, "1.0")
            assertEqual(document.encoding, .utf8)
            assertEqual(document.standalone, .no)
            assertEqual(document.root, XML.Element(
                name: "root",
                children: [
                    .element(XML.Element(
                        name: "element",
                        children: [.text("text")]))
                ]))
        }
    }

    func testUppercasedHeader() {
        scope {
            let stream = InputByteStream("""
                <?xml version="1.0" encoding="UTF-8" standalone="NO"?>
                <root></root>

                """)
            let document = try XML.Document(from: stream)

            assertEqual(document.version, "1.0")
            assertEqual(document.encoding, .utf8)
            assertEqual(document.standalone, .no)
            assertEqual(document.root, XML.Element(name: "root"))
        }
    }

    func testSelfElement() {
        scope {
            let stream = InputByteStream("<element/>")
            let element = try XML.Element(from: stream)
            assertEqual(element, XML.Element(name: "element"))
        }
    }

    func testTextElement() {
        scope {
            let stream = InputByteStream("<element>text</element>")
            let element = try XML.Element(from: stream)
            assertEqual(element, XML.Element(
                name: "element",
                children: [.text("text")]))
        }
    }

    func testElement() {
        scope {
            let stream = InputByteStream("""
                <root>
                    <element>text</element>
                </root>
                """)
            let element = try XML.Element(from: stream)
            assertEqual(element, XML.Element(
                name: "root",
                children: [.element(XML.Element(
                    name: "element",
                    children: [.text("text")]))
                ]))
        }
    }

    func testElementChildren() {
        scope {
            let stream = InputByteStream("""
                <root>
                    <element>text</element>
                    <element2>text2</element2>
                    <element3>text3</element3>
                </root>
                """)
            let element = try XML.Element(from: stream)
            assertEqual(element, XML.Element(
                name: "root",
                children: [
                    .element(XML.Element(
                        name: "element", children: [.text("text")])),
                    .element(XML.Element(
                        name: "element2", children: [.text("text2")])),
                    .element(XML.Element(
                        name: "element3", children: [.text("text3")]))
                ]))
        }
    }

    func testSelfElementAttributes() {
        scope {
            let stream = InputByteStream("<element name=\"value\"/>")
            let element = try XML.Element(from: stream)
            assertEqual(element, XML.Element(
                name: "element",
                attributes: ["name" : "value"]
            ))
        }
    }

    func testTextElementAttributes() {
        scope {
            let stream = InputByteStream(
                "<element name=\"value\">text</element>")
            let element = try XML.Element(from: stream)
            assertEqual(element, XML.Element(
                name: "element",
                attributes: ["name" : "value"],
                children: [.text("text")]
            ))
        }
    }
}
