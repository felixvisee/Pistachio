//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Prelude
import Result
import ValueTransformer
import Monocle

// MARK: - Lift

public func lift<A, B, E>(lens: Lens<A, B>) -> Lens<Result<A, E>, Result<B, E>> {
    let get: Result<A, E> -> Result<B, E> = { a in
        return a.map(Monocle.get(lens))
    }

    let set: (Result<A, E>, Result<B, E>) -> Result<A, E> = { a, b in
        return a.flatMap { a in b.map { b in Monocle.set(lens, a, b) } }
    }

    return Lens(get: get, set: set)
}

// MARK: - Transform

public func transform<A, B, C, V: ReversibleValueTransformerType where V.ValueType == B, V.TransformedValueType == C>(lens: Lens<A, B>, reversibleValueTransformer: V) -> Lens<Result<A, V.ErrorType>, Result<C, V.ErrorType>> {
    return transform(lift(lens), reversibleValueTransformer)
}

public func transform<A, B, C, V: ReversibleValueTransformerType where V.ValueType == B, V.TransformedValueType == C>(lens: Lens<Result<A, V.ErrorType>, Result<B, V.ErrorType>>, reversibleValueTransformer: V) -> Lens<Result<A, V.ErrorType>, Result<C, V.ErrorType>> {
    let get: Result<A, V.ErrorType> -> Result<C, V.ErrorType> = { a in
        return Monocle.get(lens, a).flatMap(curry(transform)(reversibleValueTransformer))
    }

    let set: (Result<A, V.ErrorType>, Result<C, V.ErrorType>) -> Result<A, V.ErrorType> = { a, c in
        return Monocle.set(lens, a, c.flatMap(curry(reverseTransform)(reversibleValueTransformer)))
    }

    return Lens(get: get, set: set)
}
