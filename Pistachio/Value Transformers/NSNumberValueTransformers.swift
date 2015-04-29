//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result
import ValueTransformer

public struct NSNumberValueTransformers {
    public static func char<E>() -> ReversibleValueTransformer<Int8, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(char: value))
        }, reverseTransformClosure: { transformedValue in
            return Result.success(transformedValue.charValue)
        })
    }

    public static func unsignedChar<E>() -> ReversibleValueTransformer<UInt8, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(unsignedChar: value))
        }, reverseTransformClosure: { transformedValue in
            return Result.success(transformedValue.unsignedCharValue)
        })
    }

    public static func short<E>() -> ReversibleValueTransformer<Int16, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(short: value))
        }, reverseTransformClosure: { transformedValue in
            return Result.success(transformedValue.shortValue)
        })
    }

    public static func unsignedShort<E>() -> ReversibleValueTransformer<UInt16, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(unsignedShort: value))
        }, reverseTransformClosure: { transformedValue in
            return Result.success(transformedValue.unsignedShortValue)
        })
    }

    public static func int<E>() -> ReversibleValueTransformer<Int32, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(int: value))
        }, reverseTransformClosure: { transformedValue in
            return Result.success(transformedValue.intValue)
        })
    }

    public static func unsignedInt<E>() -> ReversibleValueTransformer<UInt32, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(unsignedInt: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.unsignedIntValue)
        })
    }

    public static func long<E>() -> ReversibleValueTransformer<Int, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(long: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.longValue)
        })
    }

    public static func unsignedLong<E>() -> ReversibleValueTransformer<UInt, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(unsignedLong: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.unsignedLongValue)
        })
    }

    public static func longLong<E>() -> ReversibleValueTransformer<Int64, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(longLong: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.longLongValue)
        })
    }

    public static func unsignedLongLong<E>() -> ReversibleValueTransformer<UInt64, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(unsignedLongLong: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.unsignedLongLongValue)
        })
    }

    public static func float<E>() -> ReversibleValueTransformer<Float, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(float: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.floatValue)
        })
    }

    public static func double<E>() -> ReversibleValueTransformer<Double, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(double: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.doubleValue)
        })
    }

    public static func bool<E>() -> ReversibleValueTransformer<Bool, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(bool: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.boolValue)
        })
    }

    public static func integer<E>() -> ReversibleValueTransformer<Int, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(integer: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.integerValue)
        })
    }

    public static func unsignedInteger<E>() -> ReversibleValueTransformer<Int, NSNumber, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return Result.success(NSNumber(unsignedInteger: value))
            }, reverseTransformClosure: { transformedValue in
                return Result.success(transformedValue.unsignedIntegerValue)
        })
    }
}
