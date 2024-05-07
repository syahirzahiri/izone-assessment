//
//  ACControllerAPI.swift
//  Izone
//
//  Created by Ahmad Syahir on 07/05/2024.
//

import Foundation

let ROOT_URL = "https://api.izone.com.au/testsimplelocalcocb"

class ACControllerAPI{
    func getStatus(onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: ROOT_URL) else {
            onError("Invalid URL")
            return
        }
        
        var val = [String: Any]()
        var body = [String: Any]()
        body["Type"] = 1
        body["No"] = 0
        body["No1"] = 0
        val["iZoneV2Request"] = body
        
        guard let jsonString = val.toJSONString() else {
           return
        }
        
        let parameters = jsonString
        let postData =  parameters.data(using: .utf8)
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Handle the error
                if let networkError = error as? URLError, networkError.code == .notConnectedToInternet {
                    onError("NetworkError")
                } else {
                    onError("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                onError("No data received")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                onError("Invalid response")
                return
            }
            
            switch response.statusCode {
            case 200...299:
                // Handle the successful response
                if let responseString = String(data: data, encoding: .utf8) {
                    onSuccess(responseString)
                } else {
                    onError("Failed to parse response")
                }
            case 400...499:
                // Handle client errors
                if let errorData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let errorMessage = errorData["data"] as? String {
                    onError(errorMessage)
                } else {
                    onError("Invalid client error response")
                }
            case 500...599:
                // Handle server errors
                if let errorData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let errorMessage = errorData["message"] as? String {
                    onError(errorMessage)
                } else {
                    onError("Invalid server error response")
                }
            default:
                onError("Unexpected response status code: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
    
    func setACValue(val:String, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: ROOT_URL) else {
            onError("Invalid URL")
            return
        }

        let parameters = val
        let postData =  parameters.data(using: .utf8)
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Handle the error
                if let networkError = error as? URLError, networkError.code == .notConnectedToInternet {
                    onError("NetworkError")
                } else {
                    onError("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                onError("No data received")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                onError("Invalid response")
                return
            }
            
            switch response.statusCode {
            case 200...299:
                // Handle the successful response
                if let responseString = String(data: data, encoding: .utf8) {
                    onSuccess(responseString)
                } else {
                    onError("Failed to parse response")
                }
            case 400...499:
                // Handle client errors
                if let errorData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let errorMessage = errorData["data"] as? String {
                    onError(errorMessage)
                } else {
                    onError("Invalid client error response")
                }
            case 500...599:
                // Handle server errors
                if let errorData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let errorMessage = errorData["message"] as? String {
                    onError(errorMessage)
                } else {
                    onError("Invalid server error response")
                }
            default:
                onError("Unexpected response status code: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
    

}

