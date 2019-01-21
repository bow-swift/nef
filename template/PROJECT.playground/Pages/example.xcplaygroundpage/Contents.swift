/*:
 # Functional Programming in Swift with ![Bow](bow-brand-color.png)

 Bow is a Swift library for Typed Functional Programming, available as an open-source project on [Github](https://github.com/bow-swift/bow).
 */
import Bow

/*:
 ## Function composition

 The most basic operation in functional programming is **composition**. Composing two functions is equivalent to applying them sequentially.

 In Bow, there is a function called `compose` to do this:
 */
func f1(_ x : Int) -> Int {
    return 2 * x
}

func f2(_ x : Int) -> String {
    return "\(x)"
}

let composedWithOperator = f2 <<< f1
/*:
 Reading composition backwards is sometimes difficult, specially if we chain multiple functions. Bow has a function called `andThen`, which has inputs in reverse order:
 */
let composedWithAndThen = andThen(f1, f2)
/*:
 Likewise, Bow has the `andThen` operator, namely `>>>`:
 */
let composedWithAndThenOperator = f1 >>> f2
