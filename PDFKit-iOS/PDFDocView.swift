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
import SocketIO

class PDFDocView: UIView, UIScrollViewDelegate {

    fileprivate let fabMenuSize = CGSize(width: 40, height: 40)
    fileprivate let bottomInset: CGFloat = 16
    fileprivate let rightInset: CGFloat = 16

    fileprivate var fabButton: FABButton!
    fileprivate var fabMenu: FABMenu!
    fileprivate var clearAnnotationFABMenuItem: FABMenuItem!
    fileprivate var addSquareFABMenuItem: FABMenuItem!
    fileprivate var drawingView:ACEDrawingView!

    var socket: SocketIOClient?
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
            reloadAnnotaions()
        }
    }
    var pageControlView: UIView!
    var currentPageLabel: UILabel!
    var annotationArray: [ZDStickerView] = []
    var tapGesture: UITapGestureRecognizer!

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
        if let pdfUrl = Bundle.main.url(forResource: "gal-trace.pdf", withExtension: nil) {
            let documentUrl = pdfUrl as CFURL
            pdfFile = CGPDFDocument(documentUrl)
            numberOfPages = pdfFile.numberOfPages as Int
            print("PDF Loaded with \(numberOfPages) pages")
            loadPDFInView()
        } else {
            print("Error Loading PDF file")
        }
    }

    func loadPDFInView() {
        if numberOfPages > 1 {
            pdfScrollView = TiledPDFScrollView(frame: CGRect(x: 0, y: 50, w: self.bounds.width, h: self.bounds.height - 50))
            addPageControlView()
        } else {
            pdfScrollView = TiledPDFScrollView(frame: self.bounds)
        }
        
        self.addSubview(pdfScrollView)
        self.pdfScrollView.delaysContentTouches = true
        self.pdfScrollView.isExclusiveTouch = true
        self.pdfScrollView.canCancelContentTouches = true
       
        let scrollRect = pdfFile.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox)
        self.pdfScrollView.pdfFrameRect = scrollRect?.size
        self.pdfScrollView.frame = CGRect(x: 0, y: 50, width: self.pdfScrollView.frame.size.width, height: self.pdfScrollView.frame.size.height)
        currentPageNumber = 1
        self.pdfScrollView.tiledPDFView.layer.setNeedsLayout()

//        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(tapGesture:)))
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.numberOfTouchesRequired = 1
//        self.pdfScrollView.addGestureRecognizer(tapGesture)
    }

    func tapGestureRecognizer(tapGesture: UITapGestureRecognizer) {
        print("DID Tap ON PDF")
        self.pdfScrollView.isScrollEnabled = true
        annotationArray.forEach { (annotation) in
            annotation.hideEditingHandles()
        }
    }

    func reloadAnnotaions() {
        func removeAllAnnotationsFromPDF() {
            annotationArray.forEach { (annotation) in
                annotation.removeFromSuperview()
            }
        }

        func addAnnotaionForCurrentPage() {
            let annotations = annotationArray.filter { ($0.contentView as! CircleAnnotation).page == currentPageNumber }
            annotations.forEach { (annotation) in
                self.pdfScrollView.tiledPDFView.addSubview(annotation)
            }
        }

        drawingView = ACEDrawingView(frame: self.pdfScrollView.tiledPDFView.frame)
        drawingView.drawTool = ACEDrawingToolTypeRectagleFill
        self.pdfScrollView.tiledPDFView.addSubview(drawingView)
        drawingView.drawTool = ACEDrawingToolTypeDraggableText
        drawingView.delegate = self
        removeAllAnnotationsFromPDF()
        addAnnotaionForCurrentPage()
        
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
        fabMenu.fabMenuItems = [clearAnnotationFABMenuItem, addSquareFABMenuItem]

    }

    fileprivate func prepareNotesFABMenuItem() {
        clearAnnotationFABMenuItem = FABMenuItem()
        clearAnnotationFABMenuItem.title = "Clear Annotations"
        clearAnnotationFABMenuItem.fabButton.image = Icon.cm.clear
        clearAnnotationFABMenuItem.fabButton.tintColor = .white
        clearAnnotationFABMenuItem.fabButton.pulseColor = .white
        clearAnnotationFABMenuItem.fabButton.backgroundColor = Color.green.base
        clearAnnotationFABMenuItem.fabButton.addTarget(self, action: #selector(clearAnnotationFABMenuItem(button:)), for: .touchUpInside)

    }

    fileprivate func prepareRemindersFABMenuItem() {
        addSquareFABMenuItem = FABMenuItem()
        addSquareFABMenuItem.title = "Add Circle"
        addSquareFABMenuItem.fabButton.image = Icon.cm.pen
        addSquareFABMenuItem.fabButton.tintColor = .white
        addSquareFABMenuItem.fabButton.pulseColor = .white
        addSquareFABMenuItem.fabButton.backgroundColor = Color.blue.base
        addSquareFABMenuItem.fabButton.addTarget(self, action: #selector(addCircleFABMenuItem(button:)), for: .touchUpInside)
    }


    @objc
    fileprivate func clearAnnotationFABMenuItem(button: UIButton) {
        print("notesFABMenuItem")
        emitClearAnnotationEvent()
        fabMenu.close()
        fabMenu.fabButton?.animate(Motion.rotation(angle: 0))

    }

    @objc
    fileprivate func addCircleFABMenuItem(button: UIButton) {
        print("remindersFABMenuItem")
        let circle = addCircle(xPos: 50,
                               yPos: 75,
                               radius: 10,
                               page: currentPageNumber,
                               uuid: UUID().uuidString)
        annotationArray.append(circle)
        emitAddAnnotationEvent(annotation: circle)
        fabMenu.close()
        fabMenu.fabButton?.animate(Motion.rotation(angle: 0))

    }

}

extension PDFDocView {

    @discardableResult
    func addCircle(xPos: CGFloat, yPos: CGFloat, radius: CGFloat, page: Int, uuid: String) -> ZDStickerView {
        let circleView = CircleAnnotation(frame: CGRect(x: 0, y: 0, w: radius * 2, h: radius * 2))
        circleView.uuid = uuid
        circleView.page = page
        circleView.backgroundColor = UIColor.clear
        let resizableCircle = ZDStickerView(frame: CGRect(x: xPos, y: yPos, w: radius * 2, h: radius * 2))
        resizableCircle.contentView = circleView
        resizableCircle.stickerViewDelegate = self
        resizableCircle.preventsPositionOutsideSuperview = true
        resizableCircle.preventsCustomButton = true
        resizableCircle.setButton(ZDSTICKERVIEW_BUTTON_DEL, image: Icon.close)
        resizableCircle.hideEditingHandles()
        if page == currentPageNumber {
            pdfScrollView.tiledPDFView.addSubview(resizableCircle)
        }
        return resizableCircle
    }

    func calculateFrameForAnnotation(annotation: ZDStickerView, fromView: TiledPDFScrollView) -> CGRect {
        var frame: CGRect = .zero
        let scale = pdfScrollView.zoomScale
        frame.size.width = annotation.contentView.frame.size.width //* scale
        frame.size.height = annotation.contentView.frame.size.height //* scale
        frame.origin.x = annotation.frame.origin.x + annotation.contentView.frame.origin.x * scale
        frame.origin.y = annotation.frame.origin.y + annotation.contentView.frame.origin.y * scale
        return frame
    }
}

extension PDFDocView {
    // Socket Event Updates 

    func addAnnotationSocketEvent(data: [Any]) {

        print("=======ADD ANNOTATION CALLED=======")
        if let annotationData = data.first as? [String : Any] {
            if(annotationData["type"] as! String == "fillcircle") {
                let xPos = annotationData["cx"] as! CGFloat
                let yPos = annotationData["cy"] as! CGFloat
                let radius = annotationData["r"] as! CGFloat
                let circleAnnotation = addCircle(xPos: xPos - radius,
                                                 yPos: yPos - radius,
                                                 radius: radius,
                                                 page: annotationData["page"] as! Int,
                                                 uuid: annotationData["uuid"] as! String)
                annotationArray.append(circleAnnotation)
            } else {
                drawingView.drawTool = ACEDrawingToolTypeDraggableText
                drawingView.createNewObjects(CGPoint(x: annotationData["x"] as! CGFloat, y: annotationData["y"] as! CGFloat), withData:["content":annotationData["content"] as! String])
            }
        }
    }

    func emitAddAnnotationEvent(annotation: ZDStickerView) {

//        let circleView = CircleAnnotation(frame: CGRect(x: 92 - 10, y: 195 - 10, w: 20, h: 20))
//        circleView.backgroundColor = UIColor.clear
//        pdfScrollView.tiledPDFView.addSubview(circleView)
        
        let frame = calculateFrameForAnnotation(annotation: annotation, fromView: pdfScrollView)
        print(frame)
        let annotationDict: [String:Any] = ["type":"fillcircle",
                                               "cx": frame.x + (frame.width)/2,
                                               "cy": frame.y + (frame.width)/2,
                                               "r": (frame.width)/2,
                                               "class": "Annotation",
                                               "uuid": (annotation.contentView as! CircleAnnotation).uuid!,
                                               "page": (annotation.contentView as! CircleAnnotation).page!,
                                               "color": "#808080",
                                               ]
        socket?.emit(SocketEvents.addAnnotation, with: [annotationDict])
    }

    func deleteAnnotationSocketEvent(data: [Any]) {
        print("=======DELETE ANNOTATION CALLED=======")
        if let annotationData = data.first as? [String : Any] {
            let uuid = annotationData["uuid"] as! String
            let annotation = annotationArray.filter { ($0.contentView as! CircleAnnotation).uuid == uuid }
            print(annotation)
            annotation.first?.removeFromSuperview()
        }
    }

    func emitDeleteAnnotationEvent(annotation: ZDStickerView) {
        socket?.emit(SocketEvents.deleteAnnotation, with: [["uuid": (annotation.contentView as! CircleAnnotation).uuid!,
                                                            "documentId":"shared/example.pdf",
                                                            "is_deleted":true,
                                                            "i_by":(annotation.contentView as! CircleAnnotation).uuid!,
                                                            "page":1]])
    }

    func clearAnnotationsSocketEvent(data: [Any]) {
        print("=======CLEAR ANNOTATION CALLED=======")
        annotationArray.forEach { (annotation) in
            annotation.removeFromSuperview()
        }
        annotationArray = []
    }

    func emitClearAnnotationEvent() {
        socket?.emit(SocketEvents.clearAnnotation, with: [["clear"]])
        annotationArray.forEach { (annotation) in
            annotation.removeFromSuperview()
        }
        annotationArray = []
    }

    func editAnnotationSocketEvent(data: [Any]) {
        print("=======EDIT ANNOTATION CALLED=======")
        if let annotationData = data.first as? [String : Any] {
            let uuid = annotationData["uuid"] as! String
            let annotation = annotationArray.filter { ($0.contentView as! CircleAnnotation).uuid == uuid }
            print(annotation)
            let cx = annotationData["cx"] as! CGFloat
            let cy = annotationData["cy"] as! CGFloat
            annotation.first?.frame.x = cx
            annotation.first?.frame.y = cy
        }
    }

    func emitEditAnnotationEvent(annotation: ZDStickerView) {
        let frame = calculateFrameForAnnotation(annotation: annotation, fromView: pdfScrollView)

        let annotationDict: [String:Any] = ["type":"fillcircle",
                                            "cx": frame.x + (frame.width)/2,
                                            "cy": frame.y + (frame.width)/2,
                                            "r": (frame.width)/2,
                                            "class": "Annotation",
                                            "uuid": (annotation.contentView as! CircleAnnotation).uuid!,
                                            "page": (annotation.contentView as! CircleAnnotation).page!,
                                            "color": "#808080",
                                            ]
        socket?.emit(SocketEvents.editAnnotation, with: [annotationDict])
    }
}



extension PDFDocView: ZDStickerViewDelegate {

    func stickerViewDidClose(_ sticker: ZDStickerView!) {
        print(sticker)
        print("CLOSE")
        emitDeleteAnnotationEvent(annotation: sticker)
    }
    
    func stickerViewDidEndEditing(_ sticker: ZDStickerView!) {
        print(sticker)
        print("stickerViewDidEndEditing")
        emitEditAnnotationEvent(annotation: sticker)
    }
    
    func stickerViewDidCancelEditing(_ sticker: ZDStickerView!) {
        print(sticker)
        print("stickerViewDidCancelEditing")
        if sticker.isEditingHandlesHidden() {
            sticker.showEditingHandles()
            self.pdfScrollView.isScrollEnabled = false
        }
    }

    func stickerViewDidBeginEditing(_ sticker: ZDStickerView!) {
        print(sticker)
        print("stickerViewDidBeginEditing")
    }

    func stickerViewDidCustomButtonTap(_ sticker: ZDStickerView!) {
        print(sticker)
        print("stickerViewDidCustomButtonTap")
    }
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
    }
}

extension PDFDocView: ACEDrawingViewDelegate {
    func drawingView(_ view: ACEDrawingView, willBeginDrawUsing tool: ACEDrawingTool) {
                self.pdfScrollView.isScrollEnabled = false
    }

    func drawingView(_ view: ACEDrawingView, didEndDrawUsing tool: ACEDrawingTool) {
        self.pdfScrollView.isScrollEnabled = true
    }
}

extension Int {
    func clamp(min: Int, _ max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}
