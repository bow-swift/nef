import Foundation
import XCTest

public extension Nef {

    static func run<T: XCTestCase>(testCase class: T.Type) {
        startTestObserver()
        T.defaultTestSuite.run()
    }

    static private func startTestObserver() {
        _ = testObserverInstalled
    }

    static private var testObserverInstalled = { () -> NefTestFailObserver in
        let testObserver = NefTestFailObserver()
        XCTestObservationCenter.shared.addTestObserver(testObserver)
        return testObserver
    }()
}

// MARK: enrich the output for XCTest
fileprivate class NefTestFailObserver: NSObject, XCTestObservation {

    private var numberOfFailedTests = 0

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        numberOfFailedTests = 0
    }

    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        if numberOfFailedTests > 0 {
            print("💢 Test Suite '\(testSuite.name)' finished with \(numberOfFailedTests) failed \(numberOfFailedTests > 1 ? "tests" : "test").")
        } else {
            print("🔅 Test Suite '\(testSuite.name)' finished successfully.")
        }
    }

    func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: Int) {

        numberOfFailedTests += 1
        print("❗️Test Fail '\(testCase.name)':\(UInt(lineNumber)): \(description.description)")
    }
}
