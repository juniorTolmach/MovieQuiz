import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}

final class MovieQuizTests: XCTestCase {
    func testAddition() throws {
        let arithmeticOperations = ArithmeticOperations()

        let expection = expectation(description: "Addition function expection")
        
        arithmeticOperations.addition(num1: 1, num2: 2) { result in
            XCTAssertEqual(result, 3)
            expection.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

}
