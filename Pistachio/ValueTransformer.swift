//
//  ValueTransformer.swift
//  Pistachio
//
//  Created by Felix Jendrusch on 2/5/15.
//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.
//

import LlamaKit

public struct ValueTransformer<A, B, E> {
    private let transformClosure: A -> Result<B, E>
    private let reverseTransformClosure: B -> Result<A, E>

    public init(transformClosure: A -> Result<B, E>, reverseTransformClosure: B -> Result<A, E>) {
        self.transformClosure = transformClosure
        self.reverseTransformClosure = reverseTransformClosure
    }

    public func transformedValue(value: A) -> Result<B, E> {
        return self.transformClosure(value)
    }

    public func reverseTransformedValue(value: B) -> Result<A, E> {
        return self.reverseTransformClosure(value)
    }
}

// MARK: - Flip

public func flip<A, B, E>(valueTransformer: ValueTransformer<A, B, E>) -> ValueTransformer<B, A, E> {
    return ValueTransformer(transformClosure: valueTransformer.reverseTransformClosure, reverseTransformClosure: valueTransformer.transformClosure)
}

// MARK: - Compose

public func compose<A, B, C, E>(left: ValueTransformer<A, B, E>, right: ValueTransformer<B, C, E>) -> ValueTransformer<A, C, E> {
    let transformValue: A -> Result<C, E> = { a in
        return left.transformedValue(a).flatMap { b in right.transformedValue(b) }
    }

    let reverseTransformValue: C -> Result<A, E> = { c in
        return right.reverseTransformedValue(c).flatMap { b in left.reverseTransformedValue(b) }
    }

    return ValueTransformer(transformClosure: transformValue, reverseTransformClosure: reverseTransformValue)
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <A, B, C, E>(lhs: ValueTransformer<A, B, E>, rhs: ValueTransformer<B, C, E>) -> ValueTransformer<A, C, E> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <A, B, C, E>(lhs: ValueTransformer<B, C, E>, rhs: ValueTransformer<A, B, E>) -> ValueTransformer<A, C, E> {
    return compose(rhs, lhs)
}

// MARK: - Lift

public func lift<A, B: Equatable, E>(valueTransformer: ValueTransformer<A, B, E>, defaultTransformedValue: @autoclosure () -> B) -> ValueTransformer<A?, B, E> {
    let transformValue: A? -> Result<B, E> = { value in
        if let value = value {
            return valueTransformer.transformedValue(value)
        } else {
            return success(defaultTransformedValue())
        }
    }

    let reverseTransformValue: B -> Result<A?, E> = { value in
        if value == defaultTransformedValue() {
            return success(nil)
        } else {
            return valueTransformer.reverseTransformedValue(value).map { $0 }
        }
    }

    return ValueTransformer(transformClosure: transformValue, reverseTransformClosure: reverseTransformValue)
}

public func lift<A, B, E>(valueTransformer: ValueTransformer<A, B, E>) -> ValueTransformer<[A], [B], E> {
    let transformValue: [A] -> Result<[B], E> = { values in
        var result = [B]()
        for element in values {
            switch valueTransformer.transformedValue(element) {
            case .Success(let value):
                result.append(value.unbox)
            case .Failure(let error):
                return failure(error.unbox)
            }
        }

        return success(result)
    }

    let reverseTransformValue: [B] -> Result<[A], E> = { values in
        var result = [A]()
        for element in values {
            switch valueTransformer.reverseTransformedValue(element) {
            case .Success(let value):
                result.append(value.unbox)
            case .Failure(let error):
                return failure(error.unbox)
            }
        }

        return success(result)
    }

    return ValueTransformer(transformClosure: transformValue, reverseTransformClosure: reverseTransformValue)
}
