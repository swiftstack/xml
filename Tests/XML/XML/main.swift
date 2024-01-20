import Test
@testable import XML

test("Document") {
    let document = XML.Document()
    expect(document.version == "1.0")
    expect(document.encoding == .utf8)
    expect(document.standalone == .no)
    expect(document.root == nil)
}

test("Element") {
    let element = XML.Element(name: "root")
    expect(element.name == "root")
    expect(element.attributes == [:])
    expect(element.children == [])
}

test("ElementNode") {
    let node = XML.Node.element(XML.Element(name: "root"))
    expect(node == .element(XML.Element(name: "root")))
}

test("TextNode") {
    let node = XML.Node.text("text")
    expect(node == .text("text"))
}

test("ElementChildren") {
    let element = XML.Element(name: "root", children: [.text("text")])
    expect(element.children == [.text("text")])
}

test("NodeValue") {
    let element = XML.Element(name: "root", children: [.text("text")])
    expect(element.value == "text")
}

await run()
