import Test
import Stream
@testable import XML

extension OutputByteStream {
    var string: String {
        return String(decoding: bytes, as: UTF8.self)
    }
}

class XMLEncodeTests: TestCase {
    func testDocument() {
        do {
            let root = XML.Element(
                name: "root",
                children: [
                    .element(XML.Element(
                        name: "element",
                        children: [.text("text")]))
                ])

            let document = XML.Document(
                root: root,
                version: "1.0",
                encoding: .utf8,
                standalone: .no)

            let xml =
                "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>" +
                "<root>" +
                "<element>text</element>" +
                "</root>"

            let stream = OutputByteStream()
            try document.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelfElement() {
        do {
            let element = XML.Element(name: "element")

            let xml = "<element/>"

            let stream = OutputByteStream()
            try element.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }

    func testTextElement() {
        do {
            let element = XML.Element(
                name: "element",
                children: [.text("text")])

            let xml = "<element>text</element>"

            let stream = OutputByteStream()
            try element.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }

    func testElement() {
        do {
            let element = XML.Element(
                name: "root",
                children: [.element(XML.Element(
                    name: "element",
                    children: [.text("text")]))
                ])

            let xml = "<root><element>text</element></root>"

            let stream = OutputByteStream()
            try element.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }

    func testElementChildren() {
        do {
            let element = XML.Element(
                name: "root",
                children: [
                    .element(XML.Element(
                        name: "element", children: [.text("text")])),
                    .element(XML.Element(
                        name: "element2", children: [.text("text2")])),
                    .element(XML.Element(
                        name: "element3", children: [.text("text3")]))
                ])

            let xml =
                "<root>" +
                "<element>text</element>" +
                "<element2>text2</element2>" +
                "<element3>text3</element3>" +
                "</root>"

            let stream = OutputByteStream()
            try element.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelfElementAttributes() {
        do {
            let element = XML.Element(
                name: "element",
                attributes: ["name" : "value"])

            let xml = "<element name=\"value\"/>"

            let stream = OutputByteStream()
            try element.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }

    func testTextElementAttributes() {
        do {
            let element = XML.Element(
                name: "element",
                attributes: ["name" : "value"],
                children: [.text("text")])

            let xml = "<element name=\"value\">text</element>"

            let stream = OutputByteStream()
            try element.encode(to: stream)
            assertEqual(stream.string, xml)
        } catch {
            fail(String(describing: error))
        }
    }
}
