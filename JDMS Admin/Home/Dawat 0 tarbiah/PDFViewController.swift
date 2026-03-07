//
//  PDFViewController.swift
//  JDMS
//
//  Created by Moin Janjua on 14/12/2025.
//

import UIKit
import PDFKit
import NVActivityIndicatorView

class PDFViewController: UIViewController {
    
    private var pdfView: PDFView!
    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var mainview: UIView!        // For PDF
    @IBOutlet weak var contentTextView: UIView! // Container for TextView
    @IBOutlet weak var downloadbtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    var str = String()         // Screen Title
    var content_str = String() // Text Content
    var pdfurl = String()      // PDF URL from API
    
    // Replace with your actual base URL
    let baseURL = "https://jdms.bsite.net"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlelb.text = str
        titlelb.font = .jameelNastaleeq(17)
        setupPDFView()
        checkContentMode()
        setupActivityIndicator()
    }
    
    
    func setupActivityIndicator() {
        activityIndicatorView.type = .ballPulseSync
        activityIndicatorView.color = .systemGreen
        activityIndicatorView.isHidden = true
    }
    
    private func checkContentMode() {
        // Logic: If pdfurl is not empty, show PDF and hide Text.
        // Otherwise, if content_str has details, show Text and hide PDF/Download.
        
        if !pdfurl.isEmpty {
            // MODE 1: PDF AVAILABLE
            print("📄 Mode: PDF View")
            mainview.isHidden = false
            contentTextView.isHidden = true
            downloadbtn.isHidden = false // PDF can be downloaded
            loadRemotePDF()
        } else if !content_str.isEmpty {
            // MODE 2: TEXT CONTENT AVAILABLE
            print("📝 Mode: Text Content View")
            textView.font = .jameelNastaleeq(17)
            mainview.isHidden = true
            contentTextView.isHidden = false
            downloadbtn.isHidden = true  // Hide download for text content
            textView.text = content_str
        } else {
            // Fallback: Both empty
            showAlert(title: "Empty", message: "No content available to display.")
        }
    }
    
    private func setupPDFView() {
        pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        mainview.addSubview(pdfView)
        
        // Pin to edges of mainview
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: mainview.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: mainview.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: mainview.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: mainview.trailingAnchor)
        ])
        
        // 1. Remove the gaps between pages and the top margin
        pdfView.displaysPageBreaks = false
        
        // 2. Set background to white so the "gray" area disappears
        pdfView.backgroundColor = .white
        
        // 3. Disable the safe area adjustment on the internal scrollview
        if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = .zero // Force zero padding
        }
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
    }
    
    private func loadRemotePDF() {
        // Construct the full URL if the path is relative (e.g., /uploads/...)
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        let fullPath = pdfurl.hasPrefix("http") ? pdfurl : "\(baseURL)\(pdfurl)"
        
        guard let url = URL(string: fullPath) else {
            showAlert(title: "Error", message: "Invalid PDF link.")
            return
        }
        
        // Load PDF asynchronously so the UI doesn't freeze
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.pdfView.document = document
                    
                    // Force scale to width
                    self.pdfView.autoScales = true
                    self.pdfView.maxScaleFactor = 4.0
                    self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
                    
                    // Force scroll to the actual top edge of the first page
                    if let firstPage = document.page(at: 0) {
                        let pageBounds = firstPage.bounds(for: .mediaBox)
                        // Scroll to the top-left corner
                        self.pdfView.go(to: CGRect(x: 0, y: pageBounds.height, width: 1, height: 1), on: firstPage)
                    }
                }
            }
                else
                {
                    DispatchQueue.main.async {
                        
                        self.activityIndicatorView.stopAnimating()
                        self.showAlertWithButtons(title: "Error", message: "Could not load the PDF document.", okTitle: "OK", cancelTitle: nil) {
                            self.dismiss(animated: true)
                        }
                        
                    }
                }
            }
    }
    
        
        @IBAction func downloadbtnTapped(_ sender: UIButton) {
            let fullPath = pdfurl.hasPrefix("http") ? pdfurl : "\(baseURL)\(pdfurl)"
            guard let url = URL(string: fullPath) else { return }
            
            // Professional way: Open a share sheet so user can save it anywhere
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(activityController, animated: true)
        }
        
        @IBAction func backbtnTapped(_ sender: UIButton) {
            self.dismiss(animated: true)
        }
    }
