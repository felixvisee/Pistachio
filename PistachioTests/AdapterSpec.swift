//
//  AdapterSpec.swift
//  Pistachio
//
//  Created by Felix Jendrusch on 2/8/15.
//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.
//

import Quick
import Nimble

import LlamaKit
import Pistachio

extension ValueTransformers {
    static let int: ValueTransformer<Int, AnyObject, NSError> = ValueTransformer(transformClosure: { value in
        return success(value)
    }, reverseTransformClosure: { value in
        switch value {
        case let value as Int:
            return success(value)
        default:
            return failure(NSError())
        }
    })

    static let array: ValueTransformer<[AnyObject], AnyObject, NSError> = ValueTransformer(transformClosure: { value in
        return success(value)
    }, reverseTransformClosure: { value in
        switch value {
        case let value as [AnyObject]:
            return success(value)
        default:
            return failure(NSError())
        }
    })

    static let dictionary: ValueTransformer<[String: AnyObject], AnyObject, NSError> = ValueTransformer(transformClosure: { value in
        return success(value)
    }, reverseTransformClosure: { value in
        switch value {
        case let value as [String: AnyObject]:
            return success(value)
        default:
            return failure(NSError())
        }
    })
}

struct Node {
    var children: [Node]

    init(children: [Node]) {
        self.children = children
    }
}

struct NodeLenses {
    static let children = Lens(get: { $0.children }, set: { (inout node: Node, children) in
        node.children = children
    })
}

struct Adapters {
    static let inner = DictionaryAdapter(specification: [
        "count": transform(InnerLenses.count, ValueTransformers.int)
    ], dictionaryTansformer: ValueTransformers.dictionary)

    static let outer = DictionaryAdapter(specification: [
        "count": transform(OuterLenses.count, ValueTransformers.int),
        "inner": transform(OuterLenses.inner, lift(inner, Inner(count: 0)))
    ], dictionaryTansformer: ValueTransformers.dictionary)

    static let node: DictionaryAdapter<Node, AnyObject, NSError> = fix { adapter in
        return DictionaryAdapter(specification: [
            "children": transform(NodeLenses.children, lift(lift(adapter, Node(children: []))) >>> ValueTransformers.array)
        ], dictionaryTansformer: ValueTransformers.dictionary)
    }
}

class AdapterSpec: QuickSpec {
    override func spec() {
        describe("A DictionaryAdapter") {
            let adapter = Adapters.inner

            it("should encode a model") {
                let result = adapter.encode(Inner(count: 1))

                expect(result.value as? [String: Int]).to(equal([ "count": 1 ]))
            }

            it("should decode a model from data") {
                let result = adapter.decode(Inner(count: 2), from: [ "count": 3 ])

                expect(result.value?.count).to(equal(3))
            }
        }

        describe("Fixed adapters") {
            let adapter = Adapters.node

            it("should encode a model") {
                let result = adapter.encode(Node(children: [ Node(children: []), Node(children: []) ]))

                expect((result.value as? [String: [AnyObject]])?["children"]?.count).to(equal(2))
            }

            it("should decode a model from data") {
                let result = adapter.decode(Node(children: []), from: [ "children": [ [ "children": [] ], [ "children": [] ] ] ])

                expect(result.value?.children.count).to(equal(2))
            }
        }

        describe("Lifted adapters") {
            let adapter = lift(Adapters.inner, Inner(count: 3))

            it("should transform a value") {
                let result = adapter.transformedValue(Inner(count: 4))

                expect(result.value as? [String: Int]).to(equal([ "count": 4 ]))
            }

            it("should reverse transform a value") {
                let result = adapter.reverseTransformedValue([ "count": 5 ])

                expect(result.value?.count).to(equal(5))
            }

            it("should use the default structure") {
                let result = adapter.reverseTransformedValue([String: AnyObject]())

                expect(result.value?.count).to(equal(3))
            }
        }
    }
}
