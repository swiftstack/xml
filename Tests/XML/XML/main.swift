import Test
@testable import XML

test.case("Document") {
    let document = XML.Document()
    expect(document.version == "1.0")
    expect(document.encoding == .utf8)
    expect(document.standalone == .no)
    expect(document.root == nil)
}

test.case("Element") {
    let element = XML.Element(name: "root")
    expect(element.name == "root")
    expect(element.attributes == [:])
    expect(element.children == [])
}

test.case("ElementNode") {
    let node = XML.Node.element(XML.Element(name: "root"))
    expect(node == .element(XML.Element(name: "root")))
}

test.case("TextNode") {
    let node = XML.Node.text("text")
    expect(node == .text("text"))
}

test.case("ElementChildren") {
    let element = XML.Element(name: "root", children: [.text("text")])
    expect(element.children == [.text("text")])
}

test.case("NodeValue") {
    let element = XML.Element(name: "root", children: [.text("text")])
    expect(element.value == "text")
}

test.run()
