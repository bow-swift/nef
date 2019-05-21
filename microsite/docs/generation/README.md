---
layout: docs
title: Generation
permalink: /docs/generation/
---

## Parsing to Json

We can decode from a `String`, a `File`, etc:

```kotlin:ank:silent
import arrow.core.*
import helios.core.*
import helios.meta.*
import helios.typeclasses.*
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

```

## From Json to the ADT

Once we have a Json, we can parse it to an ADT:

```kotlin:ank

val personOrError: Either<DecodingError, Person> = Person.decoder().decode(jsonFromString)

personOrError.fold({
  "Something went wrong during decoding: $it"
}, {
  "Successfully decode the json: $it"
})
```

## Encoding to a Json

We can also encode from a data class instance to a `Json`:

```kotlin:ank
val person = Person("Raul", 34)

val jsonFromPerson = with(Person.encoder()) {
  person.encode()
}

jsonFromPerson.toJsonString()
```
