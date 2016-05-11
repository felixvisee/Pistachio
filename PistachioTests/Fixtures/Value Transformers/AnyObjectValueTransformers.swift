//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Foundation

import Result
import ValueTransformer

struct AnyObjectValueTransformers {
    static let int = ReversibleValueTransformer<Int, AnyObject, NSError>(transformClosure: { value in
        return Result.success(value)
    }, reverseTransformClosure: { transformedValue in
        switch transformedValue {
        case let transformedValue as Int:
            return Result.success(transformedValue)
        default:
            return Result.failure(NSError(domain: "domain", code: 1, userInfo: nil))
        }
    })

    static let array = ReversibleValueTransformer<[AnyObject], AnyObject, NSError>(transformClosure: { value in
        return Result.success(value)
    }, reverseTransformClosure: { transformedValue in
        switch transformedValue {
        case let transformedValue as [AnyObject]:
            return Result.success(transformedValue)
        default:
            return Result.failure(NSError(domain: "domain", code: 1, userInfo: nil))
        }
    })

    static let dictionary = ReversibleValueTransformer<[String: AnyObject], AnyObject, NSError>(transformClosure: { value in
        return Result.success(value)
    }, reverseTransformClosure: { transformedValue in
        switch transformedValue {
        case let transformedValue as [String: AnyObject]:
            return Result.success(transformedValue)
        default:
            return Result.failure(NSError(domain: "domain", code: 1, userInfo: nil))
        }
    })
}
