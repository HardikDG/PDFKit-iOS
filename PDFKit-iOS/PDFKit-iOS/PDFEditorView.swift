//
//  PDFEditorView.swift
//  PDFKit-iOS
//
//  Created by Parth on 14/07/17.
//  Copyright © 2017 Solution Analysts. All rights reserved.
//

import UIKit

class PDFEditorView: UIView {

    var pdfFile: CGPDFDocument!
    var numberOfPages: Int = 0
    var pdfScrollView: TiledPDFScrollView!
    var page: CGPDFPage!
    var myScale: CGFloat = 0
    var pageNumber: Int = 1

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureView()
    }

    func configureView() {
        loadPDFFromBundle()
        loadPDFInView()
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
        pdfScrollView = TiledPDFScrollView(frame: self.bounds)
        self.addSubview(pdfScrollView)
        page = pdfFile.page(at: pageNumber)
        pdfScrollView.setPDFPage(page)
    }
}
