//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import Result
import ValueTransformer
import Monocle
import Pistachio

struct ValueTransformers {
    static let string = ReversibleValueTransformer<Int, String, NSError>(transformClosure: { value in
        return Result.success(String(value))
    }, reverseTransformClosure: { transformedValue in
        if let value = transformedValue.toInt() {
            return Result.success(value)
        } else {
            return Result.failure(NSError())
        }
    })

    static let int = ReversibleValueTransformer<Int, AnyObject, NSError>(transformClosure: { value in
        return Result.success(value)
    }, reverseTransformClosure: { transformedValue in
        switch transformedValue {
        case let transformedValue as Int:
            return Result.success(transformedValue)
        default:
            return Result.failure(NSError())
        }
    })

    static let array = ReversibleValueTransformer<[AnyObject], AnyObject, NSError>(transformClosure: { value in
        return Result.success(value)
    }, reverseTransformClosure: { transformedValue in
        switch transformedValue {
        case let transformedValue as [AnyObject]:
            return Result.success(transformedValue)
        default:
            return Result.failure(NSError())
        }
    })

    static let dictionary = ReversibleValueTransformer<[String: AnyObject], AnyObject, NSError>(transformClosure: { value in
        return Result.success(value)
    }, reverseTransformClosure: { transformedValue in
        switch transformedValue {
        case let transformedValue as [String: AnyObject]:
            return Result.success(transformedValue)
        default:
            return Result.failure(NSError())
        }
    })
}

struct Inner: Equatable {
    var count: Int
}

func == (lhs: Inner, rhs: Inner) -> Bool {
    return lhs.count == rhs.count
}

struct Outer: Equatable {
    var count: Int

    var inner: Inner

    init(count: Int = 0, inner: Inner = Inner(count: 0)) {
        self.count = count
        self.inner = inner
    }
}

func == (lhs: Outer, rhs: Outer) -> Bool {
    return lhs.count == rhs.count && lhs.inner == rhs.inner
}

struct OuterLenses {
    static let count = Lens(get: { $0.count }, set: { (inout outer: Outer, count) in
        outer.count = count
    })

    static let inner = Lens(get: { $0.inner }, set: { (inout outer: Outer, inner) in
        outer.inner = inner
    })
}

struct InnerLenses {
    static let count = Lens(get: { $0.count }, set: { (inout inner: Inner, count) in
        inner.count = count
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
    ], dictionaryTransformer: ValueTransformers.dictionary, newValue: Inner(count: 0))

    static let outer = DictionaryAdapter(specification: [
        "count": transform(OuterLenses.count, ValueTransformers.int),
        "inner": transform(OuterLenses.inner, inner)
    ], dictionaryTransformer: ValueTransformers.dictionary, newValue: Outer(count: 0, inner: Inner(count: 0)))

    static let node: DictionaryAdapter<Node, AnyObject, NSError> = fix { adapter in
        return DictionaryAdapter(specification: [
            "children": transform(NodeLenses.children, lift(adapter) >>> ValueTransformers.array)
        ], dictionaryTransformer: ValueTransformers.dictionary, newValue: Node(children: []))
    }
}

class AdapterSpec: QuickSpec {
    override func spec() {
        describe("A DictionaryAdapter") {
            let adapter = Adapters.inner

            it("should encode a model") {
                let result = adapter.transform(Inner(count: 1))

                expect(result.value as? [String: Int]).to(equal([ "count": 1 ]))
            }

            it("should decode a model from data") {
                let result = adapter.reverseTransform([ "count": 3 ])

                expect(result.value?.count).to(equal(3))
            }
        }

        describe("Fixed adapters") {
            let adapter = Adapters.node

            it("should encode a model") {
                let result = adapter.transform(Node(children: [ Node(children: []), Node(children: []) ]))

                expect((result.value as? [String: [AnyObject]])?["children"]?.count).to(equal(2))
            }

            it("should decode a model from data") {
                let result = adapter.reverseTransform([ "children": [ [ "children": [] ], [ "children": [] ] ] ])

                expect(result.value?.children.count).to(equal(2))
            }
        }
    }
}
