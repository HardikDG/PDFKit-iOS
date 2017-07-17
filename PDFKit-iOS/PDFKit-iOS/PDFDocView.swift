//
//  PDFDocView.swift
//  PDFKit-iOS
//
//  Created by Parth on 14/07/17.
//  Copyright © 2017 Solution Analysts. All rights reserved.
//

import UIKit
import Material
import ZDStickerView

class PDFDocView: UIView, UIScrollViewDelegate {

    fileprivate let fabMenuSize = CGSize(width: 40, height: 40)
    fileprivate let bottomInset: CGFloat = 16
    fileprivate let rightInset: CGFloat = 16

    fileprivate var fabButton: FABButton!
    fileprivate var fabMenu: FABMenu!
    fileprivate var notesFABMenuItem: FABMenuItem!
    fileprivate var remindersFABMenuItem: FABMenuItem!

    var pdfFile: CGPDFDocument!
    var numberOfPages: Int = 0
    var pdfScrollView: TiledPDFScrollView!
    var page: CGPDFPage!
    var myScale: CGFloat = 0
    var currentPageNumber: Int = 1 {
        didSet {
            page = pdfFile.page(at: currentPageNumber)
            pdfScrollView.setPDFPage(page)
            if let  _ = currentPageLabel {
                currentPageLabel.text = "\(currentPageNumber)/\(numberOfPages)"
            }
        }
    }
    var pageControlView: UIView!
    var currentPageLabel: UILabel!

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
        prepareFABButton()
        prepareFABMenu()
    }

    func loadPDFFromBundle() {
        if let pdfUrl = Bundle.main.url(forResource: "NCPocDoc.pdf", withExtension: nil) {
            let documentUrl = pdfUrl as CFURL
            pdfFile = CGPDFDocument(documentUrl)
            numberOfPages = pdfFile.numberOfPages as Int
            print("PDF Loaded with \(numberOfPages) pages")
            loadPDFInView()
        } else {
            print("Error Loading PDF file")
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pdfScrollView.tiledPDFView
    }

    func loadPDFInView() {
        if numberOfPages > 1 {
            pdfScrollView = TiledPDFScrollView(frame: CGRect(x: 0, y: 50, w: self.bounds.width, h: self.bounds.height - 50))
            addPageControlView()
        } else {
            pdfScrollView = TiledPDFScrollView(frame: self.bounds)
        }
        pdfScrollView.delegate = self
        self.addSubview(pdfScrollView)
        currentPageNumber = 1
    }

    func addPageControlView() {
        pageControlView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 50))
        self.addSubview(pageControlView)
        currentPageLabel = UILabel(frame: CGRect(x: self.bounds.width/2 - 50, y: 0, width: 100, height: 50))
        currentPageLabel.textAlignment = .center
        currentPageLabel.text = "1/\(numberOfPages)"
        pageControlView.addSubview(currentPageLabel)

        func addButtonsToPageControl() {
            let nextButton = UIButton(x: self.bounds.width - 50, y: 0, w: 50, h: 50, target: self, action: #selector(changePdfPage(buttonTapped:)))
            nextButton.tag = 2
            nextButton.setImage(UIImage(named: "img_pdf_next"), for: .normal)
            pageControlView.addSubview(nextButton)

            let previousButton = UIButton(x: 0, y: 0, w: 50, h: 50, target: self, action: #selector(changePdfPage(buttonTapped:)))
            previousButton.tag = 1
            previousButton.setImage(UIImage(named: "img_pdf_previous"), for: .normal)
            pageControlView.addSubview(previousButton)
        }
        addButtonsToPageControl()
    }

    func changePdfPage(buttonTapped: UIButton) {
        if buttonTapped.tag == 1 {
            currentPageNumber = (currentPageNumber - 1).clamp(min: 1, numberOfPages)
        } else {
            currentPageNumber = (currentPageNumber + 1).clamp(min: 1, numberOfPages)
        }
    }

}

extension PDFDocView {
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = Color.red.base
    }

    fileprivate func prepareFABMenu() {
        fabMenu = FABMenu()
        fabMenu.fabButton = fabButton

        self.layout(fabMenu)
            .size(fabMenuSize)
            .bottom(bottomInset)
            .right(rightInset)
        prepareNotesFABMenuItem()
        prepareRemindersFABMenuItem()
        fabMenu.delegate = self
        fabMenu.fabMenuItems = [notesFABMenuItem, remindersFABMenuItem]

    }

    fileprivate func prepareNotesFABMenuItem() {
        notesFABMenuItem = FABMenuItem()
        notesFABMenuItem.title = "Audio Library"
        notesFABMenuItem.fabButton.image = Icon.cm.pen
        notesFABMenuItem.fabButton.tintColor = .white
        notesFABMenuItem.fabButton.pulseColor = .white
        notesFABMenuItem.fabButton.backgroundColor = Color.green.base
        notesFABMenuItem.fabButton.addTarget(self, action: #selector(handleNotesFABMenuItem(button:)), for: .touchUpInside)

    }

    fileprivate func prepareRemindersFABMenuItem() {
        remindersFABMenuItem = FABMenuItem()
        remindersFABMenuItem.title = "Reminders"
        remindersFABMenuItem.fabButton.image = Icon.cm.bell
        remindersFABMenuItem.fabButton.tintColor = .white
        remindersFABMenuItem.fabButton.pulseColor = .white
        remindersFABMenuItem.fabButton.backgroundColor = Color.blue.base
        remindersFABMenuItem.fabButton.addTarget(self, action: #selector(handleRemindersFABMenuItem(button:)), for: .touchUpInside)
    }


    @objc
    fileprivate func handleNotesFABMenuItem(button: UIButton) {
        print("notesFABMenuItem")
        addCircle()
        fabMenu.close()
        fabMenu.fabButton?.animate(Motion.rotation(angle: 0))

    }

    @objc
    fileprivate func handleRemindersFABMenuItem(button: UIButton) {
        print("remindersFABMenuItem")
        addText()
        fabMenu.close()
        fabMenu.fabButton?.animate(Motion.rotation(angle: 0))

    }

}

extension PDFDocView {

    func addCircle() {
        let contentView = UIView(frame: CGRect(x: 50, y: 50, w: 120, h: 120))
        contentView.addSubview(UIImageView(image: Icon.cm.check))
        contentView.backgroundColor = .red
        let resizableCircle = ZDStickerView(frame: CGRect(x: 50, y: 50, w: 150, h: 150))
        resizableCircle.tag = 10
        resizableCircle.contentView = contentView
        resizableCircle.stickerViewDelegate = self
        resizableCircle.preventsPositionOutsideSuperview = true
        resizableCircle.showEditingHandles()
        pdfScrollView.tiledPDFView.addSubview(resizableCircle)
    }

    func addText() {

    }
}

extension PDFDocView {
    // Socket Event Updates 

    func addAnnotation(data: [Any]) {
        print("=======ADD ANNOTATION CALLED=======")
    }

    func deleteAnnotation(data: [Any]) {
        print("=======DELETE ANNOTATION CALLED=======")

    }

    func clearAnnotations(data: [Any]) {
        print("=======CLEAR ANNOTATION CALLED=======")

    }

    func editAnnotation(data: [Any]) {
        print("=======EDIT ANNOTATION CALLED=======")

    }
}

extension PDFDocView: ZDStickerViewDelegate {

}

extension PDFDocView: FABMenuDelegate {

    func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(Motion.rotation(angle: 45))
    }

    func fabMenuDidOpen(fabMenu: FABMenu) {
        print("DID OPEN")
    }

    func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(Motion.rotation(angle: 0))
    }

    func fabMenuDidClose(fabMenu: FABMenu) {
        print("fabMenuDidClose")
    }

    func fabMenu(fabMenu: FABMenu, tappedAt point: CGPoint, isOutside: Bool) {
        if fabMenu == notesFABMenuItem {
        }
        if fabMenu == remindersFABMenuItem {
        }
    }
}

extension Int {
    func clamp(min: Int, _ max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}
