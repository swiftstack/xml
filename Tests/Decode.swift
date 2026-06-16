import Testing
import Stream
@testable import XML

@Test("Decode Document")
func decodeDocument() async throws {
    let stream = MemoryStream("""
        <?xml version="1.0" encoding="utf-8" standalone="no"?>
        <root>
            <element>text</element>
        </root>
        """)
    let document = try await XML.Document.decode(from: stream)

    #expect(document.version == "1.0")
    #expect(document.encoding == .utf8)
    #expect(document.standalone == .no)
    #expect(document.root == XML.Element(
        name: "root",
        children: [
            .element(XML.Element(
                name: "element",
                children: [.text("text")]))
        ]))
}

@Test("Decode UppercasedHeader")
func decodeUppercasedHeader() async throws {
    let stream = MemoryStream("""
        <?xml version="1.0" encoding="UTF-8" standalone="NO"?>
        <root></root>

        """)
    let document = try await XML.Document.decode(from: stream)

    #expect(document.version == "1.0")
    #expect(document.encoding == .utf8)
    #expect(document.standalone == .no)
    #expect(document.root == XML.Element(name: "root"))
}

@Test("Decode Node")
func decodeNode() async throws {
    _ = try await XML.Node.decode(from: MemoryStream("<element/>"))
}

@Test("Decode NodeElement")
func decodeNodeElement() async throws {
    let node = try await XML.Node.decode(from: MemoryStream("<element/>"))
    #expect(node == .element(.init(name: "element")))
}

@Test("Decode NodeText")
func decodeNodeText() async throws {
    let stream = MemoryStream("""
        <root>
            text start
            <element/>
            text end
        </root>
        """)
    let node = try await XML.Node.decode(from: stream)
    #expect(node == .element(.init(
        name: "root",
        children: [
            .text("text start"),
            .element(.init(name: "element")),
            .text("text end"),
        ])))
}

@Test("Decode SelfElement")
func decodeSelfElement() async throws {
    let stream = MemoryStream("<element/>")
    let element = try await XML.Element.decode(from: stream)
    #expect(element == XML.Element(name: "element"))
}

@Test("Decode TextElement")
func decodeTextElement() async throws {
    let stream = MemoryStream("<element>text</element>")
    let element = try await XML.Element.decode(from: stream)
    #expect(element == XML.Element(
        name: "element",
        children: [.text("text")]))
}

@Test("Decode Element")
func decodeElement() async throws {
    let stream = MemoryStream("""
        <root>
            <element>text</element>
        </root>
        """)
    let element = try await XML.Element.decode(from: stream)
    #expect(element == XML.Element(
        name: "root",
        children: [.element(XML.Element(
            name: "element",
            children: [.text("text")]))
        ]))
}

@Test("Decode ElementChildren")
func decodeElementChildren() async throws {
    let stream = MemoryStream("""
        <root>
            <element>text</element>
            <element2>text2</element2>
            <element3>text3</element3>
        </root>
        """)
    let element = try await XML.Element.decode(from: stream)
    #expect(element == XML.Element(
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

@Test("Decode SelfElementAttributes")
func decodeSelfElementAttributes() async throws {
    let stream = MemoryStream("<element name=\"value\"/>")
    let element = try await XML.Element.decode(from: stream)
    #expect(element == XML.Element(
        name: "element",
        attributes: ["name": "value"]
    ))
}

@Test("Decode TextElementAttributes")
func decodeTextElementAttributes() async throws {
    let stream = MemoryStream(
        "<element name=\"value\">text</element>")
    let element = try await XML.Element.decode(from: stream)
    #expect(element == XML.Element(
        name: "element",
        attributes: ["name": "value"],
        children: [.text("text")]
    ))
}
