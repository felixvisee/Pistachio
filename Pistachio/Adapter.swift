//
//  Adapter.swift
//  Pistachio
//
//  Created by Felix Jendrusch on 2/6/15.
//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.
//

import LlamaKit

public protocol Adapter {
    typealias Model
    typealias Data
    typealias Error

    func encode(model: Model) -> Result<Data, Error>
    func decode(model: Model, from data: Data) -> Result<Model, Error>
}

public struct LazyAdapter<Model, Data, Error, T: Adapter where T.Model == Model, T.Data == Data, T.Error == Error>: Adapter {
    private let adapter: () -> T

    public init(adapter: @autoclosure () -> T) {
        self.adapter = adapter
    }

    public func encode(model: Model) -> Result<Data, Error> {
        return adapter().encode(model)
    }

    public func decode(model: Model, from data: Data) -> Result<Model, Error> {
        return adapter().decode(model, from: data)
    }
}

public struct DictionaryAdapter<Model, Data, Error>: Adapter {
    private let specification: [String: Lens<Result<Model, Error>, Result<Data, Error>>]
    private let dictionaryTansformer: ValueTransformer<[String: Data], Data, Error>

    public init(specification: [String: Lens<Result<Model, Error>, Result<Data, Error>>], dictionaryTansformer: ValueTransformer<[String: Data], Data, Error>) {
        self.specification = specification
        self.dictionaryTansformer = dictionaryTansformer
    }

    public func encode(model: Model) -> Result<Data, Error> {
        var dictionary = [String: Data]()
        for (key, lens) in self.specification {
            switch get(lens, success(model)) {
            case .Success(let value):
                dictionary[key] = value.unbox
            case .Failure(let error):
                return failure(error.unbox)
            }
        }

        return dictionaryTansformer.transformedValue(dictionary)
    }

    public func decode(model: Model, from data: Data) -> Result<Model, Error> {
        return dictionaryTansformer.reverseTransformedValue(data).flatMap { dictionary in
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

public func fix<Model, Data, Error, T: Adapter where T.Model == Model, T.Data == Data, T.Error == Error>(f: LazyAdapter<Model, Data, Error, T> -> T) -> T {
    return f(LazyAdapter(adapter: fix(f)))
}

// MARK: - Lift

public func lift<Model, Data, Error, T: Adapter where T.Model == Model, T.Data == Data, T.Error == Error>(adapter: T, model: @autoclosure () -> Model) -> ValueTransformer<Model, Data, Error> {
    let transformClosure: Model -> Result<Data, Error> = { model in
        return adapter.encode(model)
    }

    let reverseTransformClosure: Data -> Result<Model, Error> = { data in
        return adapter.decode(model(), from: data)
    }

    return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
}
