---
layout: docs
title: Compile
permalink: /docs/compile/
---

## Automatic Encoding/Decoding

The `@json` annotation will provide the decoder and encoder for that data class,
so we are able to read from and write to Json.

```kotlin
@json
data class Person(val name: String, val age: Int) {
  companion object // <- This is needed
}
```

You will be able to encode and decode using the following:

```kotlin:ank
import arrow.core.*
import helios.core.*
import helios.meta.*
import helios.typeclasses.*
//sampleStart
val personJson = with(Person.encoder()) { Person("Abc", 10).encode() }
Person.decoder().decode(personJson)
//sampleEnd
```

## Building a Json

You can build your own Json object like this:

```kotlin:ank:silent
val jObject = JsObject(
"name" to JsString("Elia"),
"age" to JsNumber(23)
)
```

## Custom Encoders

To create a custom `Encoder`, you need to inherit from the `Encoder` interface and implement the `encode` method.

```kotlin:ank
val personCustomEncoder = object : Encoder<Person> {
  override fun Person.encode(): Json =
    JsObject(
      "first_name" to JsString("John"),
      "age" to JsNumber(28)
    )
}

val personCustomJson = with(personCustomEncoder) { Person("Abc", 10).encode() }
```


## Custom Decoders

You can follow the same approach to create a custom Decoder:

```kotlin:ank
import arrow.core.extensions.either.applicative.applicative
import helios.instances.decoder

val personCustomDecoder = object : Decoder<Person> {
  override fun decode(value: Json): Either<DecodingError, Person> =
    Either.applicative<DecodingError>().map(
      value["first_name"].fold({ Either.Left(KeyNotFound("first_name")) }, { it.decode(String.decoder()) }),
      value["age"].fold({ Either.Left(KeyNotFound("age")) }, { it.decode(Int.decoder()) })
    ) { tuple ->
      Person(tuple.a, tuple.b)
    }.fix()
}

personCustomDecoder.decode(personCustomJson)
```

## Navigation through Json

You can navigate `Json` using the `Json.path` DSL to select keys or traverse collections.

```kotlin:ank
import helios.optics.*

Json.path.select("name").string.modify(jObject, String::toUpperCase)
```

Note that the code generation will give you an accessor for each json field.

```kotlin:ank
Json.path.name.string.modify(jObject, String::toUpperCase)
```
