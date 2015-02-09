# Pistachio

Pistachio is a generic functional model framework for Swift. Given the right value transformers, it can handle encoding to and decoding from any recursive data structure, like JSON, YAML or XML.

If you are already familiar with [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), take a look at [SwiftyPistachio](https://github.com/felixjendrusch/SwiftyPistachio).

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa. You can install it with [Homebrew](http://brew.sh) using the following commands:

```
$ brew update
$ brew install carthage
```

Next, add Pistachio to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "felixjendrusch/Pistachio"
```

Afterwards, run `carthage update` to actually fetch Pistachio.

Finally, on your application target's "General" settings tab, in the "Linked Frameworks and Libraries" section, add `Pistachio.framework` from the [Carthage/Build](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#carthagebuild) folder on disk.

## Usage

Pistachio is all about [lenses](http://chris.eidhof.nl/posts/lenses-in-swift.html), which provide a view on your model. Let's define a simple model:

```swift
struct Person {
  var name: String
  var origin: Origin
}

struct Origin {
  var city: String
}
```

Lenses are basically just a combination of a getter and a setter:

```swift
struct PersonLenses {
  static let name = Lens<Person, String>(get: { $0.name }, set: { (inout person: Person, name) in
    person.name = name
  })

  static let origin = Lens<Person, Origin>(get: { $0.origin }, set: { (inout person: Person, origin) in
    person.origin = origin
  })
}

struct OriginLenses {
  static let city = Lens<Origin, String>(get: { $0.city }, set: { (inout origin: Origin, city) in
    origin.city = city
  })
}
```

They can be used to access and modify your model:

```swift
var person = Person(name: "Felix", origin: Origin(city: "Berlin"))
person = set(PersonLenses.name, person, "Robb")
get(PersonLenses.name, person) // == "Robb"
```

You can even compose, lift, transform, split, fanout, [...](https://github.com/felixjendrusch/Pistachio/blob/master/Pistachio/Lens.swift) them:

```swift
person = set(PersonLenses.origin >>> OriginLenses.city, person, "New York")
```

Given the right value transformers, you can create adapters for your models:

```swift
struct Adapters {
  static let origin = DictionaryAdapter<Origin, AnyObject, NSError>(specification: [
    "city": transform(OriginLenses.city, ValueTransformers.stringToAnyObject)
  ], dictionaryTansformer: ValueTransformers.dictionaryToAnyObject)

  static let person = DictionaryAdapter<Person, AnyObject, NSError>(specification: [
    "name": transform(PersonLenses.name, ValueTransformers.stringToAnyObject),
    "city": transform(PersonLenses.origin, lift(origin, Origin(city: "")))
  ], dictionaryTansformer: ValueTransformers.dictionaryToAnyObject)
}
```
Adapters handle encoding to and decoding from data:

```swift
var person = Person(name: "Seb", origin: Origin(city: "Berlin"))
var data = adapter.encode(person) // == [ "name": "Seb", "origin": [ "city": "Berlin" ] ]
adapter.decode(Person(name: "", origin: Origin(city: "")), from: data) // == person
```

Of course, you can also lift adapters as well as compose and lift value transformers. You can even fix your adapter if your model is recursive.

## About

Pistachio was built by [Felix Jendrusch](http://felixjendrusch.is) and [Robert Böhnke](http://robb.is). Greetings from Berlin :wave:
