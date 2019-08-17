// Markup
//
// Copyright (c) 2017 Guille Gonzalez
// See LICENSE file for license
//

import Foundation

public struct MarkupParser {
	public static func parse(text: String) -> [MarkupNode] {
		var parser = MarkupParser(text: text)
		return parser.parse().1
	}

	private var tokenizer: MarkupTokenizer
	private var openingDelimiters: [UnicodeScalar] = []
	private init(text: String) {
		tokenizer = MarkupTokenizer(string: text)
	}

	private mutating func parse() -> (UnicodeScalar?, [MarkupNode]) {
		var elements: [MarkupNode] = []
		while let token = tokenizer.nextToken() {
			switch token {
			case .text(let text):
				elements.append(.text(text))

			case .leftDelimiter(let delimiter):
				// Recursively parse all the tokens following the delimiter
				openingDelimiters.append(delimiter)
				let childResult = parse()
				if let childDelemiter = childResult.0, childDelemiter != delimiter && childResult.1.count == 1 {
					if let item = childResult.1.first {
						switch item {
						case .text: elements.append(item)
						case .strong(let children): elements.append(contentsOf: children)
						case .emphasis(let children): elements.append(contentsOf: children)
						case .delete(let children): elements.append(contentsOf: children)
						}
					}
					if let markupNode = MarkupNode(delimiter: childDelemiter, children: elements) { return (childDelemiter, [markupNode]) }
				}
				elements.append(contentsOf: childResult.1)

			case .rightDelimiter(let delimiter) where openingDelimiters.contains(delimiter):
				guard let containerNode = close(delimiter: delimiter, elements: elements) else {
					fatalError("There is no MarkupNode for \(delimiter)")
				}
				return (delimiter, [containerNode])

			default:
				elements.append(.text(token.description))
			}
		}

		// Convert orphaned opening delimiters to plain text
		if let lastOrphan = openingDelimiters.popLast() {
			elements.insert(MarkupNode.text(String(lastOrphan)), at: 0)
		}

		return (nil, elements)
	}

	private mutating func close(delimiter: UnicodeScalar, elements: [MarkupNode]) -> MarkupNode? {
		var newElements = elements

		// Convert orphaned opening delimiters to plain text
		while openingDelimiters.count > 0 {
			let openingDelimiter = openingDelimiters.popLast()!

			if openingDelimiter == delimiter {
				break
			} else {
				newElements.insert(.text(String(openingDelimiter)), at: 0)
			}
		}

		return MarkupNode(delimiter: delimiter, children: newElements)
	}
}
