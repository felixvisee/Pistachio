//
//  Lens.swift
//  Pistachio
//
//  Created by Robert Böhnke on 1/17/15.
//  Copyright (c) 2015 Robert Böhnke. All rights reserved.
//

import LlamaKit

public struct Lens<A, B> {
    private let get: A -> B
    private let set: (A, B) -> A

    public init(get: A -> B, set: (A, B) -> A) {
        self.get = get
        self.set = set
    }

    public init(get: A -> B, set: (inout A, B) -> ()) {
        self.get = get
        self.set = {
            var copy = $0; set(&copy, $1); return copy
        }
    }
}

// MARK: - Basics

public func get<A, B>(lens: Lens<A, B>, a: A) -> B {
    return lens.get(a)
}

public func get<A, B>(lens: Lens<A, B>)(a: A) -> B {
    return lens.get(a)
}

public func get<A, B>(lens: Lens<A, B>, a: A?) -> B? {
    return map(a, lens.get)
}

public func get<A, B>(lens: Lens<A, B>)(a: A?) -> B? {
    return map(a, lens.get)
}

public func set<A, B>(lens: Lens<A, B>, a: A, b: B) -> A {
    return lens.set(a, b)
}

public func set<A, B>(lens: Lens<A, B>, a: A)(b: B) -> A {
    return lens.set(a, b)
}

public func mod<A, B>(lens: Lens<A, B>, a: A, f: B -> B) -> A {
    return set(lens, a, f(get(lens, a)))
}

// MARK: - Compose

public func compose<A, B, C>(left: Lens<A, B>, right: Lens<B, C>) -> Lens<A, C> {
    let get: A -> C = { a in
        return right.get(left.get(a))
    }

    let set: (A, C) -> A = { a, c in
        return left.set(a, right.set(left.get(a), c))
    }

    return Lens(get: get, set: set)
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <A, B, C>(lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <A, B, C>(lhs: Lens<B, C>, rhs: Lens<A, B>) -> Lens<A, C> {
    return compose(rhs, lhs)
}

// MARK: - Lift

public func lift<A, B>(lens: Lens<A, B>) -> Lens<[A], [B]> {
    let get: [A] -> [B] = { xs in
        return map(xs, lens.get)
    }

    let set: ([A], [B]) -> [A] = { xs, ys in
        return map(zip(xs, ys), lens.set)
    }

    return Lens(get: get, set: set)
}

public func lift<A, B, E>(lens: Lens<A, B>) -> Lens<Result<A, E>, Result<B, E>> {
    let get: Result<A, E> -> Result<B, E> = { a in
        return a.map(lens.get)
    }

    let set: (Result<A, E>, Result<B, E>) -> Result<A, E> = { a, b in
        return a.flatMap { a in b.map { b in lens.set(a, b) } }
    }

    return Lens(get: get, set: set)
}

// MARK: - Transform

public func transform<A, B, C, E>(lens: Lens<Result<A, E>, Result<B, E>>, valueTransformer: ValueTransformer<B, C, E>) -> Lens<Result<A, E>, Result<C, E>> {
    let get: Result<A, E> -> Result<C, E> = { a in
        return lens.get(a).flatMap { valueTransformer.transformedValue($0) }
    }

    let set: (Result<A, E>, Result<C, E>) -> Result<A, E> = { a, c in
        return lens.set(a, c.flatMap { valueTransformer.reverseTransformedValue($0) })
    }

    return Lens(get: get, set: set)
}

public func transform<A, B, C, E>(lens: Lens<Result<A, E>, Result<B, E>>)(valueTransformer: ValueTransformer<B, C, E>) -> Lens<Result<A, E>, Result<C, E>> {
    return transform(lens, valueTransformer)
}

// MARK: - Split

public func split<A, B, C, D>(left: Lens<A, B>, right: Lens<C, D>) -> Lens<(A, C), (B, D)> {
    let get: (A, C) -> (B, D) = { (a, c) in
        return (left.get(a), right.get(c))
    }

    let set: ((A, C), (B, D)) -> (A, C) = { (fst, snd) in
        return (left.set(fst.0, snd.0), right.set(fst.1, snd.1))
    }

    return Lens(get: get, set: set)
}

infix operator *** {
    associativity left
    precedence 150
}

public func *** <A, B, C, D>(lhs: Lens<A, B>, rhs: Lens<C, D>) -> Lens<(A, C), (B, D)> {
    return split(lhs, rhs)
}

// MARK: - Fanout

public func fanout<A, B, C>(left: Lens<A, B>, right: Lens<A, C>) -> Lens<A, (B, C)> {
    let get: A -> (B, C) = { a in
        return (left.get(a), right.get(a))
    }

    let set: (A, (B, C)) -> A = { (a, input) in
        return right.set(left.set(a, input.0), input.1)
    }

    return Lens(get: get, set: set)
}

infix operator &&& {
    associativity left
    precedence 120
}

public func &&& <A, B, C>(lhs: Lens<A, B>, rhs: Lens<A, C>) -> Lens<A, (B, C)> {
    return fanout(lhs, rhs)
}
