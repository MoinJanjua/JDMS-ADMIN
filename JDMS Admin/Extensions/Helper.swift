
import Foundation
import UIKit
import NVActivityIndicatorView
import SideMenu

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



var sideMenu: SideMenuNavigationController?
func makeSettings() -> SideMenuSettings
{
   let presentationStyle = SideMenuPresentationStyle.menuSlideIn
   
   presentationStyle.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
   
   presentationStyle.presentingEndAlpha = 0.5
   var settings = SideMenuSettings()
   settings.menuWidth = 290.0
   settings.presentationStyle = presentationStyle
   return settings
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
let DimGreenColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.1)
let DimRedColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.1)


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


extension UIView {
    
    // Use a unique tag to find and remove the blur later
    private var blurViewTag: Int { return 999 }

    func addBlur(style: UIBlurEffect.Style = .dark, alpha: CGFloat = 1.0) {
        // Prevent adding multiple blurs
        removeBlur()
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        blurEffectView.tag = blurViewTag
        
        self.addSubview(blurEffectView)
        
        UIView.animate(withDuration: 0.3) {
            blurEffectView.alpha = alpha
        }
    }

    func removeBlur() {
        if let viewWithTag = self.viewWithTag(blurViewTag) {
            UIView.animate(withDuration: 0.3, animations: {
                viewWithTag.alpha = 0
            }) { _ in
                viewWithTag.removeFromSuperview()
            }
        }
    }
}


