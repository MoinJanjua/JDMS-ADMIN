//
//  ApiCLint.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 19/02/2026.
//

import Foundation
import UIKit

class APIClient {
    
    static let shared = APIClient() // Singleton instance
    let baseURL = "https://jdms.bsite.net"
    
    private init() {}
    
    func registerUser(params: RegisterRequest, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Account/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch let decodingError as DecodingError {
                    // This will print the exact key that failed
                    print("❌ Decoding Error: \(decodingError)")
                    completion(.failure(decodingError))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    
    func loginUser(params: LoginRequest, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Account/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("❌ Login Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func logoutUser(completion: @escaping (Result<LogoutResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Account/logout") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // 1. Check if data is nil or empty (0 bytes)
                guard let data = data, !data.isEmpty else {
                    // If it's empty but the HTTP status is 200, it's a success!
                    let successResponse = LogoutResponse(isSuccess: true, message: "Logged out", errors: nil)
                    completion(.success(successResponse))
                    return
                }
                
                // 2. If data exists, try to decode it
                do {
                    let decodedResponse = try JSONDecoder().decode(LogoutResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    // If decoding fails but we have data, print it to see what the server sent
                    let rawString = String(data: data, encoding: .utf8) ?? "Non-text data"
                    print("❌ Logout Data Received but failed to decode: \(rawString)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    
    
    // MARK: - Ameer Messages APIs
    
    // 1. Upload the Image File
    func uploadTempImage(image: UIImage, messageType: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/AmeerMessages/upload-temp-image") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // --- 1. ADD AUTHORIZATION HEADER ---
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"MessageType\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(messageType)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"File\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // --- 2. CHECK STATUS CODE ---
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if statusCode == 401 {
                    completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: Token expired"])))
                    return
                }
                
                guard let data = data, !data.isEmpty else {
                    completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned empty response"])))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ImageUpload_Response.self, from: data)
                    completion(.success(decodedResponse.imageUrl))
                } catch {
                    // If decoding fails, check if the server sent a plain error message
                    if let serverMsg = String(data: data, encoding: .utf8) {
                        print("❌ Server Response: \(serverMsg)")
                        completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: serverMsg])))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    // 2. Post the Final Message
    func sendAmeerMessage(params: AmeerMessageRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/AmeerMessages") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                // If 200 OK, we assume success
                completion(.success(true))
            }
        }.resume()
    }
    
    
    func patchAmeerMessage(id: Int, params: AmeerMessageData, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/AmeerMessages/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        // Set the specific Content-Type required by your API
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        // Add the Token
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(params)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if statusCode == 200 {
                    completion(.success(true))
                } else {
                    // Handle 401 or other server errors
                    if statusCode == 401 {
                        let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                        completion(.failure(authError))
                    } else {
                        let serverError = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server Error: \(statusCode)"])
                        completion(.failure(serverError))
                    }
                }
            }
        }.resume()
    }
    
    
    // MARK: - Ameer Messages Detail & Delete
    
    // 1. Get Message Record
    func getAmeerMessage(id: Int64, completion: @escaping (Result<AmeerMessageData, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/AmeerMessages/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        // --- ADD THIS PART ---
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async{
                
                guard let httpResponse = response as? HTTPURLResponse else { return }
                if httpResponse.statusCode == 401 {
                    print("🚫 Unauthorized: Token is missing or expired.")
                    let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                    completion(.failure(authError))
                    return
                }
            
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else { return }
            
           
                do {
                    // 1. Decode the wrapper
                    let serverResponse = try JSONDecoder().decode(AmeerMessageResponse.self, from: data)
                    
                    // 2. Extract the actual data object
                    if let actualRecord = serverResponse.data {
                        completion(.success(actualRecord))
                    } else {
                        let noDataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Message not found"])
                        completion(.failure(noDataError))
                    }
                } catch {
                    print("❌ Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // 2. Delete Message Record
    func deleteAmeerMessage(id: Int64, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/AmeerMessages/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                
                // Check if status code is 200
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(.success(true))
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete"])
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func getAllDistricts(completion: @escaping (Result<[District], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Districts/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        // Add Token
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Prepare Body (defaulting to get all)
        let body = DistrictRequest(
            paginationRequest: PaginationRequest(pageNumber: 1, pageSize: 100, sortDirection: "Asc"),
            filters: DistrictFilters(searchTerm: "", name: "", code: "")
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(DistrictResponse.self, from: data)
                    completion(.success(decodedResponse.data ?? []))
                } catch {
                    print("❌ District Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func getConstituencies(districtId: Int? = nil, completion: @escaping (Result<[Constituency2], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Constituencies/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Prepare Body
        // Setting districtId to 0 or nil depending on how your backend handles "All"
        let filters = ConstituencyFilters(
            searchTerm: "",
            name: "",
            code: "",
            districtId: districtId ?? 0
        )
        
        let body = ConstituencyRequest(
            paginationRequest: PaginationRequest(pageNumber: 1, pageSize: 1000, sortDirection: "Asc"),
            filters: filters
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ConstituencyResponse.self, from: data)
                    completion(.success(decodedResponse.data ?? []))
                } catch {
                    print("❌ Constituency Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func getUnionCouncils(constituencyId: Int? = nil, completion: @escaping (Result<[UnionCouncil2], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/UnionCouncils/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        // Add Authorization Token
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Setup Filters
        let filters = UCFilters(
            searchTerm: "",
            name: "",
            code: "",
            constituencyId: constituencyId ?? 0
        )
        
        let body = UCRequest(
            paginationRequest: PaginationRequest(pageNumber: 1, pageSize: 1000, sortDirection: "Asc"),
            filters: filters
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(UCResponse.self, from: data)
                    completion(.success(decodedResponse.data ?? []))
                } catch {
                    print("❌ UC Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    
    func getWards(unionCouncilId: Int? = nil, completion: @escaping (Result<[Ward2], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Wards/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Setup Filters
        let filters = WardFilters(
            searchTerm: "",
            name: "",
            code: "",
            unionCouncilId: unionCouncilId ?? 0
        )
        
        let body = WardRequest(
            paginationRequest: PaginationRequest(pageNumber: 1, pageSize: 1000, sortDirection: "Asc"),
            filters: filters
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(WardResponse.self, from: data)
                    completion(.success(decodedResponse.data ?? []))
                } catch {
                    print("❌ Ward Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func saveMember(params: MemberRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Members") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(MemberSaveResponse.self, from: data)
                    
                    if decodedResponse.isSuccess {
                        // Send back the success message from the server
                        completion(.success(decodedResponse.message ?? "Member Created Successfully"))
                    } else {
                        // Handle case where server returns 200 but isSuccess is false
                        let serverMsg = decodedResponse.message ?? "Unknown Error"
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: serverMsg])))
                    }
                } catch {
                    // If decoding fails, it might be a validation error string
                    let rawError = String(data: data, encoding: .utf8) ?? "Decoding Error"
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: rawError])))
                }
            }
        }.resume()
    }
    
    
    func uploadMemberImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Members/upload-temp-image") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add Token
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"File\"; filename=\"member_image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 401 {
                print("🚫 Unauthorized: Token is missing or expired.")
                let authError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])
                completion(.failure(authError))
                return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
                    if let imageId = decodedResponse.data?.tempImageId {
                        completion(.success(imageId)) // This will now send just the UUID
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "ID not found in response"])))
                    }
                } catch {
                    print("❌ Image Upload Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func getDesignations(completion: @escaping (Result<[Designation], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Designations/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = DesignationRequest(
            paginationRequest: PaginationRequest(pageNumber: 1, pageSize: 100, sortDirection: "Asc"),
            filters: DesignationFilters(title: nil, urduTitle: nil, level: nil, responsibilities: nil, isActive: true)
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                // 1. Handle Unauthorized immediately
                if statusCode == 401 {
                    let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                    completion(.failure(unauthError)); return
                }
                
                guard let data = data, !data.isEmpty else {
                    let emptyError = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned no data (Status: \(statusCode))"])
                    completion(.failure(emptyError)); return
                }
                
                // 2. If status is not 200, try to parse the server's error message
                if !(200...299).contains(statusCode) {
                    if let serverErrorMessage = String(data: data, encoding: .utf8) {
                        let serverError = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: serverErrorMessage])
                        completion(.failure(serverError))
                    } else {
                        completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server Error: \(statusCode)"])))
                    }
                    return
                }
                
                // 3. Finally, try to decode success data
                do {
                    let decodedResponse = try JSONDecoder().decode(DesignationResponse.self, from: data)
                    completion(.success(decodedResponse.data ?? []))
                } catch {
                    print("❌ Decoding Failure. Raw Data: \(String(data: data, encoding: .utf8) ?? "Empty")")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    
    func getAllMembers(filters: MemberFilters, page: Int, size: Int, completion: @escaping (Result<[Member], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Members/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = MemberListRequest(
            paginationRequest: PaginationRequest(pageNumber: page, pageSize: size, sortDirection: "Asc"),
            memberFilters: filters
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            //
            //            if let jsonString = String(data: data!, encoding: .utf8) {
            //                          print("📦 Manufacturers Response: \(jsonString)")
            //                     }
            
            // 1. Capture the HTTP Response
            let httpResponse = response as? HTTPURLResponse
            
            DispatchQueue.main.async {
                // 2. Check for 401 Unauthorized
                if httpResponse?.statusCode == 401 {
                    let sessionError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Your session has expired. Please login again."])
                    completion(.failure(sessionError))
                    return
                }
                
                if let error = error { completion(.failure(error)); return }
                
                guard let data = data, !data.isEmpty else {
                    let emptyError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned no data."])
                    completion(.failure(emptyError))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(MemberListResponse.self, from: data)
                    completion(.success(decodedResponse.data ?? []))
                } catch {
                    // If decoding fails, provide a cleaner error than 'dataCorrupted'
                    let parseError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to read server data. Please try again."])
                    completion(.failure(parseError))
                }
            }
        }.resume()
    }
    
    
    func deleteMember(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Members/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            
            
            DispatchQueue.main.async {
                // Check for session expiry
                if httpResponse?.statusCode == 401 {
                    AppNavigator.navigateToLogin()
                    return
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Success if status code is 200
                if httpResponse?.statusCode == 200 {
                    completion(.success(true))
                } else {
                    let serverError = NSError(domain: "", code: httpResponse?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Failed to delete member."])
                    completion(.failure(serverError))
                }
            }
        }.resume()
    }
    
    
    func fetchAllDawat(page: Int, completion: @escaping (Result<[DawatRecord], Error>) -> Void) {
        // 1. Ensure the URL is using the production/live path if needed
        guard let url = URL(string: "https://jdms.bsite.net/api/Dawat/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // 2. IMPORTANT: Change Content-Type to match what the server expects
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        // 3. ADD AUTHENTICATION
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let params = DawatFetchRequest(
            paginationRequest: DawatPager(pageNumber: page, pageSize: 50),
            filters: DawatFilters()
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Debugging logs
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            // 1. Handle Unauthorized immediately
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
//            
//            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
//                print("📦 Server Response: \(jsonString)")
//            }
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoded = try JSONDecoder().decode(DawatFetchResponse.self, from: data)
                    completion(.success(decoded.data ?? []))
                } catch {
                    print("❌ Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func addDawat(params: DawatPostRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Dawat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(params)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
//            if let jsonString = String(data: data!, encoding: .utf8) {
//                print("📦 addDawat Response: \(jsonString)")
//            }
//            
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if statusCode == 401 {
                    let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                    completion(.failure(unauthError)); return
                }
                
                if statusCode == 200 || statusCode == 201 {
                    completion(.success(true))
                } else {
                    // --- NEW: Try to parse the specific error message from the server ---
                    if let data = data {
                        do {
                            let errorResult = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                            // Get the first error description or the main message
                            let serverMessage = errorResult.errors?.first?.description ?? errorResult.message ?? "Unknown Error"
                            
                            let customError = NSError(domain: "", code: statusCode,
                                                      userInfo: [NSLocalizedDescriptionKey: serverMessage])
                            completion(.failure(customError))
                        } catch {
                            // Fallback if decoding fails
                            let fallbackError = NSError(domain: "", code: statusCode,
                                                        userInfo: [NSLocalizedDescriptionKey: "Status \(statusCode): Check your input."])
                            completion(.failure(fallbackError))
                        }
                    }
                }
            }
        }.resume()
    }
    
    
    func uploadDawatPDF(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Dawat/upload-temp-pdf") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Create body
        var body = Data()
        let filename = fileURL.lastPathComponent
        let mimeType = "application/pdf"
        
        if let fileData = try? Data(contentsOf: fileURL) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"File\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        }
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
//            if let data = data,
//               let jsonString = String(data: data, encoding: .utf8) {
//                print("📦 uploadDawatPDF: \(jsonString)")
//            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { return }
                do {
                    let response = try JSONDecoder().decode(PDFUploadResponse.self, from: data)
                    if response.isSuccess,
                       let path = response.data?.tempPdfUrl {
                        completion(.success(path))
                    } else {
                        let error = NSError(domain: "",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: response.message ?? "Upload failed"])
                        completion(.failure(error))
                    }
                } catch { completion(.failure(error)) }
            }
        }.resume()
    }
    
    
    func addEvent(params: EventPostRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Events") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(params)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                // Usually 200 or 201 for successful creation
                if statusCode == 200 || statusCode == 201 {
                    completion(.success(true))
                } else {
                    let serverError = NSError(domain: "", code: statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to save event. Status: \(statusCode)"])
                    completion(.failure(serverError))
                }
            }
        }.resume()
    }
    
    
    func fetchEvents(pageNumber: Int, pageSize: Int, completion: @escaping (Result<EventDataWrapper, Error>) -> Void) {
        let urlString = "\(baseURL)/api/Events?PageNumber=\(pageNumber)&PageSize=\(pageSize)&SortDirection=Desc"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(EventFetchResponse.self, from: data)
                if decodedResponse.isSuccess {
                    completion(.success(decodedResponse.data))
                } else {
                    let serverError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message ?? "Unknown error"])
                    completion(.failure(serverError))
                }
            } catch {
                print("Decoding Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // APIClient.swift additions

    // DELETE Event
    func deleteEvent(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Events/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.success(statusCode == 200))
            }
        }.resume()
    }

    // UPDATE Event (PATCH)
    func updateEvent(id: Int, params: EventRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Events/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let jsonData = try JSONEncoder().encode(params)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.success(statusCode == 200))
            }
        }.resume()
    }
    
    
    func addDesignation(params: DesignationPostRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Designations") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if statusCode == 200 || statusCode == 201 {
                    completion(.success(true))
                } else {
                    // Parse detailed error using our APIErrorResponse model
                    if let data = data, let errorResult = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                        let msg = errorResult.errors?.first?.description ?? errorResult.message ?? "Error"
                        completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: msg])))
                    } else {
                        completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server Error: \(statusCode)"])))
                    }
                }
            }
        }.resume()
    }
    
    
    func deleteDesignation(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(baseURL)/api/Designations/\(id)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if statusCode == 200 || statusCode == 204 {
                    completion(.success(true))
                } else {
                    // Use your existing error handling logic here
                    completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete record."])))
                }
            }
        }.resume()
    }
    
    
    func updateDesignation(id: Int, params: Designation, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Designations/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if statusCode == 200 || statusCode == 204 {
                    completion(.success(true))
                } else {
                    completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Update failed (Status: \(statusCode))"])))
                }
            }
        }.resume()
    }
    
    
    
    func getAllVoters(page: Int, filters: VoterFilters, completion: @escaping (Result<VoterResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/MemberVotingInfo/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        // Authorization
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let pagination = PaginationRequest1(pageNumber: page, pageSize: 100)
        let body = VoterRequest(paginationRequest: pagination, filters: filters)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoded = try JSONDecoder().decode(VoterResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    print("❌ Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func addMemberVotingInfo(params: AddVoterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/MemberVotingInfo") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        // Add Token
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(AddVoterResponse.self, from: data)
                    if decodedResponse.isSuccess {
                        completion(.success(decodedResponse.message ?? "Voter info added successfully"))
                    } else {
                        let serverError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message ?? "Failed to add voter info"])
                        completion(.failure(serverError))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func searchMembers(query: String, completion: @escaping (Result<[Member], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Members/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Using your existing structs for better type safety
        let pagination = PaginationRequest(pageNumber: 1, pageSize: 20, sortDirection: "Asc")
        let filters = MemberFilters(searchTerm: query)
        let searchBody = MemberListRequest(paginationRequest: pagination, memberFilters: filters)
        
        do {
            request.httpBody = try JSONEncoder().encode(searchBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            // Fix for the Trailing Closure error: explicitly handle the thread switch
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else { return }
            
            do {
                // FIXED: Using MemberListResponse (the name you actually defined)
                let response = try JSONDecoder().decode(MemberListResponse.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(response.data ?? []))
                }
            } catch {
                print("❌ Search Decoding Error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    
    //Feedback
    
    func getAllFeedback(page: Int, type: Int, completion: @escaping (Result<[FeedbackItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/FeedbackComplaint/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let pagination = PaginationRequest2(pageNumber: page, pageSize: 20, sortDirection: "Desc")
        let filters = FeedbackFilters(type: type) // Filter by Complaint or Suggestion
        let body = FeedbackRequest(paginationRequest: pagination, filters: filters)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(FeedbackListResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.data ?? []))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    
    func fetchAllMemberVotes(page: Int, filters: MemberVoteFilters, completion: @escaping (Result<[MemberVoteRecord], Error>) -> Void) {
        guard let url = URL(string:  "\(baseURL)/api/MemberVotingInfo/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add your Bearer Token here
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let paging = MemberVotePaging(pageNumber: page, pageSize: 50, afterCursor: 0, beforeCursor: 0, sortDirection: "Asc")
        let body = MemberVoteRequest(paginationRequest: paging, filters: filters)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            // Error handling for 500 or 401 statuses
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let serverError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server Error: \(httpResponse.statusCode)"])
                completion(.failure(serverError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(MemberVoteBaseResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.data ?? []))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // MARK: - Update Record
    func updateVoterRecord(record: MemberVoteUpdateRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/MemberVotingInfo/\(record.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(record)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            // Usually, 200 or 204 means success
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async { completion(.success(true)) }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Update failed"])
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // MARK: - Delete Record
    func deleteVoterRecord(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/MemberVotingInfo/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async { completion(.success(true)) }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Delete failed"])
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    
    func fetchAllComplaints(page: Int, completion: @escaping (Result<[ComplaintRecord], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/FeedbackComplaint/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Using the new prefixed names
        let paging = ComplaintPaging(pageNumber: page, pageSize: 50, afterCursor: 0, beforeCursor: 0, sortDirection: "Asc")
        let filters = ComplaintFilters()
        let body = ComplaintRequest(paginationRequest: paging, filters: filters)

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            
           
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(ComplaintBaseResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.data ?? []))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func fetchMemberDetails(memberId: Int, completion: @escaping (Result<MemberVoteDetail, Error>) -> Void) {
        // Assuming your endpoint follows this pattern: /api/Member/GetById/{id}
        guard let url = URL(string: "\(baseURL)/api/Member/\(memberId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    // This uses the MemberVoteDetail model we created earlier
                    let decoded = try JSONDecoder().decode(MemberVoteDetail.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    
    func getUserProfile(id: Int, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Users/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(UserResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // MARK: - Delete Dawat
    func deleteDawat(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Dawat/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                
                guard let data = data else { return }
                
                do {
                    // Parse the response to check the 'isSuccess' field
                    let result = try JSONDecoder().decode(DawatFetchResponse.self, from: data)
                    completion(.success(result.isSuccess))
                } catch {
                    // If decoding fails, fallback to status code check
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    completion(.success(statusCode == 200))
                }
            }
        }.resume()
    }

    // MARK: - Edit Dawat
    func updateDawat(item: DawatRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Dawat/\(item.id)") else { return }
        var request = URLRequest(url: url)
        
        // CHANGE THIS from "PUT" to "PATCH"
        request.httpMethod = "PATCH"
        
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept") // Added to match your curl
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let jsonData = try JSONEncoder().encode(item)
            request.httpBody = jsonData
            
            // Debugging: Print exactly what you are sending
            if let bodyString = String(data: jsonData, encoding: .utf8) {
                print("📤 Sending Body: \(bodyString)")
            }
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                // Check for 200 OK
                completion(.success(statusCode == 200))
            }
        }.resume()
    }

    
    
    func fetchNotifications(pageNumber: Int, pageSize: Int, completion: @escaping (Result<NotificationResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Notifications/GetAll") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Construct the Body
        // Construct the Body
        let body = NotificationRequest(
            // Change PaginationDetails to PaginationRequestBody here
            paginationRequest: PaginationRequestBody(
                pageNumber: pageNumber,
                pageSize: pageSize,
                afterCursor: 0,
                beforeCursor: 0,
                sortDirection: "Desc"
            ),
            filters: NotificationFilters(title: "", notifyDate: "")
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(NotificationResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
 
    func addNotification(params: NotificationPostRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
            guard let url = URL(string: "\(baseURL)/api/Notifications") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = UserDefaults.standard.string(forKey: "userToken") {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                request.httpBody = try JSONEncoder().encode(params)
            } catch {
                completion(.failure(error))
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if statusCode == 401 {
                    let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                    completion(.failure(unauthError)); return
                }
                
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)); return }
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    completion(.success(statusCode == 200 || statusCode == 201))
                }
            }.resume()
        }
    
    
    // DELETE Notification
    func deleteNotification(id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Notifications/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.success(statusCode == 200))
            }
        }.resume()
    }

    // UPDATE Notification (PATCH)
    func updateNotification(id: Int, params: NotificationRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Notifications/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let bodyString = String(data: data!, encoding: .utf8) {
                print("📤 Sending Body: \(bodyString)")
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 401 {
                let unauthError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])
                completion(.failure(unauthError)); return
            }
            
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.success(statusCode == 200))
            }
        }.resume()
    }
    
    
    
    // GET User Profile
    func fetchUserProfile(userId: Int, completion: @escaping (Result<UserProfileResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Users/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let bodyString = String(data: data!, encoding: .utf8) {
                print("📤 fetchUserProfile Body: \(bodyString)")
            }
            
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // PATCH User Profile
    func updateUserProfile(userId: Int, params: UserUpdateRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/Users/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.success(statusCode == 200))
            }
        }.resume()
    }
    
    
    func updateMember(id: Int, memberData: MemberUpdateRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(baseURL)/api/Members/\(id)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // Or "PATCH" depending on your exact Swagger spec
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")

        // Authorization
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encoding Body
        do {
            let jsonData = try JSONEncoder().encode(memberData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                // Usually 200 (OK) or 204 (No Content) means success for updates
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(true))
                } else if httpResponse.statusCode == 401 {
                    completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session Expired"])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Update failed"])))
                }
            }
        }.resume()
    }
    
    
}


