//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public struct LazyAdapter<A: AdapterType>: AdapterType {
    private let adapter: () -> A

    public init(@autoclosure(escaping) adapter: () -> A) {
        self.adapter = adapter
    }

    public func transform(value: A.ValueType) -> Result<A.TransformedValueType, A.ErrorType> {
        return adapter().transform(value)
    }

    public func reverseTransform(transformedValue: A.TransformedValueType) -> Result<A.ValueType, A.ErrorType> {
        return adapter().reverseTransform(transformedValue)
    }
}

// MARK: - Fix

public func fix<A: AdapterType>(f: LazyAdapter<A> -> A) -> A {
    return f(LazyAdapter(adapter: fix(f)))
}
