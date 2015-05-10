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
                let error = NSError()

                let lifted: Lens<Result<Counter, NSError>, Result<Int, NSError>> = lift(CounterLenses.count)

                it("should get values") {
                    let result = get(lifted, Result.success(counter))

                    expect(result.value).to(equal(1))
                }

                it("should return structure failures on get") {
                    let result = get(lifted, Result.failure(error))

                    expect(result.error).to(beIdenticalTo(error))
                }

                it("should set values") {
                    let result = set(lifted, Result.success(counter), Result.success(1))

                    expect(result.value?.count).to(equal(1))
                }

                it("should return structure failures on set") {
                    let result = set(lifted, Result.failure(error), Result.success(1))

                    expect(result.error).to(beIdenticalTo(error))
                }

                it("should return value failures on set") {
                    let result = set(lifted, Result.success(counter), Result.failure(error))

                    expect(result.error).to(beIdenticalTo(error))
                }
            }
        }

        describe("Mapped lenses") {
            let counter = Counter(count: 0)

            let mapped = map(CounterLenses.count, AnyObjectValueTransformers.int)

            it("should get values") {
                let result = get(mapped, Result.success(counter))
                
                expect(result.value as? Int).to(equal(0))
            }
            
            it("should set values") {
                let result = set(mapped, Result.success(counter), Result.success(2))
                
                expect(result.value?.count).to(equal(2))
            }
        }
    }
}
