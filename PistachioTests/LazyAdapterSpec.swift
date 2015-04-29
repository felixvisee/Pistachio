//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import Pistachio

class LazyAdapterSpec: QuickSpec {
    override func spec() {
        describe("A LazyAdapter") {
            let adapter = NodeAdapters.anyObject

            it("should transform a value") {
                let result = adapter.transform(Node(children: [ Node(children: []) ]))

                expect(((result.value as? [String: AnyObject])?["children"] as? [AnyObject])?.count).to(equal(1))
            }

            it("should reverse transform a value") {
                let result = adapter.reverseTransform([ "children": [ [ "children": [] ] ] ])

                expect(result.value).to(equal(Node(children: [ Node(children: []) ])))
            }
        }
    }
}
