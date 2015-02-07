//
//  PistachioTests.swift
//  PistachioTests
//
//  Created by Felix Jendrusch on 2/5/15.
//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.
//

import UIKit
import XCTest

import LlamaKit
import Pistachio

class Person {
    class var name: Lens<Person, String> { return Lens(get: { person in person.name }, set: { (inout person: Person, name) in person.name = name; }) }
    var name: String = ""

    class var father: Lens<Person, Person?> { return Lens(get: { person in person.father }, set: { (inout person: Person, father) in person.father = father }) }
    var father: Person?

    class var children: Lens<Person, [Person]> { return Lens(get: { person in person.children }, set: { (inout person: Person, children) in person.children = children }) }
    var children: [Person] = []

    init() {}

    init(name: String) {
        self.name = name
    }
}

let DictionaryTransformer: ValueTransformer<AnyObject, [String: AnyObject], NSError> = ({
    let transformClosure: AnyObject -> Result<[String: AnyObject], NSError> = { value in
        switch value {
        case let value as [String: AnyObject]:
            return success(value)
        default:
            return failure(NSError())
        }
    }

    let reverseTransformClosure: [String: AnyObject] -> Result<AnyObject, NSError> = { value in
        return success(value)
    }

    return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
})()

let StringValueTransformer: ValueTransformer<String, AnyObject, NSError> = ({
    let transformClosure: String -> Result<AnyObject, NSError> = { value in
        return success(value)
    }

    let reverseTransformClosure: AnyObject -> Result<String, NSError> = { value in
        switch value {
        case let value as String:
            return success(value)
        default:
            return failure(NSError())
        }
    }

    return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
})()

let ArrayValueTransformer: ValueTransformer<[AnyObject], AnyObject, NSError> = ({
    let transformClosure: [AnyObject] -> Result<AnyObject, NSError> = { value in
        return success(value)
    }

    let reverseTransformClosure: AnyObject -> Result<[AnyObject], NSError> = { value in
        switch value {
        case let value as [AnyObject]:
            return success(value)
        default:
            return failure(NSError())
        }
    }

    return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
})()

let adapter: DictionaryAdapter<Person, AnyObject, NSError> = fix { adapter in
    return DictionaryAdapter(specification: [
        "name": transform(lift(Person.name), StringValueTransformer),
        "father": transform(lift(Person.father), lift(adapter, Person(), [String: AnyObject]())),
        "children": transform(lift(Person.children), lift(lift(adapter, Person())) >>> ArrayValueTransformer)
    ], dictionaryTansformer: DictionaryTransformer)
}

class PistachioTests: XCTestCase {
    func testExample() {
        let input: AnyObject = ["name": "Felix", "father": ["name": "Stefen"]]

        let person = adapter.decode(Person(), from: input)

        XCTAssert(person.value?.father?.name == "Stefen")

        let output = adapter.encode(person.value!)

        XCTAssert(input["name"] as String == output.value!["name"] as String)
    }
}
