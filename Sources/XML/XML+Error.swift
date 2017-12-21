extension XML {
    enum Error: Swift.Error {
        case invalidXmlHeader
        case invalidXmlEncoding
        case invalidClosedTag
        case invalidOpeningTag
        case invalidOpeningTagName
        case invalidClosingTag
        case invalidClosingTagName
        case invalidAttribute
        case invalidAttributeValue
        case duplicateAttribute
    }
}
