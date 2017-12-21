import Test
@testable import XML

class XMLStringTests: TestCase {
    func testDocument() {
        let document = XML.Document()
        let expected = """
            <?xml version="1.0" encoding="utf-8" standalone="no"?>
            """
        assertEqual(document.xml, expected)
        assertEqual(document.xmlCompact, expected)
    }

    func testElement() {
        let element = XML.Element(name: "element")
        assertEqual(element.xml, "<element/>\n")
        assertEqual(element.xmlCompact, "<element/>")
    }

    func testTextChildren() {
        let element = XML.Element(name: "element", children: [
            .text("text")
        ])
        assertEqual(element.xml, "<element>text</element>\n")
        assertEqual(element.xmlCompact, "<element>text</element>")
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
        assertEqual(element.xml, expected)
        assertEqual(element.xmlCompact, "<root><element>text</element></root>")
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
        assertEqual(element.xml, expected)

        let expectedCompact =
            "<root><element>text</element><element1>text1</element1>" +
            "<element2><element3>text3</element3></element2></root>"
        assertEqual(element.xmlCompact, expectedCompact)
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
        assertEqual(element.xml, expected)

        let expectedCompact = "<root>text<element1>text1</element1>text2</root>"
        assertEqual(element.xmlCompact, expectedCompact)
    }
}
