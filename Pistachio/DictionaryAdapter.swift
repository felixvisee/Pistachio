//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result
import ValueTransformer
import Monocle

public struct DictionaryAdapter<Key: Hashable, Value, TransformedValue, Error>: AdapterType {
    private let specification: [Key: Lens<Result<Value, Error>, Result<TransformedValue, Error>>]
    private let dictionaryTransformer: ReversibleValueTransformer<[Key: TransformedValue], TransformedValue, Error>
    private let newValueClosure: TransformedValue -> Result<Value, Error>

    public init(specification: [Key: Lens<Result<Value, Error>, Result<TransformedValue, Error>>], dictionaryTransformer: ReversibleValueTransformer<[Key: TransformedValue], TransformedValue, Error>, newValueClosure: TransformedValue -> Result<Value, Error>) {
        self.specification = specification
        self.dictionaryTransformer = dictionaryTransformer
        self.newValueClosure = newValueClosure
    }

    public init(specification: [Key: Lens<Result<Value, Error>, Result<TransformedValue, Error>>], dictionaryTransformer: ReversibleValueTransformer<[Key: TransformedValue], TransformedValue, Error>, @autoclosure(escaping) newValue: () -> Value) {
        self.init(specification: specification, dictionaryTransformer: dictionaryTransformer, newValueClosure: { _ in
            return Result.success(newValue())
        })
    }

    public func transform(value: Value) -> Result<TransformedValue, Error> {
        return reduce(specification, Result.success([:])) { (result, element) in
            let (key, lens) = element
            return result.flatMap { (var dictionary) in
                return get(lens, Result.success(value)).map { value in
                    dictionary[key] = value
                    return dictionary
                }
            }
        }.flatMap { dictionary in
            return dictionaryTransformer.transform(dictionary)
        }
    }

    public func reverseTransform(transformedValue: TransformedValue) -> Result<Value, Error> {
        return dictionaryTransformer.reverseTransform(transformedValue).flatMap { dictionary in
            return reduce(self.specification, self.newValueClosure(transformedValue)) { (result, element) in
                let (key, lens) = element
                return map(dictionary[key]) { value in
                    return set(lens, result, Result.success(value))
                } ?? result
            }
        }
    }
}
