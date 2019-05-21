---
layout: docs
title: Integration
permalink: /docs/integration/
---

# QuickStart

Once Helios is added to your project, you can start adding the necessary imports:

```kotlin:ank:silent
import arrow.core.*
import helios.core.*
import helios.meta.*
import helios.typeclasses.*
```

Now, we can start to create our DSL.

## DSL

```kotlin
@json
data class Person(val name: String, val age: Int) {
  companion object
}
```

The `@json` annotation will provide the decoder and encoder for that data class,
so we are able to read from and write to Json.

## Decode

We can decode from a `String`, a `File`, etc.

```kotlin:ank
val jsonStr =
"""{
     "name": "Simon",
     "age": 30
   }"""

val jsonFromString : Json =
  Json.parseFromString(jsonStr).getOrHandle {
    println("Failed creating the Json ${it.localizedMessage}, creating an empty one")
    JsString("")
  }

val personOrError: Either<DecodingError, Person> = Person.decoder().decode(jsonFromString)

personOrError.fold({
  "Something went wrong during decoding: $it"
}, {
  "Successfully decode the json: $it"
})
```

## Encode

We can also encode from a data class instance to a `Json`:

```kotlin:ank
val person = Person("Raul", 34)

val jsonFromPerson = with(Person.encoder()) {
  person.encode()
}

jsonFromPerson.toJsonString()
```

You can find more on the [`samples` module](https://github.com/47deg/helios/tree/master/helios-sample/src/main/kotlin/helios/sample).
