//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import Pistachio

class UtilsSpec: QuickSpec {
    override func spec() {
        describe("zip") {
            it("should zip two arrays") {
                // Tuples do not conform to Equatable.
                let result = zip([ 1, 2 ], [ 2, 4, 6 ]).map { (a, b) in [ a, b ] }

                expect(result).to(equal([ [ 1, 2 ], [ 2, 4 ] ]))
            }
        }

        describe("unzip") {
            it("should unzip an array of tuples") {
                let (a, b) = unzip([ (1, 2), (2, 4) ])

                expect(a).to(equal([ 1, 2 ]))
                expect(b).to(equal([ 2, 4 ]))
            }
        }
    }
}
