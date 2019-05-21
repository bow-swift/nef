---
layout: docs
title: Helios
permalink: /docs/
---

# Helios

[![Build Status](https://travis-ci.org/47deg/helios.svg?branch=master)](https://travis-ci.org/47deg/helios/)
[![Kotlin version badge](https://img.shields.io/badge/kotlin-1.3-blue.svg)](https://kotlinlang.org/docs/reference/whatsnew13.html)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)

**Helios** is a library used to transform `Json` text into a model and vice versa.
It's based on part of the [Jawn Parser](https://github.com/non/jawn) built on `Arrow`,
a Functional companion to Kotlin's Standard Library.

Learn more on [**47deg.github.io/helios**](https://47deg.github.io/helios)

## Why Helios

**Helios** is one of the fastest `Json` parser libraries in `Kotlin`
with the advantage of using the `Arrow` library for functional programming.

## Adding the dependency

**Helios** uses Kotlin version `1.3.31` and `Arrow` version `0.9.0`.

To import the library on `Gradle`, add the following repository and dependencies:

```groovy
repositories {
      maven { url "https://jitpack.io" }
 }

dependencies {
    compile "com.47deg:helios-core:0.0.1-SNAPSHOT"
    compile "com.47deg:helios-meta:0.0.1-SNAPSHOT"
    compile "com.47deg:helios-parser:0.0.1-SNAPSHOT"
}
```

## Running Benchmarks

To run the benchmarks for comparing Helios with other Json libraries, execute the following command:

```bash
./gradlew :helios-benchmarks: executeBenchmarks
```

To run the benchmarks with Helios' performance, execute the following command:

```bash
./gradlew :helios-benchmarks: executeHeliosBenchmark
```

## Running Microsite

To run the **Helios** microsite locally, you need to execute the following command:

```bash
bundle install --gemfile ./docs/Gemfile --path vendor/bundle
```

Next, you'll be able to run the following command:

```bash
BUNDLE_GEMFILE=docs/Gemfile bundle exec jekyll serve -s docs
```
