//
//  Modals.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 29/12/2025.
//


import UIKit
import Foundation

struct MenuItem {
    let title: String
    let imageName: String
}


enum MenuItemType: CaseIterable {
    case dashboard, members, chat, dawat, regions, ijtimaat, designations, notifications, forms, system

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .members: return "Members"
        case .chat: return "Chat"
        case .dawat: return "Dawat & Tarbiyah"
        case .regions: return "Regions"
        case .ijtimaat: return "Ijtimaat"
        case .designations: return "Designations"
        case .notifications: return "Notifications"
        case .forms: return "Forms"
        case .system: return "System"
        }
    }

    var viewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch self {
        case .dashboard:
            return storyboard.instantiateViewController(withIdentifier: "DashboardViewController")

        case .members:
            return storyboard.instantiateViewController(withIdentifier: "MembersViewController")

        case .chat:
            return storyboard.instantiateViewController(withIdentifier: "ChatViewController")

        case .dawat:
            return storyboard.instantiateViewController(withIdentifier: "DawatViewController")

        case .regions:
            return storyboard.instantiateViewController(withIdentifier: "RegionsViewController")

        case .ijtimaat:
            return storyboard.instantiateViewController(withIdentifier: "IjtimaatViewController")

        case .designations:
            return storyboard.instantiateViewController(withIdentifier: "DesignationsViewController")

        case .notifications:
            return storyboard.instantiateViewController(withIdentifier: "NotificationsViewController")

        case .forms:
            return storyboard.instantiateViewController(withIdentifier: "FormsViewController")

        case .system:
            return storyboard.instantiateViewController(withIdentifier: "SystemViewController")
        }
    }
}



//members


// MARK: - Profile Section
struct ProfileSection {
    let sectionTitle: String
    let fields: [ProfileField]
}

// MARK: - Profile Field
struct ProfileField {
    
    enum FieldType {
        case text
        case number
        case date
        case dropdown
    }
    
    let title: String
    let urduTitle: String
    let type: FieldType
    
}

// dawat o
struct DawatPDF {
    let title: String
    let fileName: String
    let icon: String
    let uploadDate: String
    let fileSize: String
    let category: String
    let description: String
}


// Regiosn

struct Ward {
    let id: Int
    let name: String
}

struct UnionCouncil {
    let id: Int
    let name: String
    let wards: [Ward]
}

struct Constituency {
    let id: Int
    let name: String
    let unionCouncils: [UnionCouncil]
}

struct Affiliation {
    let id: Int
    let name: String
    let constituencies: [Constituency]
}


//events

// Individual Event Object
struct EventRecord: Codable {
    let id: Int
    let title: String?
    let description: String?
    let category: String?
    let organizedBy: String?
    let location: String?
    let startDate: String?
    let endDate: String?
    let speaker: String?
    let isActive: Bool
    let createdAt: String?
}

// Pagination Details
struct EventPagination: Decodable {
    let pageSize: Int
    let itemCount: Int
    let totalRecords: Int
    let currentPage: Int
    let totalPages: Int
    let hasNextPage: Bool
}

// Inner Data Wrapper
struct EventDataWrapper: Decodable {
    let data: [EventRecord]
    let paginationResponseDetails: EventPagination
}

// Top Level Response
struct EventFetchResponse: Decodable {
    let data: EventDataWrapper
    let isSuccess: Bool
    let message: String?
}


struct AppNotification {
    let title: String
    let message: String
    let date: Date
    var isRead: Bool
}



struct QuestionModal {
    let questionTitle: String
    let formType: String
    let questionOrder: Int
    let questionType: String
}


struct Complaint {
    var type: String
    var message: String
    var date: String
    var submittedBy: String
}


struct VoterList {
    var name: String
    var FatName: String
    var Cnic: String
    var VoterID: String
    var pollingStation: String
    var blockCode: String
    var halqaNo: String
   
}



// MODALS


// MARK: - Request Model  SIGNUP
struct RegisterRequest: Encodable {
    let fullName, email, phoneNumber, password, confirmPassword: String
}

// MARK: - Response Models
struct APIResponse: Decodable {
    let isSuccess: Bool
    let message: String?
    let errors: [APIError]?
    // Use [APIError]? here too if the server returns them the same way
    let serializableErrors: [APIError]?
}

struct RegisterData: Decodable {
    let userId, userName, email, name, role, message, registeredAt: String
}

struct APIErrorDetail: Decodable {
    let errorCode, fieldName, description: String?
}

struct APIError: Decodable {
    let errorCode: Int?           // Changed from String to Int
    let errorCodeName: String?
    let description: String?
    let fieldName: String?        // Keep optional as it might not be in the error
    let timestamp: String?
}


// MARK: - Login Request
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

// MARK: - Login Response
struct LoginResponse: Decodable {
    let isSuccess: Bool
    let message: String?
    let errors: [APIError]?
    let data: LoginData?
}

struct LoginData: Decodable {
    let id: String?
    let userName: String?
    let email: String?
    let token: String?
    let refreshToken: String?
    let roles: [String]?
}


// MARK: - LOG OUT
struct LogoutResponse: Decodable {
    let isSuccess: Bool
    let message: String?
    let errors: [APIError]?
}


// MARK: - Ameer Message
struct AmeerMessageRequest: Codable {
    let messageText: String?
    let imageUrl: String?
    let id: Int64?

    enum CodingKeys: String, CodingKey {
        // Map the Swift name (left) to the Server JSON name (right)
        case messageText = "messageText" // If server sends "MessageText", change right side to "MessageText"
        case imageUrl = "imageUrl"       // If server sends "ImageUrl", change right side to "ImageUrl"
        case id = "id"
    }
}


struct ImageUpload_Response: Codable {
    let imageUrl: String
}


// MARK: - Ameer Message
struct AmeerMessageResponse: Codable {
    let data: AmeerMessageData?
    let isSuccess: Bool
    let message: String?
}

// This matches the inside of the "data" object
struct AmeerMessageData: Codable {
    let id: Int
    let messageText: String?
    let imageUrl: String?
    let isActive: Bool
}



struct DistrictRequest: Encodable {
    let paginationRequest: PaginationRequest
    let filters: DistrictFilters
}

struct PaginationRequest: Encodable {
    let pageNumber: Int
    let pageSize: Int
    let sortDirection: String // "Asc" or "Desc"
}

struct DistrictFilters: Encodable {
    let searchTerm: String?
    let name: String?
    let code: String?
}

// Response Models
struct DistrictResponse: Decodable {
    let isSuccess: Bool
    let data: [District]?
}

struct District: Decodable {
    let id: Int
    let name: String
    let code: String?
}


//Constitutions
struct ConstituencyRequest: Encodable {
    let paginationRequest: PaginationRequest
    let filters: ConstituencyFilters
}

struct ConstituencyFilters: Encodable {
    let searchTerm: String?
    let name: String?
    let code: String?
    let districtId: Int? // This is new
}

// Response Models
struct ConstituencyResponse: Decodable {
    let isSuccess: Bool
    let data: [Constituency2]?
}

struct Constituency2: Decodable {
    let id: Int
    let name: String
    let code: String?
    let districtId: Int?
    let districtName: String? // Usually APIs return the name too
}


// Response Models
struct UCRequest: Encodable {
    let paginationRequest: PaginationRequest
    let filters: UCFilters
}

struct UCFilters: Encodable {
    let searchTerm: String?
    let name: String?
    let code: String?
    let constituencyId: Int? // Filter by Constituency
}

// Response Models
struct UCResponse: Decodable {
    let isSuccess: Bool
    let data: [UnionCouncil2]?
}

struct UnionCouncil2: Decodable {
    let id: Int
    let name: String
    let code: String?
    let constituencyId: Int?
    let constituencyName: String?
}


struct ImageUploadResponse: Decodable {
    let isSuccess: Bool
    let data: ImageUploadData?
}

struct ImageUploadData: Decodable {
    let tempImageId: String
    let tempImageUrl: String
}


//Wards
struct WardRequest: Encodable {
    let paginationRequest: PaginationRequest
    let filters: WardFilters
}

struct WardFilters: Encodable {
    let searchTerm: String?
    let name: String?
    let code: String?
    let unionCouncilId: Int? // Filter by Union Council
}

// Response Models
struct WardResponse: Decodable {
    let isSuccess: Bool
    let data: [Ward2]?
}

struct Ward2: Decodable {
    let id: Int
    let name: String
    let code: String?
    let unionCouncilId: Int?
    let unionCouncilName: String?
}


// MemberRequest
struct MemberRequest: Encodable,Decodable {
    let fullname: String
    let urduName: String?
    let fatherName: String
    let cnic: String
    let email: String?
    let tempImageId: String?
    let phoneNumber: String
    let alternatePhoneNumber: String?
    let address: String
    let city: String
    let district: String // Note: API asks for District Name string AND DistrictId
    let village: String?
    let dateOfBirth: String // Format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let gender: String
    let maritalStatus: String
    let bloodGroup: String?
    let education: String
    let profession: String
    let skills: String?
    let referralName: String?
    let designationId: Int
    let districtId: Int
    let constituencyId: Int
    let unionCouncilId: Int
    let wardId: Int
    let membershipStatus: String
    let joiningDate: String
    let notes: String?
    let nameofLocalJamat: String?
    
}



//Members
struct MemberSaveResponse: Decodable {
    let isSuccess: Bool
    let message: String?
    let data: MemberSaveData?
}

struct MemberSaveData: Decodable {
    let memberId: Int
    let fullName: String
    let email: String?
}


//Desiginations

struct DesignationRequest: Encodable {
    let paginationRequest: PaginationRequest
    let filters: DesignationFilters
}

struct DesignationFilters: Encodable {
    let title: String?
    let urduTitle: String?
    let level: Int?
    let responsibilities: String?
    let isActive: Bool?
}

// Response Models
struct DesignationResponse: Decodable {
    let isSuccess: Bool
    let data: [Designation]?
}

struct Designation: Codable {
    let id: Int
    let title: String
    let urduTitle: String?
    let level: Int?
    let responsibilities: String?
}


//Members

struct MemberListRequest: Encodable {
    let paginationRequest: PaginationRequest
    let memberFilters: MemberFilters
}

struct MemberFilters: Encodable {
    var searchTerm: String?
    var fullName: String?
    var city: String?
    var email: String?
    var phone: String?
    var gender: String?
    var membershipStatus: String?
    var cnic: String?
    // Note: The API schema doesn't show district/education here,
    // but we can use searchTerm or city as fallbacks if needed.
}

struct MemberListResponse: Decodable {
    let isSuccess: Bool
    let data: [Member]? // Use the Member struct from your Add Member models
}

// Small helper struct for related objects
struct NameObject: Codable {
    let id: Int?
    let name: String?
    let title: String?
    
    var displayName: String {
            return title ?? name ?? "Unknown"
        }
}

struct DesiginationObject: Codable {
    let id: Int?
    let title: String?
}

struct Member: Codable {
    let id : Int?
    let fullName: String
    let urduName: String?
    let fatherName: String
    let cnic: String
    let email: String?
    let phoneNumber: String
    let alternatePhoneNumber: String?
    let address: String?
    let city: String
    let village: String?
    let education: String
    let profession: String?
    let gender: String?
    let maritalStatus: String?
    let joiningDate: String?
    let referralName:String?
    let membershipStatus: String?
    let nameofLocalJamat: String?
    let imageUrl: String? // Note: The JSON uses imageUrl for the list
    let dateOfBirth : String?
    // Nested Objects for Names
    let district: NameObject?
    let constituency: NameObject?
    let unionCouncil: NameObject?
    let ward: NameObject?
    let designation: NameObject? // Standardized naming
    let skills : String?
    let isActive : Bool?
    
    // IDs (Keeping these as Int? based on JSON)
    let districtId: Int?
    let constituencyId: Int?
    let unionCouncilId: Int?
    let wardId: Int?
    let designationId: Int?

    // CodingKeys to handle typos or mapping if necessary
    enum CodingKeys: String, CodingKey {
        case id ,fullName, urduName, fatherName, cnic, email, phoneNumber, alternatePhoneNumber
        case address, city, village, education, profession, gender,maritalStatus, joiningDate,referralName
        case membershipStatus, nameofLocalJamat, imageUrl, dateOfBirth ,district,isActive, constituency
        case unionCouncil, ward, districtId, constituencyId, unionCouncilId, wardId, designationId
        case designation = "designation",skills // Map this to whatever the server object key is
    }
}




//Dawat o Tarjihe
// 1. The Top Level Response
struct DawatFetchRequest: Encodable {
    let paginationRequest: DawatPager
    let filters: DawatFilters
}

struct DawatPager: Encodable {
    let pageNumber: Int
    let pageSize: Int
    let afterCursor: Int = 0  // Added
    let beforeCursor: Int = 0 // Added
    let sortDirection: String = "Asc" // Changed to Asc to match your curl
}

struct DawatFilters: Encodable {
    let title: String = ""    // Changed to non-optional empty string
    let category: String = "" // Changed to non-optional empty string
}

// Response Model
struct DawatFetchResponse: Decodable {
    let data: [DawatRecord]?
    let isSuccess: Bool
    let message: String?
}

struct DawatRecord: Codable {
    let id: Int
    let title: String?
    let shortDescription: String?
    let content: String?
    let category: String?
    let pdfUrl: String?
    let isActive : Bool?
}



//Add Dawat

struct DawatPostRequest: Encodable {
    let title: String
    let shortDescription: String
    let content: String
    let category: String
    let pdfUrl: String? // This will hold the path returned from the upload API
}

// Model for the PDF Upload response
struct PDFUploadResponse: Codable {
    let isSuccess: Bool
    let message: String?
    let data: PDFUploadData?
}

struct PDFUploadData: Codable {
    let tempPdfId: String?
    let tempPdfUrl: String?
}

struct APIErrorResponse: Decodable {
    let isSuccess: Bool
    let message: String?
    let errors: [ValidationError]?
}

struct ValidationError: Decodable {
    let description: String?
    let fieldName: String?
}


struct ServerErrorResponse: Decodable {
    let title: String?
    let detail: String?
    let status: Int?
    let type: String?
}



//AddEvents

struct EventPostRequest: Encodable {
    let title: String
        let startDate: String // Format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let endDate: String
        let description: String
        let category: String
        let organizedBy: String
        let location: String
        let speaker: String
}


// desigination
struct DesignationPostRequest: Encodable {
    let title: String
    let level: Int
    let urduTitle: String
    let responsibilities: String
}


//Voters

// MARK: - Voter Models
struct VoterRequest: Codable {
    let paginationRequest: PaginationRequest1
    let filters: VoterFilters
}

struct PaginationRequest1: Codable {
    var pageNumber: Int
    var pageSize: Int
    var afterCursor: Int = 0
    var beforeCursor: Int = 0
    var sortDirection: String = "Asc"
}

struct VoterFilters: Codable {
    var voterId: String? = ""
    var pollingStation: String? = ""
    var memberId: Int? = 0
    var blockCode: String? = ""
    var halqaNumber: String? = ""
    var memberFullName: String? = ""
    var memberCNIC: String? = ""
}

// MARK: - Response Models
struct VoterResponse: Codable {
    let data: [VoterDetail]
    let isSuccess: Bool
    let message: String?
    let paginationResponse: PaginationResponse?
}

struct VoterDetail: Codable {
    let id: Int
    let voterId: String?
    let pollingStation: String?
    let blockCode: String?
    let halqaNumber: String?
    let memberFullName: String?
    let memberCNIC: String?
    // Add any other fields returned in the "data" array
}

struct PaginationResponse: Codable {
    let totalRecords: Int
    let totalPages: Int
    let currentPage: Int
}


    //Add Voetrs
struct AddVoterRequest: Codable {
    let voterId: String
    let pollingStation: String
    let blockCode: String
    let halqaNumber: String
    let voteRegistrationDate: String // ISO8601 format
    let memberId: Int
}

struct AddVoterResponse: Codable {
    let isSuccess: Bool
    let message: String?
}



//Feedback Suggestions
// MARK: - Request Models
struct FeedbackRequest: Codable {
    let paginationRequest: PaginationRequest2
    let filters: FeedbackFilters
}

struct PaginationRequest2: Codable {
    var pageNumber: Int
    var pageSize: Int
    var afterCursor: Int? = 0
    var beforeCursor: Int? = 0
    var sortDirection: String? = "Asc"
}


struct FeedbackFilters: Codable {
    var type: Int? = 0 // 0: All, 1: Complaint, 2: Suggestion
    var priority: String? = ""
    var category: String? = ""
    var subject: String? = ""
}

// MARK: - Response Models
struct FeedbackListResponse: Codable {
    let isSuccess: Bool
    let message: String?
    let data: [FeedbackItem]?
    let paginationResponse: PaginationResponse?
}

struct FeedbackItem: Codable {
    let id: Int
    let type: Int // 1 for Complaint, 2 for Suggestion
    let category: String?
    let subject: String?
    let description: String?
    let priority: String?
    let status: String?
    let createdAt: String?
    let memberFullName: String?
}


// MARK: - Voters List
struct MemberVoteRequest: Codable {
    let paginationRequest: MemberVotePaging
    let filters: MemberVoteFilters
}

struct MemberVotePaging: Codable {
    let pageNumber: Int
    let pageSize: Int
    let afterCursor: Int?
    let beforeCursor: Int?
    let sortDirection: String
}

struct MemberVoteFilters: Codable {
    var voterId: String? = nil
    var pollingStation: String? = nil
    var memberId: Int? = nil
    var blockCode: String? = nil
    var halqaNumber: String? = nil
    var memberFullName: String? = nil
    var memberCNIC: String? = nil
}

// MARK: - RESPONSE MODELS
struct MemberVoteBaseResponse: Codable {
    let isSuccess: Bool
    let message: String?
    let data: [MemberVoteRecord]?
    let paginationResponse: MemberVotePagingResponse?
}

struct MemberVotePagingResponse: Codable {
    let pageSize: Int?
    let itemCount: Int?
    let totalRecords: Int?
    let currentPage: Int?
    let totalPages: Int?
    let firstCursor: Int?
    let lastCursor: Int?
    let hasNextPage: Bool?
    let hasPreviousPage: Bool?
    let mode: Int?
    let sortDirection: Int?
}

struct MemberVoteRecord: Codable {
    let id: Int
    let voterId: String?
    let pollingStation: String?
    let blockCode: String?
    let halqaNumber: String?
    let voteRegistrationDate: String?
    let memberId: Int?
    let member: MemberVoteDetail?
}

struct MemberVoteDetail: Codable {
    let id: Int
    let fullName: String?
    let urduName: String?
    let fatherName: String?
    let cnic: String?
    let email: String?
    let phoneNumber: String?
    let alternatePhoneNumber: String?
    let referralName: String?
    let village: String?
    let address: String?
    let city: String?
    let districtName: String?
    let dateOfBirth: String?
    let gender: String?
    let maritalStatus: String?
    let bloodGroup: String?
    let education: String?
    let profession: String?
    let skills: String?
    let districtId: Int?
    let constituencyId: Int?
    let unionCouncilId: Int?
    let wardId: Int?
    let designationId: Int?
    let nameofLocalJamat: String?
    let joiningDate: String?
    let membershipStatus: String?
    let isActive: Bool?
    let notes: String?
    let imageUrl: String?
    
    // Nested Location Objects
    let constituency: MemberVoteLocation?
    let unionCouncil: MemberVoteLocation?
    let ward: MemberVoteLocation?
}

struct MemberVoteLocation: Codable {
    let id: Int?
    let name: String?
    let urduName: String?
    let code: String?
    let description: String?
    let isActive: Bool?
    let createdAt: String?
}



//Edit voting
struct MemberVoteUpdateRequest: Codable {
    let id: Int
    var voterId: String
    var pollingStation: String
    var blockCode: String
    var halqaNumber: String
    var voteRegistrationDate: String // Format: "2026-02-25T20:52:39.613Z"
}


//Feedback

// MARK: - Feedback Models
// MARK: - Complaint Request Models
struct ComplaintRequest: Codable {
    let paginationRequest: ComplaintPaging
    let filters: ComplaintFilters
}

struct ComplaintPaging: Codable {
    let pageNumber: Int
    let pageSize: Int
    let afterCursor: Int
    let beforeCursor: Int
    let sortDirection: String
}

struct ComplaintFilters: Codable {
    var voterId: String? = nil
    var pollingStation: String? = nil
    var memberId: Int? = nil
    var blockCode: String? = nil
    var halqaNumber: String? = nil
    var memberFullName: String? = nil
    var memberCNIC: String? = nil
}

// MARK: - Complaint Response Models
struct ComplaintBaseResponse: Codable {
    let isSuccess: Bool
    let message: String?
    let data: [ComplaintRecord]?
    let paginationResponse: ComplaintPagingResponse?
}

struct ComplaintRecord: Codable {
    let id: Int
    let subject: String?
    let type: String?
    let priority: String?
    let details: String?
    let category: String?
    let memberId: Int?      // This maps to 'createdBy' in your JSON
    let createdAt: String?  // Added this for the date label
    var senderName: String? // Local property to store the fetched name

    enum CodingKeys: String, CodingKey {
        case id, subject, type, priority, details, category, createdAt
        case memberId = "createdBy" // Tells Swift that 'memberId' is 'createdBy' in JSON
    }
}

struct ComplaintPagingResponse: Codable {
    let pageSize: Int?
    let itemCount: Int?
    let totalRecords: Int?
    let currentPage: Int?
    let totalPages: Int?
    let hasNextPage: Bool?
    let hasPreviousPage: Bool?
}


struct UserResponse: Codable {
    let data: UserData?
    let isSuccess: Bool
}

struct UserData: Codable {
    let id: Int
    let name: String
    let userName: String
}


enum EventStatus: String {
    case ongoing = "Ongoing"
    case upcoming = "Upcoming"
    case past = "Past"
    case today = "Today"
    
    var color: UIColor {
        switch self {
        case .ongoing: return .systemOrange
        case .upcoming: return .systemBlue
        case .past: return .systemGray
        case .today: return .systemGreen
        }
    }
}


//NotificationRequest
// MARK: - API Request Body
struct NotificationRequest: Codable {
    let paginationRequest: PaginationRequestBody
    let filters: NotificationFilters
}

struct PaginationRequestBody: Codable {
    let pageNumber: Int
    let pageSize: Int
    let afterCursor: Int
    let beforeCursor: Int
    let sortDirection: String
}

struct NotificationFilters: Codable {
    let title: String
    let notifyDate: String
}

// MARK: - API Response
struct NotificationResponse: Codable {
    let data: NotificationDataWrapper
    let isSuccess: Bool
    let message: String
}

struct NotificationRecord: Codable {
    let id: Int
    let title: String?
    let message: String?
    let notifyDate: String?
    let isActive: Bool
    let createdAt: String?
}

struct NotificationDataWrapper: Codable {
    let data: [NotificationRecord]
    let paginationResponseDetails: PaginationDetails
}

struct PaginationDetails: Codable {
    let pageSize: Int
    let itemCount: Int
    let totalRecords: Int
    let currentPage: Int
    let totalPages: Int
    let firstCursor: Int
    let lastCursor: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    // Note: mode and sortDirection are Ints in this API response
    let mode: Int
    let sortDirection: Int
}

struct NotificationPostRequest: Encodable {
    let title: String
    let message: String
    let notifyDate: String // ISO8601 Format
}


struct UserProfileResponse: Codable {
    let data: UserData1
    let isSuccess: Bool
    let message: String
}

struct UserData1: Codable {
    let id: Int
    let userName: String?
    let email: String?
    let name: String?
    let emailConfirmed: Bool
    let created: String?
}

struct UserUpdateRequest: Encodable {
    let fullName: String
    let email: String
    let phoneNumber: String
}


struct MemberUpdateRequest: Codable {
    let id: Int
    let fullName: String?
    let urduName: String?
    let fatherName: String?
    let cnic: String?
    let email: String?
    let phoneNumber: String?
    let alternatePhoneNumber: String?
    let address: String?
    let city: String?
    let district: String?
    let village: String?
    let dateOfBirth: String? // Format: "2026-03-06T02:38:03.624Z"
    let gender: String?
    let maritalStatus: String?
    let bloodGroup: String?
    let education: String?
    let profession: String?
    let skills: String?
    let referralName: String?
    let designationId: Int?
    let districtId: Int?
    let constituencyId: Int?
    let unionCouncilId: Int?
    let wardId: Int?
    let joiningDate: String?
    let membershipStatus: String?
    let notes: String?
    let nameofLocalJamat: String?
    let tempImageId: String?
}
