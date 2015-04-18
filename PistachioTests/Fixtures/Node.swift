//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import ValueTransformer
import Monocle
import Pistachio

struct Node {
    var children: [Node]
}

struct NodeLenses {
    static let children = Lens(get: { $0.children }, set: { (inout node: Node, children) in
        node.children = children
    })
}

struct NodeAdapters {
    static let anyObject: DictionaryAdapter<String, Node, AnyObject, NSError> = fix { adapter in
        return DictionaryAdapter(specification: [
            "children": transform(NodeLenses.children, lift(adapter) >>> AnyObjectValueTransformers.array)
        ], dictionaryTransformer: AnyObjectValueTransformers.dictionary, newValue: Node(children: []))
    }
}
