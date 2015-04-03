//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Foundation

// MARK: - Zip

public func zip<A, B>(a: [A], b: [B]) -> [(A, B)] {
    var x = [(A, B)]()
    for i in 0 ..< min(a.count, b.count) {
        x.append((a[i], b[i]))
    }

    return x
}

// MARK: - Unzip

public func unzip<A, B>(x: [(A, B)]) -> ([A], [B]) {
    var xs = [A](), ys = [B]()
    for (a, b) in x {
        xs.append(a)
        ys.append(b)
    }

    return (xs, ys)
}
