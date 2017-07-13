//
//  MarkupToken.swift
//  Markup
//
//  Created by Guille Gonzalez on 11/07/2017.
//  Copyright © 2017 Tuenti Technologies S.L. All rights reserved.
//

import Foundation

enum MarkupToken {
	case text(String)
	case leftDelimiter(UnicodeScalar)
	case rightDelimiter(UnicodeScalar)
}

extension MarkupToken: Equatable {
	static func ==(lhs: MarkupToken, rhs: MarkupToken) -> Bool {
		switch (lhs, rhs) {
		case let (.text(lvalue), .text(rvalue)):
			return lvalue == rvalue
		case let (.leftDelimiter(lvalue), .leftDelimiter(rvalue)):
			return lvalue == rvalue
		case let (.rightDelimiter(lvalue), .rightDelimiter(rvalue)):
			return lvalue == rvalue
		default:
			return false
		}
	}
}

extension MarkupToken: CustomStringConvertible {
	var description: String {
		switch self {
		case .text(let value):
			return value
		case .leftDelimiter(let value):
			return String(value)
		case .rightDelimiter(let value):
			return String(value)
		}
	}
}

extension MarkupToken: CustomDebugStringConvertible {
	var debugDescription: String {
		switch self {
		case .text(let value):
			return "text(\(value))"
		case .leftDelimiter(let value):
			return "leftDelimiter(\(value))"
		case .rightDelimiter(let value):
			return "rightDelimiter(\(value))"
		}
	}
}
