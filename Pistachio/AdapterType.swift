//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result
import ValueTransformer

public protocol AdapterType {
    typealias Model
    typealias Data
    typealias Error

    func encode(model: Model) -> Result<Data, Error>
    func decode(model: Model, from data: Data) -> Result<Model, Error>
}

// MARK: - Lift

public func lift<A: AdapterType>(adapter: A, @autoclosure(escaping) model: () -> A.Model) -> ReversibleValueTransformer<A.Model, A.Data, A.Error> {
    let transformClosure: A.Model -> Result<A.Data, A.Error> = { model in
        return adapter.encode(model)
    }

    let reverseTransformClosure: A.Data -> Result<A.Model, A.Error> = { data in
        return adapter.decode(model(), from: data)
    }

    return ReversibleValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
}
