class V2rayParserError extends Error {
  V2rayParserError([this.type = V2rayParserErrorType.parseURI]);
  V2rayParserErrorType type;

  @override
  String toString() {
    switch (type) {
      case V2rayParserErrorType.parseURI:
        return 'V2rayParserError: Error parsing the uri.';
      case V2rayParserErrorType.tagIsExist:
        return 'V2rayParserError: outbound with entered tag is already exists.';
      case V2rayParserErrorType.tagNotFounded:
        return 'V2rayParserError: The outbound with the entered tag could not be found.';
      default:
        return super.toString();
    }
  }
}

enum V2rayParserErrorType { parseURI, tagIsExist, tagNotFounded }
