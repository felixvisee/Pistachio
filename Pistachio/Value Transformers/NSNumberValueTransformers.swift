//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result
import ValueTransformer

public struct NSNumberValueTransformers {
    public static func char<E>() -> ReversibleValueTransformer<NSNumber, Int8, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.charValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(char: transformedValue))
        })
    }

    public static func unsignedChar<E>() -> ReversibleValueTransformer<NSNumber, UInt8, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.unsignedCharValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(unsignedChar: transformedValue))
        })
    }

    public static func short<E>() -> ReversibleValueTransformer<NSNumber, Int16, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.shortValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(short: transformedValue))
        })
    }

    public static func unsignedShort<E>() -> ReversibleValueTransformer<NSNumber, UInt16, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.unsignedShortValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(unsignedShort: transformedValue))
        })
    }

    public static func int<E>() -> ReversibleValueTransformer<NSNumber, Int32, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.intValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(int: transformedValue))
        })
    }

    public static func unsignedInt<E>() -> ReversibleValueTransformer<NSNumber, UInt32, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.unsignedIntValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(unsignedInt: transformedValue))
        })
    }

    public static func long<E>() -> ReversibleValueTransformer<NSNumber, Int, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.longValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(long: transformedValue))
        })
    }

    public static func unsignedLong<E>() -> ReversibleValueTransformer<NSNumber, UInt, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.unsignedLongValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(unsignedLong: transformedValue))
        })
    }

    public static func longLong<E>() -> ReversibleValueTransformer<NSNumber, Int64, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.longLongValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(longLong: transformedValue))
        })
    }

    public static func unsignedLongLong<E>() -> ReversibleValueTransformer<NSNumber, UInt64, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.unsignedLongLongValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(unsignedLongLong: transformedValue))
        })
    }

    public static func float<E>() -> ReversibleValueTransformer<NSNumber, Float, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.floatValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(float: transformedValue))
        })
    }

    public static func double<E>() -> ReversibleValueTransformer<NSNumber, Double, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.doubleValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(double: transformedValue))
        })
    }

    public static func bool<E>() -> ReversibleValueTransformer<NSNumber, Bool, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.boolValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(bool: transformedValue))
        })
    }

    public static func integer<E>() -> ReversibleValueTransformer<NSNumber, Int, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.integerValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(integer: transformedValue))
        })
    }

    public static func unsignedInteger<E>() -> ReversibleValueTransformer<NSNumber, Int, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(value.unsignedIntegerValue)
        }, reverseTransformClosure: { transformedValue in
            return Result.success(NSNumber(unsignedInteger: transformedValue))
        })
    }
}
