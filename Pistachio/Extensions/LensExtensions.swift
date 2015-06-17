//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

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

// MARK: - Map

public func map<A, V: ReversibleValueTransformerType>(lens: Lens<A, V.ValueType>, _ reversibleValueTransformer: V) -> Lens<Result<A, V.ErrorType>, Result<V.TransformedValueType, V.ErrorType>> {
    return map(lift(lens), reversibleValueTransformer)
}

public func map<A, V: ReversibleValueTransformerType>(lens: Lens<Result<A, V.ErrorType>, Result<V.ValueType, V.ErrorType>>, _ reversibleValueTransformer: V) -> Lens<Result<A, V.ErrorType>, Result<V.TransformedValueType, V.ErrorType>> {
    let get: Result<A, V.ErrorType> -> Result<V.TransformedValueType, V.ErrorType> = { a in
        return Monocle.get(lens, a).flatMap(transform(reversibleValueTransformer))
    }

    let set: (Result<A, V.ErrorType>, Result<V.TransformedValueType, V.ErrorType>) -> Result<A, V.ErrorType> = { a, c in
        return Monocle.set(lens, a, c.flatMap(reverseTransform(reversibleValueTransformer)))
    }

    return Lens(get: get, set: set)
}
