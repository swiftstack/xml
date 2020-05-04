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

            expect(document.version == "1.0")
            expect(document.encoding == .utf8)
            expect(document.standalone == .no)
            expect(document.root == XML.Element(
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

            expect(document.version == "1.0")
            expect(document.encoding == .utf8)
            expect(document.standalone == .no)
            expect(document.root == XML.Element(name: "root"))
        }
    }

    func testNode() throws {
        _ = try XML.Node(from: InputByteStream("<element/>"))
    }

    func testNodeElement() throws {
        let node = try XML.Node(from: InputByteStream("<element/>"))
        expect(node == .element(.init(name: "element")))
    }

    func testNodeText() throws {
        let stream = InputByteStream("""
            <root>
                text start
                <element/>
                text end
            </root>
            """)
        let node = try XML.Node(from: stream)
        expect(node == .element(.init(
            name: "root",
            children: [
                .text("text start"),
                .element(.init(name: "element")),
                .text("text end"),
            ])))
    }

    func testSelfElement() {
        scope {
            let stream = InputByteStream("<element/>")
            let element = try XML.Element(from: stream)
            expect(element == XML.Element(name: "element"))
        }
    }

    func testTextElement() {
        scope {
            let stream = InputByteStream("<element>text</element>")
            let element = try XML.Element(from: stream)
            expect(element == XML.Element(
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
            expect(element == XML.Element(
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
            expect(element == XML.Element(
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
            expect(element == XML.Element(
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
            expect(element == XML.Element(
                name: "element",
                attributes: ["name" : "value"],
                children: [.text("text")]
            ))
        }
    }
}
