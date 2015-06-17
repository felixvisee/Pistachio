# Pistachio

Pistachio is a generic model framework. By leveraging [lenses](http://chris.eidhof.nl/posts/lenses-in-swift.html) and value transformers, it allows you to create type safe adapters for any recursive data structure, be it JSON, YAML or XML.

If you are already familiar with [Argo](https://github.com/thoughtbot/Argo), take a look at [Pistachiargo](https://github.com/felixjendrusch/Pistachiargo).

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

1. Add Pistachio to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

  ```
  github "felixjendrusch/Pistachio" ~> 0.2
  ```

2. Run `carthage update` to fetch and build Pistachio and its dependencies.

3. [Make sure your application's target links against `Pistachio.framework` and copies all relevant frameworks into its application bundle (iOS); or embeds the binaries of all relevant frameworks (Mac).](https://github.com/carthage/carthage#getting-started)

## Usage

Let's start by defining a very simple model:

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

It can be used to access and modify your model:

```swift
var person = Person(name: "Felix", origin: Origin(city: "Berlin"))
person = set(PersonLenses.name, person, "Robb")
get(PersonLenses.name, person) // == "Robb"
```

And you can [compose, lift, etc.](https://github.com/robb/Monocle/blob/master/Monocle/Lens.swift) them:

```swift
let composed = PersonLenses.origin >>> OriginLenses.city
person = set(composed, person, "New York")
get(composed, person) // == "New York"
```

With lenses and value transformers, you can create adapters for your models:

```swift
struct Adapters {
  static let origin = DictionaryAdapter(specification: [
    "city_name": map(OriginLenses.city, StringToAnyObjectValueTransformers)
  ], dictionaryTansformer: DictionaryToAnyObjectValueTransformers, value: Origin())

  static let person = DictionaryAdapter(specification: [
    "name": map(PersonLenses.name, StringToAnyObjectValueTransformers),
    "origin": map(PersonLenses.origin, origin)
  ], dictionaryTansformer: DictionaryToAnyObjectValueTransformers, value: Person())
}
```

Use `fix` to create adapters for recursive models:

```swift
let adapter: DictionaryAdapter<Key, Value, TransformedValue, Error> = fix { adapter in
  // use `adapter` to reference the currently created adapter
}
```

Adapters handle transforming and reverse transforming your models:

```swift
let adapter = Adapters.person

var person = Person(name: "Seb", origin: Origin(city: "Berlin"))
var data = adapter.transform(person)
// == .Success(Box([ "name": "Seb", "origin": [ "city_name": "Berlin" ] ]))

adapter.reverseTransform(data.value!)
// == .Success(Box(person))
```

Both `transform` and `reverseTransform` return a [`Result`](https://github.com/antitypical/Result/blob/master/Result/Result.swift), which either holds the (reverse) transformed value or an error. This enables you to gracefully handle transformation errors.

## Posts

- [Working with immutable models in Swift](https://github.com/felixjendrusch/blog/blob/master/_posts/2015-02-14-working-with-immutable-models-in-swift.md) (February 14, 2015)
