extension XML {
    enum Error: Swift.Error {
        case invalidXmlHeader
        case invalidXmlEncoding
        case invalidSelfClosingTag
        case invalidOpeningTag
        case invalidOpeningTagName
        case invalidClosingTag
        case invalidClosingTagName
        case invalidClosingTagNameMismatch
        case invalidAttribute
        case invalidAttributeName
        case invalidAttributeValue
        case duplicateAttribute
    }
}
