//
//  CoinServiceProviderTests.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import Foundation
import XCTest
import Combine
@testable import Coin64


final class CoinServiceProviderTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    var provider: CoinServiceProvider!
    var mockEndpoint: MockEndpoint!

    override func setUp() {
        super.setUp()
        mockEndpoint = MockEndpoint(url: URL(string: "https://test.test"), method: "GET")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        provider = CoinServiceProvider(session: session)
    }

    override func tearDown() {
        cancellables = []
        MockURLProtocol.responseData = nil
        MockURLProtocol.error = nil
        provider = nil
        mockEndpoint = nil
        super.tearDown()
    }

    struct MockResponse: Codable, Equatable {
        let message: String
    }

    func testInvalidURLReturnsError() {
        let expectation = self.expectation(description: "Invalid URL Error")

        let invalidEndpoint = MockEndpoint(url: nil, method: "GET")

        provider.request(invalidEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   let networkError = error as? CoinServiceProvider.NetworkError,
                   networkError == .invalidURL {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testNoInternetConnectionReturnsError() {
        let expectation = self.expectation(description: "No Internet Error")

        MockURLProtocol.error = URLError(.notConnectedToInternet)


        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   let networkError = error as? CoinServiceProvider.NetworkError,
                   networkError == .noInternetConnection {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testOtherURLErrorIsPassedThrough() {
        let expectation = self.expectation(description: "Other URLError")

        MockURLProtocol.error = URLError(.timedOut)

        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   (error as? URLError)?.code == .timedOut {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testDecodingErrorReturnsDecodingError() {
        let expectation = self.expectation(description: "Decoding error")

        let invalidJSON = """
        { "unexpected_key": "unexpected_value" }
        """.data(using: .utf8)
        MockURLProtocol.responseData = invalidJSON

        // Mock a valid HTTPURLResponse with status code 200
        let url = URL(string: "https://test.test")!
        let successResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.response = successResponse

        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   let networkError = error as? CoinServiceProvider.NetworkError,
                   case .decodingError = networkError {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected decodingError")
                }
            }, receiveValue: { _ in
                XCTFail("Should not succeed with invalid JSON")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testInvalidStatusCodeReturnsError() {
        let expectation = self.expectation(description: "Invalid status code error")

        // Test with StatusCode with 404
        let badResponse = HTTPURLResponse(
            url: URL(string: "https://test.test")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.response = badResponse
        MockURLProtocol.responseData = Data()

        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   let networkError = error as? CoinServiceProvider.NetworkError,
                   case .invalidStatusCode(let code) = networkError {
                    XCTAssertEqual(code, 404)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected invalidStatusCode error")
                }
            }, receiveValue: { _ in
                XCTFail("Should not succeed with invalid status code")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testSuccessfulRequestReturnsDecodedData() {
        let expectation = self.expectation(description: "Success Response")

        let mockResponse = MockResponse(message: "Hello")
        let responseData = try! JSONEncoder().encode(mockResponse)
        let url = URL(string: "https://test.test")!
        let successResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.response = successResponse
        MockURLProtocol.responseData = responseData

        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected failure: \(error)")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, mockResponse)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testInvalidResponseReturnsInvalidResponseError() {
        let expectation = self.expectation(description: "Invalid response error")

        let validJSON = """
        { "message": "Hello" }
        """.data(using: .utf8)
        MockURLProtocol.responseData = validJSON

        let url = URL(string: "https://test.test")!
        let nonHTTPResponse = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        MockURLProtocol.response = nonHTTPResponse

        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   let networkError = error as? CoinServiceProvider.NetworkError,
                   case .invalidResponse = networkError {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected invalidResponse error")
                }
            }, receiveValue: { _ in
                XCTFail("Should not succeed with invalid response")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testInvalidStatusCodeEquality() {
        let error1 = CoinServiceProvider.NetworkError.invalidStatusCode(404)
        let error2 = CoinServiceProvider.NetworkError.invalidStatusCode(404)
        let error3 = CoinServiceProvider.NetworkError.invalidStatusCode(500)

        XCTAssertEqual(error1, error2, "Errors with the same status code should be equal.")
        XCTAssertNotEqual(error1, error3, "Errors with different status codes should not be equal.")
    }

    func testDifferentErrorCasesInequality() {
        let error1 = CoinServiceProvider.NetworkError.invalidURL
        let error2 = CoinServiceProvider.NetworkError.noInternetConnection
        let error3 = CoinServiceProvider.NetworkError.invalidResponse
        let error4 = CoinServiceProvider.NetworkError.decodingError(NSError(domain: "", code: 0, userInfo: nil))
        let error5 = CoinServiceProvider.NetworkError.invalidStatusCode(400)

        XCTAssertNotEqual(error1, error2, "Different error cases should not be equal.")
        XCTAssertNotEqual(error1, error3, "Different error cases should not be equal.")
        XCTAssertNotEqual(error1, error4, "Different error cases should not be equal.")
        XCTAssertNotEqual(error1, error5, "Different error cases should not be equal.")
    }

    func testLocalizedNetworkErrorDescription() {

        let invalidURL = CoinServiceProvider.NetworkError.invalidURL
        let noInternetConnection = CoinServiceProvider.NetworkError.noInternetConnection
        let invalidResponse = CoinServiceProvider.NetworkError.invalidResponse
        let decodingError = CoinServiceProvider.NetworkError.decodingError(NSError(domain: "Failed to decode the response", code: 0, userInfo: nil))
        let invalidStatusCode = CoinServiceProvider.NetworkError.invalidStatusCode(400)

        XCTAssertEqual(invalidURL.localizedDescription, NSLocalizedString("The URL provided is invalid.", comment: ""))
        XCTAssertEqual(noInternetConnection.localizedDescription, NSLocalizedString("No internet connection is available.", comment: ""))
        XCTAssertEqual(invalidResponse.localizedDescription, NSLocalizedString("The server response was invalid.", comment: ""))
        XCTAssertEqual(decodingError.localizedDescription, "Failed to decode the response: The operation couldn’t be completed. (Failed to decode the response error 0.)")
        XCTAssertEqual(invalidStatusCode.localizedDescription, String(format: NSLocalizedString("Received HTTP status code %d.", comment: ""), 400))
    }

    func testInvalidStatusCodeError() {
        let expectation = self.expectation(description: "Invalid status code error")

        // Simulate a 404 Not Found response
        let url = URL(string: "https://dummy.com")!
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.response = response
        MockURLProtocol.responseData = Data()

        provider.request(mockEndpoint, responseType: MockResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                   let networkError = error as? CoinServiceProvider.NetworkError,
                   case .invalidStatusCode(let code) = networkError {
                    XCTAssertEqual(code, 404)
                    XCTAssertEqual(error.localizedDescription, "Received HTTP status code 404.")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected invalidStatusCode error")
                }
            }, receiveValue: { _ in
                XCTFail("Should not succeed with invalid status code")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }


}
