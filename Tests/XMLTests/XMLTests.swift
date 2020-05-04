import Test
@testable import XML

class XMLTests: TestCase {
    func testDocument() {
        let document = XML.Document()
        expect(document.version == "1.0")
        expect(document.encoding == .utf8)
        expect(document.standalone == .no)
        expect(document.root == nil)
    }

    func testElement() {
        let element = XML.Element(name: "root")
        expect(element.name == "root")
        expect(element.attributes == [:])
        expect(element.children == [])
    }

    func testElementNode() {
        let node = XML.Node.element(XML.Element(name: "root"))
        expect(node == .element(XML.Element(name: "root")))
    }

    func testTextNode() {
        let node = XML.Node.text("text")
        expect(node == .text("text"))
    }

    func testElementChildren() {
        let element = XML.Element(name: "root", children: [.text("text")])
        expect(element.children == [.text("text")])
    }

    func testNodeValue() {
        let element = XML.Element(name: "root", children: [.text("text")])
        expect(element.value == "text")
    }
}
