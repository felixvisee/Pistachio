//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import Pistachio

class DictionaryAdapterSpec: QuickSpec {
    override func spec() {
        describe("A DictionaryAdapter") {
            var adapter = CounterAdapters.anyObject

            it("should transform a value") {
                let result = adapter.transform(Counter(count: 1))

                expect((result.value as? [String: AnyObject])?["count"] as? Int).to(equal(1))
            }

            it("should reverse transform a value") {
                let result = adapter.reverseTransform([ "count": 1 ])

                expect(result.value).to(equal(Counter(count: 1)))
            }
        }
    }
}
