//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import LlamaKit

public struct NSNumberValueTransformers {
    public static func char<E>() -> ValueTransformer<NSNumber, Int8, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.charValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(char: value))
        })
    }

    public static func unsignedChar<E>() -> ValueTransformer<NSNumber, UInt8, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.unsignedCharValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(unsignedChar: value))
        })
    }

    public static func short<E>() -> ValueTransformer<NSNumber, Int16, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.shortValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(short: value))
        })
    }

    public static func unsignedShort<E>() -> ValueTransformer<NSNumber, UInt16, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.unsignedShortValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(unsignedShort: value))
        })
    }

    public static func int<E>() -> ValueTransformer<NSNumber, Int32, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.intValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(int: value))
        })
    }

    public static func unsignedInt<E>() -> ValueTransformer<NSNumber, UInt32, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.unsignedIntValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(unsignedInt: value))
        })
    }

    public static func long<E>() -> ValueTransformer<NSNumber, Int, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.longValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(long: value))
        })
    }

    public static func unsignedLong<E>() -> ValueTransformer<NSNumber, UInt, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.unsignedLongValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(unsignedLong: value))
        })
    }

    public static func longLong<E>() -> ValueTransformer<NSNumber, Int64, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.longLongValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(longLong: value))
        })
    }

    public static func unsignedLongLong<E>() -> ValueTransformer<NSNumber, UInt64, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.unsignedLongLongValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(unsignedLongLong: value))
        })
    }

    public static func float<E>() -> ValueTransformer<NSNumber, Float, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.floatValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(float: value))
        })
    }

    public static func double<E>() -> ValueTransformer<NSNumber, Double, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.doubleValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(double: value))
        })
    }

    public static func bool<E>() -> ValueTransformer<NSNumber, Bool, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.boolValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(bool: value))
        })
    }

    public static func integer<E>() -> ValueTransformer<NSNumber, Int, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.integerValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(integer: value))
        })
    }

    public static func unsignedInteger<E>() -> ValueTransformer<NSNumber, Int, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.unsignedIntegerValue)
        }, reverseTransformClosure: { value in
            return success(NSNumber(unsignedInteger: value))
        })
    }
}
