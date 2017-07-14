//
//  ViewController.swift
//  PDFKit-iOS
//
//  Created by Parth on 11/07/17.
//  Copyright © 2017 Solution Analysts. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class ViewController: UIViewController {

    @IBOutlet weak var pdfView: UIView!

    var pdfFile: CGPDFDocument!
    var numberOfPages: Int = 0
    var pdfScrollView: TiledPDFScrollView!
    var page: CGPDFPage!
    var myScale: CGFloat = 0
    var pageNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadPDFFromBundle()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.loadPDFInView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadPDFFromBundle() {
        if let pdfUrl = Bundle.main.url(forResource: "input_pdf.pdf", withExtension: nil) {
            let documentUrl = pdfUrl as CFURL
            pdfFile = CGPDFDocument(documentUrl)
            numberOfPages = pdfFile.numberOfPages as Int
            print("PDF Loaded with \(numberOfPages) pages")
        } else {
            print("Error Loading PDF file")
        }
    }

    func loadPDFInView() {
        pdfScrollView = TiledPDFScrollView(frame: self.pdfView.bounds)
        self.pdfView.addSubview(pdfScrollView)
        page = pdfFile.page(at: 1)
        pdfScrollView.setPDFPage(page)
        page = pdfFile.page(at: 5)
    }
}

