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
    static let int: ValueTransformer<Int, AnyObject, NSError> = ({
        let transformClosure: Int -> Result<AnyObject, NSError> = { value in
            return success(value)
        }

        let reverseTransformClosure: AnyObject -> Result<Int, NSError> = { value in
            switch value {
            case let value as Int:
                return success(value)
            default:
                return failure(NSError())
            }
        }

        return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
    })()
}

struct DictionaryTransformers {
    static let anyObject: ValueTransformer<[String: AnyObject], AnyObject, NSError> = ({
        let transformClosure: [String: AnyObject] -> Result<AnyObject, NSError> = { value in
            return success(value)
        }

        let reverseTransformClosure: AnyObject -> Result<[String: AnyObject], NSError> = { value in
            switch value {
            case let value as [String: AnyObject]:
                return success(value)
            default:
                return failure(NSError())
            }
        }

        return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
    })()
}

struct Adapters {
    static let inner = DictionaryAdapter(specification: [
        "count": transform(InnerLenses.count, ValueTransformers.int)
    ], dictionaryTansformer: DictionaryTransformers.anyObject)

    static let outer = DictionaryAdapter(specification: [
        "count": transform(OuterLenses.count, ValueTransformers.int),
        "inner": transform(OuterLenses.inner, lift(inner, Inner(count: 0)))
    ], dictionaryTansformer: DictionaryTransformers.anyObject)
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
