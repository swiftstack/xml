import Test
@testable import XML

class XMLTests: TestCase {
    func testDocument() {
        let document = XML.Document()
        assertEqual(document.version, "1.0")
        assertEqual(document.encoding, .utf8)
        assertEqual(document.standalone, .no)
        assertNil(document.root)
    }

    func testElement() {
        let element = XML.Element(name: "root")
        assertEqual(element.name, "root")
        assertEqual(element.attributes, [:])
        assertEqual(element.children, [])
    }

    func testElementNode() {
        let node = XML.Node.element(XML.Element(name: "root"))
        assertEqual(node, .element(XML.Element(name: "root")))
    }

    func testTextNode() {
        let node = XML.Node.text("text")
        assertEqual(node, .text("text"))
    }

    func testElementChildren() {
        let element = XML.Element(name: "root", children: [.text("text")])
        assertEqual(element.children, [.text("text")])
    }

    func testNodeValue() {
        let element = XML.Element(name: "root", children: [.text("text")])
        assertEqual(element.value, "text")
    }
}
