//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Prelude
import Result
import ValueTransformer
import Monocle

public protocol Adapter {
    typealias Model
    typealias Data
    typealias Error

    func encode(model: Model) -> Result<Data, Error>
    func decode(model: Model, from data: Data) -> Result<Model, Error>
}

public struct DictionaryAdapter<Model, Data, Error>: Adapter {
    private let specification: [String: Lens<Result<Model, Error>, Result<Data, Error>>]
    private let dictionaryTansformer: ReversibleValueTransformer<[String: Data], Data, Error>

    public init(specification: [String: Lens<Result<Model, Error>, Result<Data, Error>>], dictionaryTansformer: ReversibleValueTransformer<[String: Data], Data, Error>) {
        self.specification = specification
        self.dictionaryTansformer = dictionaryTansformer
    }

    public func encode(model: Model) -> Result<Data, Error> {
        return reduce(specification, Result.success([:])) { (result, element) in
            return result.flatMap { (var dictionary) in
                return get(element.1, Result.success(model)).map { value in
                    dictionary[element.0] = value
                    return dictionary
                }
            }
        }.flatMap(curry(transform)(dictionaryTansformer))
    }

    public func decode(model: Model, from data: Data) -> Result<Model, Error> {
        return dictionaryTansformer.reverseTransform(data).flatMap { dictionary in
            return reduce(specification, Result.success(model)) { (result, element) in
                if let value = dictionary[element.0] {
                    return set(element.1, result, Result.success(value))
                } else {
                    return result
                }
            }
        }
    }
}

// MARK: - Lift

public func lift<A: Adapter>(adapter: A, @autoclosure(escaping) model: () -> A.Model) -> ReversibleValueTransformer<A.Model, A.Data, A.Error> {
    let transformClosure: A.Model -> Result<A.Data, A.Error> = { model in
        return adapter.encode(model)
    }

    let reverseTransformClosure: A.Data -> Result<A.Model, A.Error> = { data in
        return adapter.decode(model(), from: data)
    }

    return ReversibleValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
}
