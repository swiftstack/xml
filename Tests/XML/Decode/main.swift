import Test
import Stream
@testable import XML

test("Document") {
    let stream = InputByteStream("""
        <?xml version="1.0" encoding="utf-8" standalone="no"?>
        <root>
            <element>text</element>
        </root>
        """)
    let document = try await XML.Document.decode(from: stream)

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

test("UppercasedHeader") {
    let stream = InputByteStream("""
        <?xml version="1.0" encoding="UTF-8" standalone="NO"?>
        <root></root>

        """)
    let document = try await XML.Document.decode(from: stream)

    expect(document.version == "1.0")
    expect(document.encoding == .utf8)
    expect(document.standalone == .no)
    expect(document.root == XML.Element(name: "root"))
}

test("Node") {
    _ = try await XML.Node.decode(from: InputByteStream("<element/>"))
}

test("NodeElement") {
    let node = try await XML.Node.decode(from: InputByteStream("<element/>"))
    expect(node == .element(.init(name: "element")))
}

test("NodeText") {
    let stream = InputByteStream("""
        <root>
            text start
            <element/>
            text end
        </root>
        """)
    let node = try await XML.Node.decode(from: stream)
    expect(node == .element(.init(
        name: "root",
        children: [
            .text("text start"),
            .element(.init(name: "element")),
            .text("text end"),
        ])))
}

test("SelfElement") {
    let stream = InputByteStream("<element/>")
    let element = try await XML.Element.decode(from: stream)
    expect(element == XML.Element(name: "element"))
}

test("TextElement") {
    let stream = InputByteStream("<element>text</element>")
    let element = try await XML.Element.decode(from: stream)
    expect(element == XML.Element(
        name: "element",
        children: [.text("text")]))
}

test("Element") {
    let stream = InputByteStream("""
        <root>
            <element>text</element>
        </root>
        """)
    let element = try await XML.Element.decode(from: stream)
    expect(element == XML.Element(
        name: "root",
        children: [.element(XML.Element(
            name: "element",
            children: [.text("text")]))
        ]))
}

test("ElementChildren") {
    let stream = InputByteStream("""
        <root>
            <element>text</element>
            <element2>text2</element2>
            <element3>text3</element3>
        </root>
        """)
    let element = try await XML.Element.decode(from: stream)
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

test("SelfElementAttributes") {
    let stream = InputByteStream("<element name=\"value\"/>")
    let element = try await XML.Element.decode(from: stream)
    expect(element == XML.Element(
        name: "element",
        attributes: ["name": "value"]
    ))
}

test("TextElementAttributes") {
    let stream = InputByteStream(
        "<element name=\"value\">text</element>")
    let element = try await XML.Element.decode(from: stream)
    expect(element == XML.Element(
        name: "element",
        attributes: ["name": "value"],
        children: [.text("text")]
    ))
}

await run()
