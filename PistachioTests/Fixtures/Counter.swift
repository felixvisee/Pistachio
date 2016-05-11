//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import ValueTransformer
import Monocle
import Pistachio

struct Counter: Equatable {
    var count: Int
}

func == (lhs: Counter, rhs: Counter) -> Bool {
    return lhs.count == rhs.count
}

struct CounterLenses {
    static let count = Lens(get: { $0.count }, set: { (inout counter: Counter, count) in
        counter.count = count
    })
}

struct CounterAdapters {
    static let anyObject = DictionaryAdapter(specification: [
        "count": map(CounterLenses.count, reversibleValueTransformer: AnyObjectValueTransformers.int)
    ], dictionaryTransformer: AnyObjectValueTransformers.dictionary, value: Counter(count: 0))
}
