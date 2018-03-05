//
//  Helpers.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash

import Vapor

// MARK: Fetching & Parsing

enum ParsingError: Error {
    case podcast
}

// MARK: Parsing helper funcs

func elements(_ name: String, `in` xml: [XMLIndexer]) -> [XMLIndexer] {
    return xml.filter { $0.element?.name == name }
}

func value(_ name: String, `in` xml: [XMLIndexer]) -> String? {
    return xml.filter { $0.element?.name == name }.first?.element?.text
}

func values(_ name: String, `in` xml: [XMLIndexer]) -> [String] {
    return xml.filter { $0.element?.name == name }.flatMap { $0.element?.text }
}

func attr(_ name: String, attr: String, `in` xml: [XMLIndexer]) -> String? {
    return xml.filter { $0.element?.name == name }.first?.value(ofAttribute: attr)
}

func attrs(_ name: String, attr: String, `in` xml: [XMLIndexer]) -> [String] {
    return xml.filter { $0.element?.name == name }.flatMap { $0.value(ofAttribute: attr) }
}
