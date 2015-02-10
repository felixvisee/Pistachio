# Pistachio

Pistachio is a generic functional model framework for Swift. Given the right value transformers, it can handle encoding to and decoding from any recursive data structure, like JSON, YAML or XML.

~~If you are already familiar with [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), take a look at [SwiftyPistachio](https://github.com/felixjendrusch/SwiftyPistachio).~~

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
```

```swift
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

And you can compose, lift, transform, [...](https://github.com/felixjendrusch/Pistachio/blob/master/Pistachio/Lens.swift) them:

```swift
let composed: Lens<Person, String> = PersonLenses.origin >>> OriginLenses.city
person = set(composed, person, "New York")
get(composed, person) // == "New York"
```

```swift
var persons = [ person ]

let arrayLifted: Lens<[Person], [String]> = lift(composed)
persons = set(arrayLifted, [ person ], [ "San Francisco" ])
get(arrayLifted, persons) // == [ "San Francisco" ]
```

```swift
var result: Result<[Person], NSError> = success(persons)

let resultLifted: Lens<Result<[Person], NSError>, Result<[String], NSError>> = lift(arrayLifted)
result = set(resultLifted, result, success([ "London" ]))
get(resultLifted, result) // == .Success(Box([ "London" ]))
```

```swift
let valueTransformer: ValueTransformer<String, Int> = SocialSecurityNumberValueTransformer

let transformed: Lens<Person, Int> = transform(PersonLenses.name, valueTransformer)
person = set(transformed, person, 1234567890)
get(PersonLenses.name, person) // == "Felix"
```

Value transformers can be flipped, composed and lifted:

```swift
let flipped: ValueTransformer<Int, String> = flip(valueTransformer)
flipped.transformedValue(1234567890) // == "Felix"
```

```swift
let composed: ValueTransformer<String, String> = flipped >>> UppercaseValueTransformer
flipped.transformedValue(1234567890) // == "FELIX"
```

```swift
let dictionaryLifted: ValueTransformer<String, Int> = lift([ "Felix": 1234567890 ], 0, "Unknown")
dictionaryLifted.transformedValue("Felix") // == 1234567890
dictionaryLifted.transformedValue("Hans") // == 0
dictionaryLifted.reverseTransformedValue(1234567890) // == "Felix"
dictionaryLifted.reverseTransformedValue(0) // == "Unknown"
```

```swift
let optionalLifted: ValueTransformer<String?, String> = lift(UppercaseValueTransformer, "")
optionalLifted.transformedValue("Felix") // == "FELIX"
optionalLifted.transformedValue(nil) // == ""
optionalLifted.reverseTransformedValue("FELIX") // == "Felix"
optionalLifted.reverseTransformedValue("") // == nil
```

```swift
let arrayLifted: ValueTransformer<[String], [String]> = lift(UppercaseValueTransformer)
arrayLifted.transformedValue([ "Felix", "Robb" ]) // == [ "FELIX", "ROBB" ]
```

With lenses and value transformers, you can create adapters for your models:

```swift
struct Adapters {
  static let origin = DictionaryAdapter<Origin, AnyObject, NSError>(specification: [
    "city": transform(OriginLenses.city, StringToAnyObjectValueTransformers)
  ], dictionaryTansformer: DictionaryToAnyObjectValueTransformers)

  static let person = DictionaryAdapter<Person, AnyObject, NSError>(specification: [
    "name": transform(PersonLenses.name, StringToAnyObjectValueTransformers),
    "city": transform(PersonLenses.origin, lift(origin, Origin(city: "")))
  ], dictionaryTansformer: DictionaryToAnyObjectValueTransformers)
}
```

Uh, what was that? Right, the `origin` adapter was lifted to a value transformer. Use `fix` to create adapters for recursive models:

```swift
let adapter: DictionaryAdapter<Model, Data, Error> = fix { adapter in
  // use `adapter` to reference the currently created adapter
}
```

Adapters handle encoding to and decoding from data:

```swift
var person = Person(name: "Seb", origin: Origin(city: "Berlin"))
var data: Result<AnyObject, NSError> = adapter.encode(person) // == [ "name": "Seb", "origin": [ "city": "Berlin" ] ]
adapter.decode(Person(name: "", origin: Origin(city: "")), from: data.value!) // == .Success(Box(person))
```

The return value of both `encode` and `decode` is a `Result` (by [LlamaKit](https://github.com/LlamaKit/LlamaKit)), which either holds the encoded/decoded value or an error. This enables you to gracefully handle coding errors.

## About

Pistachio was built by [Felix Jendrusch](http://felixjendrusch.is) and [Robert Böhnke](http://robb.is). Greetings from Berlin :wave:
