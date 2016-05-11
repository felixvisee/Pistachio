//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import ValueTransformer
import Monocle
import Pistachio

struct Node: Equatable {
    var children: [Node]
}

func == (lhs: Node, rhs: Node) -> Bool {
    return lhs.children == rhs.children
}

struct NodeLenses {
    static let children = Lens(get: { $0.children }, set: { (inout node: Node, children) in
        node.children = children
    })
}

struct NodeAdapters {
    static let anyObject = fix { adapter in
        return DictionaryAdapter(specification: [
            "children": map(NodeLenses.children, reversibleValueTransformer: lift(adapter) >>> AnyObjectValueTransformers.array)
        ], dictionaryTransformer: AnyObjectValueTransformers.dictionary, value: Node(children: []))
    }
}
