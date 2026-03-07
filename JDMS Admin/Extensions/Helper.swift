
import Foundation
import UIKit
import NVActivityIndicatorView

@IBDesignable extension UIButton {
    func applyCornerRadiusAndShadowbutton(cornerRadius: CGFloat = 12, shadowColor: UIColor = .white, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowOpacity: Float = 0.3, shadowRadius: CGFloat = 4.0, backgroundAlpha: CGFloat = 1.0) {
        
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        
        // Set up shadow properties
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
        
        // Set background opacity
        self.alpha = backgroundAlpha
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable extension UILabel {
    
    @IBInspectable var borderWidth2: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius2: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor2: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable extension UIView {
    func applyCornerRadiusAndShadow(cornerRadius: CGFloat = 12, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowOpacity: Float = 0.3, shadowRadius: CGFloat = 4.0, backgroundAlpha: CGFloat = 1.0) {
        
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        
        // Set up shadow properties
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
        
        // Set background opacity
        self.alpha = backgroundAlpha
    }
    
    @IBInspectable var borderWidth1: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius1: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor1: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
@IBDesignable extension UIImageView {
    
    func addBottomCurve(curveHeight: CGFloat = 50) {
        // Define the size of the image view
        let imageViewBounds = self.bounds
        
        // Create a bezier path with a curved bottom
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: imageViewBounds.width, y: 0))
        path.addLine(to: CGPoint(x: imageViewBounds.width, y: imageViewBounds.height - curveHeight)) // Adjust height for curve
        path.addQuadCurve(to: CGPoint(x: 0, y: imageViewBounds.height - curveHeight), controlPoint: CGPoint(x: imageViewBounds.width / 2, y: imageViewBounds.height)) // Control point for curve
        path.close()
        
        // Create a shape layer mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        // Apply the mask to the imageView
        self.layer.mask = maskLayer
    }
}
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            self.init(white: 1.0, alpha: 0.0) // Return a clear color if invalid
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


func roundCornertextView(textView:UITextView,cornerRadius:CGFloat)
{
    textView.layer.cornerRadius = cornerRadius
    textView.clipsToBounds = true
}

func roundCorner(button:UIButton)
{
    button.layer.cornerRadius = button.frame.size.height/2
    button.clipsToBounds = true
}

func roundCorneView(view:UIView)
{
    view.layer.cornerRadius = view.frame.size.height/2
    view.clipsToBounds = true
}

func roundCorneLabel(label:UILabel)
{
    label.layer.cornerRadius = label.frame.size.height/2
    label.clipsToBounds = true
}


func applyCornerRadiusToBottomCorners(view: UIView, cornerRadius: CGFloat) {
    // Create a bezier path with rounded corners at bottom-left and bottom-right
    let path = UIBezierPath(roundedRect: view.bounds,
                            byRoundingCorners: [.bottomLeft, .bottomRight],
                            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    
    // Create a shape layer with the bezier path
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.cgPath
    
    // Set the shape layer as the mask for the view
    view.layer.mask = maskLayer
}
extension UIViewController
{
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithButtons(title: String, message: String, okTitle: String = "OK",cancelTitle: String? = "Cancel",
                              okHandler: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OK Action
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            okHandler?()
        }
        alertController.addAction(okAction)
        
        // Cancel Action (Only adds if cancelTitle is not nil)
        if let cancel = cancelTitle {
            let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func handleAPIError(_ error: Error) {
        let nsError = error as NSError
        if nsError.code == 401 {
            self.showAlertWithButtons(title: "Session Expired", message: "Please login again.", okTitle: "Login", cancelTitle: nil) {
                AppNavigator.navigateToLogin()
            }
        } else {
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    func showToast(message: String, font: UIFont) {
        let toastWidth: CGFloat = 300
        let toastHeight: CGFloat = 40
        
        // Calculate X to be perfectly in the middle
        let xCoor = (self.view.frame.size.width - toastWidth) / 2
        // Calculate Y to be near the bottom (adjust the 100 to move it up or down)
        let yCoor = self.view.frame.size.height - 120
        
        let toastLabel = UILabel(frame: CGRect(x: xCoor, y: yCoor, width: toastWidth, height: toastHeight))
        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = font
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = toastHeight / 2 // Makes it a pill shape
        toastLabel.clipsToBounds = true
        
        self.view.addSubview(toastLabel)
        
        // Animation: Fade in and out
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}



func curveTopLeftCornersforView(of view: UIView, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: view.bounds,
                            byRoundingCorners: [.topRight],
                            cornerRadii: CGSize(width: radius, height: radius))
    
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    view.layer.mask = mask
}
func curveTopCornersDown(of view: UIView, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: view.bounds,
                            byRoundingCorners: [.topLeft, .topRight],
                            cornerRadii: CGSize(width: radius, height: radius))
    
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    view.layer.mask = mask
}

func addDropShadowButtonOne(to button: UIButton) {
    button.layer.shadowColor = UIColor.white.cgColor   // Shadow color
    button.layer.shadowOpacity = 0.5                   // Shadow opacity (0 to 1, where 1 is completely opaque)
    button.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset (width = horizontal, height = vertical)
    button.layer.shadowRadius = 4                      // Shadow blur radius
    button.layer.masksToBounds = false                 // Ensure shadow appears outside the view bounds
}


func addDropShadow(to view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor   // Shadow color
    view.layer.shadowOpacity = 0.5                   // Shadow opacity (0 to 1, where 1 is completely opaque)
    view.layer.shadowOffset = CGSize(width: 0, height: 1) // Shadow offset (width = horizontal, height = vertical)
    view.layer.shadowRadius = 4                     // Shadow blur radius
    view.layer.masksToBounds = false                 // Ensure shadow appears outside the view bounds
}


let primaryColor = UIColor(red: 79/255, green: 143/255, blue: 0/255, alpha: 1.0)


func applyGradientToButtonThree(view: UIView) {
    let gradientLayer = CAGradientLayer()
    
    // Define your gradient colors
    gradientLayer.colors = [
        
        UIColor(hex: "#609C14").cgColor,
        UIColor(hex: "#78BD22").cgColor,
        UIColor(hex: "#96F026").cgColor, UIColor(hex: "#84B844").cgColor
    ]
    
    // Set the gradient direction
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)   // Top-left
    gradientLayer.endPoint = CGPoint(x: 1, y: 1)     // Bottom-right
    
    // Set the gradient's frame to match the button's bounds
    gradientLayer.frame = view.bounds
    
    // Apply rounded corners to the gradient
    gradientLayer.cornerRadius = view.layer.cornerRadius
    
    // Add the gradient to the button
    view.layer.insertSublayer(gradientLayer, at: 0)
}


func addBottomCurveforView(view: UIView, curveHeight: CGFloat = 100) {
    // Define the size of the view
    let viewBounds = view.bounds
    
    // Create a bezier path with a curved bottom
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: viewBounds.width, y: 0))
    path.addLine(to: CGPoint(x: viewBounds.width, y: viewBounds.height - curveHeight)) // Adjust height for curve
    path.addQuadCurve(to: CGPoint(x: 0, y: viewBounds.height - curveHeight), controlPoint: CGPoint(x: viewBounds.width / 2, y: viewBounds.height)) // Control point for curve
    path.close()
    
    // Create a shape layer mask
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.cgPath
    
    // Apply the mask to the view
    view.layer.mask = maskLayer
}

func formatDate(_ dateString: String?) -> String {
    guard let dateString = dateString else { return "N/A" }
    
    // The API format: 2026-02-15T12:42:13
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm" // Matches the long API string
    
    if let date = formatter.date(from: dateString) {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Fallback if milliseconds differ
    return String(dateString.prefix(10))
}



 func parseDateForSorting(_ dateStr: String?) -> Date? {
    guard let s = dateStr else { return nil }
    let f1 = DateFormatter(); f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let f2 = DateFormatter(); f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
    let iso = ISO8601DateFormatter(); iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    return f1.date(from: s) ?? f2.date(from: s) ?? iso.date(from: s)
}

func getEventStatus(start: String?, end: String?) -> EventStatus {
    // 1. Define a helper to try all possible formats sent by your server
    func parseDate(_ dateStr: String?) -> Date? {
        guard let s = dateStr else { return nil }
        
        // Format A: 2026-03-06T12:22:06 (Standard)
        let f1 = DateFormatter()
        f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f1.locale = Locale(identifier: "en_US_POSIX")
        
        // Format B: 2026-03-01T22:24:15.9698617 (With fractions)
        let f2 = DateFormatter()
        f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        f2.locale = Locale(identifier: "en_US_POSIX")
        
        // Format C: ISO8601
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return f1.date(from: s) ?? f2.date(from: s) ?? iso.date(from: s)
    }

    // 2. Parse the dates
    guard let startDate = parseDate(start) else {
        print("⚠️ Failed to parse start date: \(start ?? "nil")")
        return .past
    }
    
    let endDate = parseDate(end) ?? startDate
    let now = Date()

    // 3. Comparison Logic
    if now >= startDate && now <= endDate {
        return .ongoing
    } else if startDate > now {
        if Calendar.current.isDateInToday(startDate) {
            return .today
        }
        return .upcoming
    } else {
        return .past
    }
}


func formatServerDate(_ dateString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    
    // Formatter 1: For "2026-03-15T09:00:00" (No fractions)
    let formatStandard = DateFormatter()
    formatStandard.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatStandard.locale = Locale(identifier: "en_US_POSIX")
    
    // Formatter 2: For "2026-02-22T16:51:34.010773" (With fractions)
    let formatFractional = DateFormatter()
    formatFractional.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
    formatFractional.locale = Locale(identifier: "en_US_POSIX")

    // Try parsing in order of likelihood
    let date = isoFormatter.date(from: dateString) ??
               formatStandard.date(from: dateString) ??
               formatFractional.date(from: dateString)
    
    if let validDate = date {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd hh : mm a"
        return displayFormatter.string(from: validDate)
    }
    
    return dateString // Returns raw string if all 3 fail
}


extension UIFont {
    static func jameelNastaleeq(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Jameel-Noori-Nastaleeq", size: size)
        ?? UIFont.systemFont(ofSize: size)
    }
    
    static func jameelNastaleeqBold(_ size: CGFloat, isBold: Bool = false) -> UIFont {
            let fontName = isBold ? "Jameel-Noori-Nastaleeq-Bold" : "Jameel-Noori-Nastaleeq"
            return UIFont(name: fontName, size: size) ?? (isBold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size))
        }
}




let dawatPDFList: [DawatPDF] = [
    
    DawatPDF(
        title: "Islahi Paighaam",
        fileName: "islahi_paighaam.pdf",
        icon: "pdf_icon",
        uploadDate: "12 Dec 2025",
        fileSize: "1.2 MB",
        category: "Islah",
        description: "A short Islahi message for personal and collective reform."
    ),
    
    DawatPDF(
        title: "Dawat-e-Deen ka Ta’aruf",
        fileName: "dawat_e_deen_intro.pdf",
        icon: "pdf_icon",
        uploadDate: "08 Dec 2025",
        fileSize: "2.5 MB",
        category: "Dawat",
        description: "Introduction to the mission, objectives, and methodology of Dawat-e-Deen."
    ),
    
    DawatPDF(
        title: "Tarbiyati Dars",
        fileName: "tarbiyati_dars.pdf",
        icon: "pdf_icon",
        uploadDate: "05 Dec 2025",
        fileSize: "1.8 MB",
        category: "Training",
        description: "Weekly Tarbiyati Dars for Arkaan and Karkunan."
    ),
    
    DawatPDF(
        title: "Seerat-un-Nabi",
        fileName: "seerat_un_nabi.pdf",
        icon: "pdf_icon",
        uploadDate: "01 Dec 2025",
        fileSize: "3.1 MB",
        category: "Seerat",
        description: "Dawati and Islahi aspects of the life of Prophet Muhammad."
    ),
    
    DawatPDF(
        title: "Islami Akhlaq aur Muashra",
        fileName: "islami_akhlaq.pdf",
        icon: "pdf_icon",
        uploadDate: "28 Nov 2025",
        fileSize: "2.0 MB",
        category: "Akhlaq",
        description: "Guidance on Islamic morals and social responsibilities."
    ),
    DawatPDF(
        title: "Islahi Paighaam",
        fileName: "islahi_paighaam.pdf",
        icon: "pdf_icon",
        uploadDate: "12 Dec 2025",
        fileSize: "1.2 MB",
        category: "Islah",
        description: "A short Islahi message for personal and collective reform."
    ),
]


let dummyAffiliations: [Affiliation] = [
    
    // MARK: - Affiliation 1
    Affiliation(
        id: 1,
        name: "Shigar",
        constituencies: [
            
            Constituency(
                id: 101,
                name: "LA-7 Bhimber-3",
                unionCouncils: [
                    UnionCouncil(
                        id: 1001,
                        name: "Kala Mula",
                        wards: [
                            Ward(id: 1, name: "Ward 1"),
                            Ward(id: 2, name: "Ward 2"),
                            Ward(id: 3, name: "Ward 3")
                        ]
                    ),
                    UnionCouncil(
                        id: 1002,
                        name: "Haji Abad",
                        wards: [
                            Ward(id: 4, name: "Ward 1"),
                            Ward(id: 5, name: "Ward 2")
                        ]
                    )
                ]
            ),
            
            Constituency(
                id: 102,
                name: "LA-8 Bhimber-4",
                unionCouncils: [
                    UnionCouncil(
                        id: 1003,
                        name: "Ali Pur",
                        wards: [
                            Ward(id: 6, name: "Ward 1"),
                            Ward(id: 7, name: "Ward 2")
                        ]
                    )
                ]
            )
        ]
    ),
    
    // MARK: - Affiliation 2
    Affiliation(
        id: 2,
        name: "Bhimber",
        constituencies: [
            
            Constituency(
                id: 201,
                name: "LA-9 Bhimber-5",
                unionCouncils: [
                    UnionCouncil(
                        id: 2001,
                        name: "Chak Jamal",
                        wards: [
                            Ward(id: 8, name: "Ward 1"),
                            Ward(id: 9, name: "Ward 2")
                        ]
                    )
                ]
            )
        ]
    ),
    
    // MARK: - Affiliation 3
    Affiliation(
        id: 3,
        name: "Mirpur",
        constituencies: [
            
            Constituency(
                id: 301,
                name: "LA-10 Mirpur-1",
                unionCouncils: [
                    UnionCouncil(
                        id: 3001,
                        name: "Sector F",
                        wards: [
                            Ward(id: 10, name: "Ward 1"),
                            Ward(id: 11, name: "Ward 2"),
                            Ward(id: 12, name: "Ward 3")
                        ]
                    )
                ]
            ),
            
            Constituency(
                id: 302,
                name: "LA-11 Mirpur-2",
                unionCouncils: [
                    UnionCouncil(
                        id: 3002,
                        name: "Sector D",
                        wards: [
                            Ward(id: 13, name: "Ward 1")
                        ]
                    )
                ]
            )
        ]
    ),
    
    // MARK: - Affiliation 4
    Affiliation(
        id: 4,
        name: "Kotli",
        constituencies: [
            
            Constituency(
                id: 401,
                name: "LA-12 Kotli-1",
                unionCouncils: [
                    UnionCouncil(
                        id: 4001,
                        name: "Charhoi",
                        wards: [
                            Ward(id: 14, name: "Ward 1"),
                            Ward(id: 15, name: "Ward 2")
                        ]
                    )
                ]
            )
        ]
    ),
    
    // MARK: - Affiliation 5
    Affiliation(
        id: 5,
        name: "Muzaffarabad",
        constituencies: [
            
            Constituency(
                id: 501,
                name: "LA-13 Muzaffarabad-1",
                unionCouncils: [
                    UnionCouncil(
                        id: 5001,
                        name: "Lower Plate",
                        wards: [
                            Ward(id: 16, name: "Ward 1"),
                            Ward(id: 17, name: "Ward 2"),
                            Ward(id: 18, name: "Ward 3")
                        ]
                    )
                ]
            )
        ]
    )
]



func startLoading(view:NVActivityIndicatorView) {
    view.isHidden = false
    view.startAnimating()
    
}

func stopLoading(view:NVActivityIndicatorView) {
    view.stopAnimating()
    view.isHidden = true
    
}



class LargeHitButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 20
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
}
