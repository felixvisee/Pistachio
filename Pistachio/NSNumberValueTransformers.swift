//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import LlamaKit
import ValueTransformer

public struct NSNumberValueTransformers {
    public static func char<E>() -> ReversibleValueTransformer<NSNumber, Int8, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.charValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(char: transformedValue))
        })
    }

    public static func unsignedChar<E>() -> ReversibleValueTransformer<NSNumber, UInt8, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.unsignedCharValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(unsignedChar: transformedValue))
        })
    }

    public static func short<E>() -> ReversibleValueTransformer<NSNumber, Int16, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.shortValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(short: transformedValue))
        })
    }

    public static func unsignedShort<E>() -> ReversibleValueTransformer<NSNumber, UInt16, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.unsignedShortValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(unsignedShort: transformedValue))
        })
    }

    public static func int<E>() -> ReversibleValueTransformer<NSNumber, Int32, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.intValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(int: transformedValue))
        })
    }

    public static func unsignedInt<E>() -> ReversibleValueTransformer<NSNumber, UInt32, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.unsignedIntValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(unsignedInt: transformedValue))
        })
    }

    public static func long<E>() -> ReversibleValueTransformer<NSNumber, Int, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.longValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(long: transformedValue))
        })
    }

    public static func unsignedLong<E>() -> ReversibleValueTransformer<NSNumber, UInt, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.unsignedLongValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(unsignedLong: transformedValue))
        })
    }

    public static func longLong<E>() -> ReversibleValueTransformer<NSNumber, Int64, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.longLongValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(longLong: transformedValue))
        })
    }

    public static func unsignedLongLong<E>() -> ReversibleValueTransformer<NSNumber, UInt64, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.unsignedLongLongValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(unsignedLongLong: transformedValue))
        })
    }

    public static func float<E>() -> ReversibleValueTransformer<NSNumber, Float, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.floatValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(float: transformedValue))
        })
    }

    public static func double<E>() -> ReversibleValueTransformer<NSNumber, Double, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.doubleValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(double: transformedValue))
        })
    }

    public static func bool<E>() -> ReversibleValueTransformer<NSNumber, Bool, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.boolValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(bool: transformedValue))
        })
    }

    public static func integer<E>() -> ReversibleValueTransformer<NSNumber, Int, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.integerValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(integer: transformedValue))
        })
    }

    public static func unsignedInteger<E>() -> ReversibleValueTransformer<NSNumber, Int, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return success(value.unsignedIntegerValue)
        }, reverseTransformClosure: { transformedValue in
            return success(NSNumber(unsignedInteger: transformedValue))
        })
    }
}
