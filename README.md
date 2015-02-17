# Pistachio

Pistachio is a generic model framework for Swift. By leveraging [lenses](http://chris.eidhof.nl/posts/lenses-in-swift.html) and value transformers, it allows you to create type safe adapters for any recursive data structure, be it JSON, YAML or XML.

If you are already familiar with [Argo](https://github.com/thoughtbot/Argo), take a look at [Pistachiargo](https://github.com/felixjendrusch/Pistachiargo).

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa. You can install it with [Homebrew](http://brew.sh) using the following commands:

```
$ brew update
$ brew install carthage
```

1. Add Pistachio to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):
  ```
  github "felixjendrusch/Pistachio" ~> 0.1
  ```

2. Run `carthage update` to fetch and build Pistachio and its dependencies.

3. On your application target's "General" settings tab, in the "Linked Frameworks and Libraries" section, add the following frameworks from the [Carthage/Build](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#carthagebuild) folder on disk:
  - `Pistachio.framework`

4. On your application target's "Build Phases" settings tab, click the "+" icon and choose "New Run Script Phase". Create a Run Script with the following contents:
  ```
  /usr/local/bin/carthage copy-frameworks
  ```
  and add the following paths to the frameworks under "Input Files":
  ```
  $(SRCROOT)/Carthage/Build/iOS/LlamaKit.framework
  $(SRCROOT)/Carthage/Build/iOS/Pistachio.framework
  ```
  This script works around an [App Store submission bug](http://www.openradar.me/radar?id=6409498411401216) triggered by universal binaries.

## Usage

Let's start with defining a simple model:

```swift
struct Origin {
  var city: String

  init(city: String = "") {
    self.city = city
  }
}
```

```swift
struct Person {
  var name: String
  var origin: Origin

  init(name: String = "", origin: Origin = Origin()) {
    self.name = name
    self.origin = origin
  }
}
```

A lens is basically just a combination of a getter and a setter, providing a view on your model:

```swift
struct OriginLenses {
  static let city = Lens(get: { $0.city }, set: { (inout origin: Origin, city) in
    origin.city = city
  })
}
```

```swift
struct PersonLenses {
  static let name = Lens(get: { $0.name }, set: { (inout person: Person, name) in
    person.name = name
  })

  static let origin = Lens(get: { $0.origin }, set: { (inout person: Person, origin) in
    person.origin = origin
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
let composed = PersonLenses.origin >>> OriginLenses.city
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

let transformed = transform(PersonLenses.name, valueTransformer)
person = set(transformed, person, 1234567890)
get(PersonLenses.name, person) // == "Felix"
```

Value transformers can be flipped, composed and lifted:

```swift
let flipped = flip(valueTransformer)
flipped.transformedValue(1234567890) // == "Felix"
```

```swift
let composed = flipped >>> UppercaseValueTransformer
flipped.transformedValue(1234567890) // == "FELIX"
```

```swift
let dictionaryLifted = lift([ "Felix": 1234567890 ], 0, "Unknown")
dictionaryLifted.transformedValue("Felix") // == 1234567890
dictionaryLifted.transformedValue("Hans") // == 0
dictionaryLifted.reverseTransformedValue(1234567890) // == "Felix"
dictionaryLifted.reverseTransformedValue(0) // == "Unknown"
```

```swift
let optionalLifted = lift(UppercaseValueTransformer, "")
optionalLifted.transformedValue("Felix") // == "FELIX"
optionalLifted.transformedValue(nil) // == ""
optionalLifted.reverseTransformedValue("FELIX") // == "felix"
optionalLifted.reverseTransformedValue("") // == nil
```

```swift
let arrayLifted = lift(UppercaseValueTransformer)
arrayLifted.transformedValue([ "Felix", "Robb" ]) // == [ "FELIX", "ROBB" ]
```

With lenses and value transformers, you can create adapters for your models:

```swift
struct Adapters {
  static let origin = DictionaryAdapter(specification: [
    "city_name": transform(OriginLenses.city, StringToAnyObjectValueTransformers)
  ], dictionaryTansformer: DictionaryToAnyObjectValueTransformers)

  static let person = DictionaryAdapter(specification: [
    "name": transform(PersonLenses.name, StringToAnyObjectValueTransformers),
    "origin": transform(PersonLenses.origin, lift(origin, Origin()))
  ], dictionaryTansformer: DictionaryToAnyObjectValueTransformers)
}
```

Uh, what was that? Right, the `origin` adapter was lifted into a value transformer.

Use `fix` to create adapters for recursive models:

```swift
let adapter: DictionaryAdapter<Model, Data, Error> = fix { adapter in
  // use `adapter` to reference the currently created adapter
}
```

Adapters handle encoding to and decoding from data:

```swift
let adapter = Adapters.person

var person = Person(name: "Seb", origin: Origin(city: "Berlin"))
var data = adapter.encode(person)
// == .Success(Box([ "name": "Seb", "origin": [ "city_name": "Berlin" ] ]))

adapter.decode(Person(), from: data.value!)
// == .Success(Box(person))
```

Both `encode` and `decode` return a [`LlamaKit.Result`](https://github.com/LlamaKit/LlamaKit/blob/master/LlamaKit/Result.swift), which either holds the encoded/decoded value or an error. This enables you to gracefully handle coding errors.

## Posts

- [Working with immutable models in Swift](https://github.com/felixjendrusch/blog/blob/master/_posts/2015-02-14-working-with-immutable-models-in-swift.md) (February 14, 2015)

## About

Pistachio was built by [Felix Jendrusch](http://felixjendrusch.is) and [Robert Böhnke](http://robb.is). Greetings from Berlin :wave:
