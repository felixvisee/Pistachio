//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import LlamaKit
import ValueTransformer

public protocol AdapterType {
    typealias ModelType
    typealias DataType
    typealias ErrorType

    func encode(model: ModelType) -> Result<DataType, ErrorType>
    func decode(model: ModelType, from data: DataType) -> Result<ModelType, ErrorType>
}

public struct LazyAdapter<A: AdapterType>: AdapterType {
    private let adapter: () -> A

    public init(adapter: @autoclosure () -> A) {
        self.adapter = adapter
    }

    public func encode(model: A.ModelType) -> Result<A.DataType, A.ErrorType> {
        return adapter().encode(model)
    }

    public func decode(model: A.ModelType, from data: A.DataType) -> Result<A.ModelType, A.ErrorType> {
        return adapter().decode(model, from: data)
    }
}

public struct DictionaryAdapter<Model, Data, Error>: AdapterType {
    private let specification: [String: Lens<Result<Model, Error>, Result<Data, Error>>]
    private let dictionaryTansformer: ReversibleValueTransformer<[String: Data], Data, Error>

    public init(specification: [String: Lens<Result<Model, Error>, Result<Data, Error>>], dictionaryTansformer: ReversibleValueTransformer<[String: Data], Data, Error>) {
        self.specification = specification
        self.dictionaryTansformer = dictionaryTansformer
    }

    public func encode(model: Model) -> Result<Data, Error> {
        var dictionary = [String: Data]()
        for (key, lens) in specification {
            switch get(lens, success(model)) {
            case .Success(let value):
                dictionary[key] = value.unbox
            case .Failure(let error):
                return failure(error.unbox)
            }
        }

        return dictionaryTansformer.transform(dictionary)
    }

    public func decode(model: Model, from data: Data) -> Result<Model, Error> {
        return dictionaryTansformer.reverseTransform(data).flatMap { dictionary in
            var result: Result<Model, Error> = success(model)
            for (key, lens) in self.specification {
                if let value = dictionary[key] {
                    result = set(lens, result, success(value))
                    if !result.isSuccess { break }
                }
            }

            return result
        }
    }
}

// MARK: - Fix

public func fix<A: AdapterType>(f: LazyAdapter<A> -> A) -> A {
    return f(LazyAdapter(adapter: fix(f)))
}

// MARK: - Lift

public func lift<A: AdapterType>(adapter: A, model: @autoclosure () -> A.ModelType) -> ReversibleValueTransformer<A.ModelType, A.DataType, A.ErrorType> {
    let transformClosure: A.ModelType -> Result<A.DataType, A.ErrorType> = { model in
        return adapter.encode(model)
    }

    let reverseTransformClosure: A.DataType -> Result<A.ModelType, A.ErrorType> = { data in
        return adapter.decode(model(), from: data)
    }

    return ReversibleValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
}
