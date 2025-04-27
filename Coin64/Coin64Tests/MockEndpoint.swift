//
//  MockEndpoint.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import Foundation
@testable import Coin64


class MockURLProtocol: URLProtocol {
    static var responseData: Data?
    static var response: URLResponse?
    static var error: Error?
    
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        if let error = MockURLProtocol.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.responseData {
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}


struct MockEndpoint: EndpointProtocol {
    var url: URL?
    var httpMethod: String
    
    init(url: URL?, method: String) {
        self.url = url
        self.httpMethod = method
    }
}
