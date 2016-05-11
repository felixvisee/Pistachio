//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Foundation

import Quick
import Nimble

import Result
import Monocle
import Pistachio

class LensExtensionsSpec: QuickSpec {
    override func spec() {
        describe("Lifted lenses") {
            context("for results") {
                let counter = Counter(count: 1)
                let error = NSError(domain: "errorDomain", code: 1, userInfo: nil)

                let lifted: Lens<Result<Counter, NSError>, Result<Int, NSError>> = lift(CounterLenses.count)

                it("should get values") {
                    let result = get(lifted, a: Result.success(counter))

                    expect(result.value).to(equal(1))
                }

                it("should return structure failures on get") {
                    let result = get(lifted, a: Result.failure(error))

                    expect(result.error).to(beIdenticalTo(error))
                }

                it("should set values") {
                    let result = set(lifted, a: Result.success(counter), b: Result.success(1))

                    expect(result.value?.count).to(equal(1))
                }

                it("should return structure failures on set") {
                    let result = set(lifted, a: Result.failure(error), b: Result.success(1))

                    expect(result.error).to(beIdenticalTo(error))
                }

                it("should return value failures on set") {
                    let result = set(lifted, a: Result.success(counter), b: Result.failure(error))

                    expect(result.error).to(beIdenticalTo(error))
                }
            }
        }

        describe("Mapped lenses") {
            let counter = Counter(count: 0)

            let mapped = map(CounterLenses.count, reversibleValueTransformer: AnyObjectValueTransformers.int)

            it("should get values") {
                let result = get(mapped, a: Result.success(counter))
                
                expect(result.value as? Int).to(equal(0))
            }
            
            it("should set values") {
                let result = set(mapped, a: Result.success(counter), b: Result.success(2))
                
                expect(result.value?.count).to(equal(2))
            }
        }
    }
}
