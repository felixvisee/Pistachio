//
//  Utils.swift
//  Pistachio
//
//  Created by Felix Jendrusch on 2/5/15.
//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.
//

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
    var ax = [A](), bx = [B]()
    for (a, b) in x {
        ax.append(a)
        bx.append(b)
    }

    return (ax, bx)
}
