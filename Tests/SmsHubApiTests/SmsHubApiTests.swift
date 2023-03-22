
import XCTest
@testable import SmsHubApi

final class SmsHubApiTests: XCTestCase {
    private var smsHubAPI: SmsHubAPI!
    private var expectation: XCTestExpectation!
    private let apiKey = ""
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        smsHubAPI = SmsHubAPI(apiKey: apiKey, urlSession: urlSession)
        expectation = expectation(description: "Expectation")
    }
    
    override func tearDown() {
        smsHubAPI = nil
        super.tearDown()
    }
    
    func testGetBalance() async throws {
        // Prepare response
        let mockResponse = "ACCESS_BALANCE:100"
        let responseData = mockResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        do {
            let balance = try await smsHubAPI.getBalance()
            XCTAssertEqual(balance, "100", "Expected balance to be 100")
            expectation.fulfill()
        } catch {
            XCTFail("Error occurred: \(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPurchasePhoneNumberSuccess() {
        // Prepare a mock response
        let mockResponse = "ACCESS_NUMBER:12345:123456789"
        let responseData = mockResponse.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        let getNumber = GetNumberRequest(service: .a9a, country: .afghanistan)
        Task {
            do {
                let (id, phone) = try await smsHubAPI.purchasePhoneNumber(by: getNumber)
                XCTAssertEqual(id, 12345, "Expected ID to be 12345")
                XCTAssertEqual(phone, 123456789, "Expected Phone to be 123456789")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetStatusSuccess() {
        // Prepare a mock response
        let mockResponse = "STATUS_OK:123456"
        let responseData = mockResponse.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        let id = 12345
        Task {
            do {
                let (status, code) = try await smsHubAPI.getStatus(id: id)
                XCTAssertEqual(status, GetStatusResponse.statusOk, "Expected GetStatusResponse to be .ready")
                XCTAssertEqual(code, "123456", "Expected code to be 123456")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetStatusWaitRetry() {
        // Prepare a mock response
        let mockResponse = "STATUS_WAIT_RETRY:3245"
        let responseData = mockResponse.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        let id = 12345
        Task {
            do {
                let (status, code) = try await smsHubAPI.getStatus(id: id)
                XCTAssertEqual(status, GetStatusResponse.statusWaitRetry, "Expected GetStatusResponse to be .statusWaitRetry")
                XCTAssertEqual(code, "3245", "Expected code to be 3245")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
