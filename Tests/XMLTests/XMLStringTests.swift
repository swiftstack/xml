import Test
@testable import XML

class XMLStringTests: TestCase {
    func testDocument() {
        let document = XML.Document()
        let expected = """
            <?xml version="1.0" encoding="utf-8" standalone="no"?>

            """

        expect(document.xml == expected)
        expect(document.xmlCompact[...] == expected.dropLast())
    }

    func testElement() {
        let element = XML.Element(name: "element")
        expect(element.xml == "<element/>\n")
        expect(element.xmlCompact == "<element/>")
    }

    func testAttributes() {
        let element = XML.Element(
            name: "element",
            attributes: ["name" : "value"])

        expect(element.xml == "<element name=\"value\"/>\n")
        expect(element.xmlCompact == "<element name=\"value\"/>")
    }

    func testTextChildren() {
        let element = XML.Element(name: "element", children: [
            .text("text")
        ])
        expect(element.xml == "<element>text</element>\n")
        expect(element.xmlCompact == "<element>text</element>")
    }

    func testElementChildren() {
        let element = XML.Element(name: "root", children: [
            .element(
                XML.Element(
                    name: "element",
                    children: [.text("text")]
                )
            )
        ])
        let expected = """
            <root>
                <element>text</element>
            </root>

            """
        expect(element.xml == expected)
        expect(element.xmlCompact == "<root><element>text</element></root>")
    }

    func testElementChildrens() {
        let element = XML.Element(name: "root", children: [
            .element(
                XML.Element(
                    name: "element",
                    children: [.text("text")]
                )
            ),
            .element(
                XML.Element(
                    name: "element1",
                    children: [.text("text1")]
                )
            ),
            .element(
                XML.Element(
                    name: "element2",
                    children: [
                        .element(
                            XML.Element(
                                name: "element3",
                                children: [.text("text3")])
                        )]
                ))
            ])
        let expected = """
            <root>
                <element>text</element>
                <element1>text1</element1>
                <element2>
                    <element3>text3</element3>
                </element2>
            </root>

            """
        expect(element.xml == expected)

        let expectedCompact =
            "<root><element>text</element><element1>text1</element1>" +
            "<element2><element3>text3</element3></element2></root>"
        expect(element.xmlCompact == expectedCompact)
    }

    func testCrazyChildrens() {
        let element = XML.Element(
            name: "root",
            children: [
                .text("text"),
                .element(
                    XML.Element(
                        name: "element1",
                        children: [.text("text1")]
                    )
                ),
                .text("text2"),
            ])

        let expected = """
            <root>
                text
                <element1>text1</element1>
                text2
            </root>

            """
        expect(element.xml == expected)

        let expectedCompact = "<root>text<element1>text1</element1>text2</root>"
        expect(element.xmlCompact == expectedCompact)
    }
}
