import Testing
@testable import XML

@Test("Document")
func document() {
    let document = XML.Document()
    #expect(document.version == "1.0")
    #expect(document.encoding == .utf8)
    #expect(document.standalone == .no)
    #expect(document.root == nil)
}

@Test("Element")
func element() async {
    let element = XML.Element(name: "root")
    #expect(element.name == "root")
    #expect(element.attributes == [:])
    #expect(element.children == [])
}

@Test("Element Node")
func elementNode() {
    let node = XML.Node.element(XML.Element(name: "root"))
    #expect(node == .element(XML.Element(name: "root")))
}

@Test("Text Node")
func textNode() {
    let node = XML.Node.text("text")
    #expect(node == .text("text"))
}

@Test("Element Children")
func elementChildren() {
    let element = XML.Element(name: "root", children: [.text("text")])
    #expect(element.children == [.text("text")])
}

@Test("Element Value")
func elementValue() {
    let element = XML.Element(name: "root", children: [.text("text")])
    #expect(element.value == "text")
}
