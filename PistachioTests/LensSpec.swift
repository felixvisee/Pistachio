//
//  LensSpec.swift
//  Pistachio
//
//  Created by Robert Böhnke on 1/17/15.
//  Copyright (c) 2015 Robert Böhnke. All rights reserved.
//

import Quick
import Nimble

import LlamaKit
import Pistachio

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

class LensSpec: QuickSpec {
    override func spec() {
        describe("A Lens") {
            let example: Outer = Outer(count: 2)

            let count = OuterLenses.count

            it("should get values") {
                expect(get(count, example)!).to(equal(2))
            }

            it("should set values") {
                expect(set(count, example, 4)).to(equal(Outer(count: 4)))
            }

            it("should modify values") {
                expect(mod(count, example, { $0 + 2 })).to(equal(Outer(count: 4)))
            }
        }

        describe("A composed Lens") {
            let example = Outer(count: 0, inner: Inner(count: 2))

            let innerCount = OuterLenses.inner >>> InnerLenses.count

            it("should get values") {
                expect(get(innerCount, example)!).to(equal(2))
            }

            it("should set values") {
                expect(set(innerCount, example, 4)).to(equal(Outer(count: 0, inner: Inner(count: 4))))
            }

            it("should modify values") {
                expect(mod(innerCount, example, { $0 + 2 })).to(equal(Outer(count: 0, inner: Inner(count: 4))))
            }
        }

        describe("Lifted lenses") {
            context("for arrays") {
                let inner = [
                    Inner(count: 1),
                    Inner(count: 2),
                    Inner(count: 3),
                    Inner(count: 4)
                ]

                let lifted = lift(InnerLenses.count)

                it("should get values") {
                    let result = get(lifted, inner)

                    expect(result).to(equal([ 1, 2, 3, 4 ]))
                }

                it("should set values") {
                    let result = set(lifted, inner, [ 2, 4, 6, 8 ])

                    expect(result).to(equal([
                        Inner(count: 2),
                        Inner(count: 4),
                        Inner(count: 6),
                        Inner(count: 8)
                    ]))
                }

                it("should reduce the resulting array size accordingly") {
                    // Does this make sense?
                    let result = set(lifted, inner, [ 42 ])

                    expect(result).to(equal([
                        Inner(count: 42)
                    ]))
                }
            }

            context("for results") {
                let inner = Inner(count: 5)
                let error = NSError()

                let lifted: Lens<Result<Inner, NSError>, Result<Int, NSError>> = lift(InnerLenses.count)

                it("should get values") {
                    let result = get(lifted, success(inner))

                    expect(result.value).to(equal(5))
                }

                it("should return structure failures on get") {
                    let result = get(lifted, failure(error))

                    expect(result.error).to(beIdenticalTo(error))
                }

                it("should set values") {
                    let result = set(lifted, success(inner), success(3))

                    expect(result.value?.count).to(equal(3))
                }

                it("should return structure failures on set") {
                    let result = set(lifted, failure(error), success(3))

                    expect(result.error).to(beIdenticalTo(error))
                }

                it("should return value failures on set") {
                    let result = set(lifted, success(inner), failure(error))

                    expect(result.error).to(beIdenticalTo(error))
                }
            }
        }

        describe("Transformed lenses") {
            let outer = Outer(count: 0)

            let transformed = transform(lift(OuterLenses.count), ValueTransformers.string)

            it("should get values") {
                let result = get(transformed, success(outer))

                expect(result.value).to(equal("0"))
            }

            it("should set values") {
                let result = set(transformed, success(outer), success("2"))

                expect(result.value?.count).to(equal(2))
            }
        }

        describe("Split lenses") {
            let outer = Outer(count: 2, inner: Inner(count: 4))
            let inner = Inner(count: 9)

            let both = OuterLenses.count *** InnerLenses.count

            it("should get values") {
                let result = get(both, (outer, inner))

                expect(result.0).to(equal(2))
                expect(result.1).to(equal(9))
            }

            it("should set values") {
                let result = set(both, (outer, inner), (12, 34))

                expect(result.0.count).to(equal(12))
                expect(result.0.inner.count).to(equal(4))
                expect(result.1.count).to(equal(34))
            }
        }

        describe("Fanned out lenses") {
            let example = Outer(count: 0, inner: Inner(count: 2))

            let both = OuterLenses.count &&& (OuterLenses.inner >>> InnerLenses.count)

            it("should get values") {
                let result = get(both, example)

                expect(result.0).to(equal(0))
                expect(result.1).to(equal(2))
            }
            
            it("should set values") {
                let result = set(both, example, (12, 34))
                
                expect(result.count).to(equal(12))
                expect(result.inner.count).to(equal(34))
            }
        }
    }
}
