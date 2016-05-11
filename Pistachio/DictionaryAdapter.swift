//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result
import ValueTransformer
import Monocle

public struct DictionaryAdapter<Key: Hashable, Value, TransformedValue, Error>: AdapterType {
    public typealias Specification = [Key: Lens<Result<Value, Error>, Result<TransformedValue, Error>>]
    private let specification: Specification

    public typealias DictionaryTransformer = ReversibleValueTransformer<[Key: TransformedValue], TransformedValue, Error>
    private let dictionaryTransformer: DictionaryTransformer

    public typealias ValueClosure = TransformedValue -> Result<Value, Error>
    private let valueClosure: ValueClosure

    public init(specification: Specification, dictionaryTransformer: DictionaryTransformer, valueClosure: ValueClosure) {
        self.specification = specification
        self.dictionaryTransformer = dictionaryTransformer
        self.valueClosure = valueClosure
    }

    public init(specification: Specification, dictionaryTransformer: DictionaryTransformer, @autoclosure(escaping) value: () -> Value) {
        self.init(specification: specification, dictionaryTransformer: dictionaryTransformer, valueClosure: { _ in
            return Result.success(value())
        })
    }

    public func transform(value: Value) -> Result<TransformedValue, Error> {
        return specification.reduce(Result.success([:])) { (result, element) in
            let (key, lens) = element
            return result.flatMap { (dictionary) in
                return get(lens, a: Result.success(value)).map { value in
                    var mutableDictionary = dictionary
                    mutableDictionary[key] = value
                    return mutableDictionary
                }
            }
        }.flatMap { dictionary in
            return dictionaryTransformer.transform(dictionary)
        }
    }

    public func reverseTransform(transformedValue: TransformedValue) -> Result<Value, Error> {
        return dictionaryTransformer.reverseTransform(transformedValue).flatMap { dictionary in
            return self.specification.reduce(self.valueClosure(transformedValue)) { (result, element) in
                let (key, lens) = element
                return dictionary[key].map { value in
                    return set(lens, a: result, b: Result.success(value))
                } ?? result
            }
        }
    }
}
