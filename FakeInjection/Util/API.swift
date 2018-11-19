//
//  API.swift
//  FakeInjection
//
//  Created by Kohei Oyama on 2017/10/19.
//  Copyright © 2017年 Kohei Oyama. All rights reserved.
//

import UIKit

import APIKit
import SwiftyJSON

protocol FakeInjectionRequest: Request {

}

enum PlaceURL: String {
    case lab = "http://192.168.11.123:8000"
    case home = "http://192.168.11.5:8000"
    case uTokyo = "http://10.213.200.206:8000"
    case manual = ""
}

extension FakeInjectionRequest {
    var baseURL: URL {
        return URL(string: "http://192.168.11.5:8000")!
    }
    /*var baseURL: URL {
        get {
            return URL(string: PlaceURL.lab.rawValue)!
        }
        set {
            print(newValue)
        }
    }*/
}

struct GetConditionsRequest: FakeInjectionRequest {
    typealias Response = Conditions

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "start"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let result = Conditions(json: JSON(object)) else {
            print("error API")
            throw ResponseError.unexpectedObject(object)
        }
        return result
    }
}

struct Conditions {
    let isModeReverse: Bool
    let time: Int

    init?(json: JSON) {
        guard let isModeReverse: Bool = json["isModeReverse"].bool else { return nil }
        guard let time: Int = json["time"].int else { return nil }

        self.isModeReverse = isModeReverse
        self.time = time
    }
}
