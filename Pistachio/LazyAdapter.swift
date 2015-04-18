//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public struct LazyAdapter<A: Adapter>: Adapter {
    private let adapter: () -> A

    public init(@autoclosure(escaping) adapter: () -> A) {
        self.adapter = adapter
    }

    public func encode(model: A.Model) -> Result<A.Data, A.Error> {
        return adapter().encode(model)
    }

    public func decode(model: A.Model, from data: A.Data) -> Result<A.Model, A.Error> {
        return adapter().decode(model, from: data)
    }
}

// MARK: - Fix

public func fix<A: Adapter>(f: LazyAdapter<A> -> A) -> A {
    return f(LazyAdapter(adapter: fix(f)))
}
