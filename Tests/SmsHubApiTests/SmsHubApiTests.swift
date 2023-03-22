
import XCTest
@testable import SmsHubApi

final class SmsHubApiTests: XCTestCase {
    private var smsHubAPI: ISmsHubAPI!
    private var apiKey: String = "api_token"
    
    override func setUp() {
        super.setUp()
        smsHubAPI = SmsHubAPI(apiKey: apiKey)
    }
    
    override func tearDown() {
        smsHubAPI = nil
        super.tearDown()
    }
    
    func testGetBalance() async throws {
        let balance = try await smsHubAPI.getBalance()
        XCTAssertNotNil(balance, "Balance should not be nil")
    }
    
    func testPurchasePhoneNumber() async throws {
        let getNumberRequest = GetNumberRequest(service: .kuhnaNaRayone, country: .russia)
        let result = try await smsHubAPI.purchasePhoneNumber(by: getNumberRequest)
        print(result.0)
        XCTAssertNotNil(result.0, "ID should not be nil")
        XCTAssertNotNil(result.1, "Phone number should not be nil")
    }
    
    func testGetStatus() async throws {
        let getStatusId = 393619569 // Replace with a valid ID
        let result = try await smsHubAPI.getStatus(id: getStatusId)
        print(result)
        XCTAssertNotNil(result.0, "GetStatusResponse should not be nil")
    }
    
    func testSetStatus() async throws {
        let setStatusId = 393619569 // Replace with a valid ID
        let setStatusResponse = try await smsHubAPI.setStatus(id: setStatusId, status: .cancelActivation)
        XCTAssertEqual(setStatusResponse, SetStatusResponse.accessCancel, "Expected status to be '.success'")
    }
}
