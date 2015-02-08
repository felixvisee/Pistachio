//
//  ValueTransformerSpec.swift
//  Pistachio
//
//  Created by Felix Jendrusch on 2/8/15.
//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.
//

import Quick
import Nimble

import LlamaKit
import Pistachio

struct ValueTransformers {
    static let string: ValueTransformer<Int, String, NSError> = ({
        let transformClosure: Int -> Result<String, NSError> = { value in
            return success(String(value))
        }

        let reverseTransformClosure: String -> Result<Int, NSError> = { value in
            if let value = value.toInt() {
                return success(value)
            } else {
                return failure(NSError())
            }
        }

        return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
    })()
}

class ValueTransformerSpec: QuickSpec {
    override func spec() {
        describe("A ValueTransformer") {
            let valueTransformer = ValueTransformers.string

            it("should transform a value") {
                let result = valueTransformer.transformedValue(1)

                expect(result.value).to(equal("1"))
            }

            it("should reverse transform a value") {
                let result = valueTransformer.reverseTransformedValue("2")

                expect(result.value).to(equal(2))
            }

            it("should fail if its value transformation fails") {
                let result = valueTransformer.reverseTransformedValue("2.5")

                expect(result.isSuccess).to(beFalse())
            }
        }

        describe("A flipped ValueTransformer") {
            let valueTransformer = flip(ValueTransformers.string)

            it("should transform a value") {
                let result = valueTransformer.transformedValue("3")

                expect(result.value).to(equal(3))
            }

            it("should fail if its value transformation fails") {
                let result = valueTransformer.transformedValue("3.5")

                expect(result.isSuccess).to(beFalse())
            }

            it("should reverse transform a value") {
                let result = valueTransformer.reverseTransformedValue(4)

                expect(result.value).to(equal("4"))
            }
        }

        describe("A composed ValueTransformer") {
            let valueTransformer = ValueTransformers.string >>> flip(ValueTransformers.string)

            it("should transform a value") {
                let result = valueTransformer.transformedValue(5)

                expect(result.value).to(equal(5))
            }

            it("should reverse transform a value") {
                let result = valueTransformer.reverseTransformedValue(6)

                expect(result.value).to(equal(6))
            }
        }

        describe("Lifted value transformers") {
            context("for optionals") {
                let valueTransformer = lift(ValueTransformers.string, "default")

                it("should transform a value") {
                    let result = valueTransformer.transformedValue(7)

                    expect(result.value).to(equal("7"))
                }

                it("should use the default transformed value if the input is nil") {
                    let result = valueTransformer.transformedValue(nil)

                    expect(result.value).to(equal("default"))
                }

                it("should reverse transform a value") {
                    let result = valueTransformer.reverseTransformedValue("8")

                    expect(result.value!).to(equal(8))
                }
            }

            context("for arrays") {
                let valueTransformer = lift(ValueTransformers.string)

                it("should transform a value") {
                    let result = valueTransformer.transformedValue([ 9, 10 ])

                    expect(result.value).to(equal([ "9", "10" ]))
                }

                it("should reverse transform a value") {
                    let result = valueTransformer.reverseTransformedValue([ "11", "12" ])

                    expect(result.value).to(equal([ 11, 12 ]))
                }

                it("should fail if any of its value transformations fail") {
                    let result = valueTransformer.reverseTransformedValue([ "13", "13.5" ])

                    expect(result.isSuccess).to(beFalse())
                }
            }
        }
    }
}
