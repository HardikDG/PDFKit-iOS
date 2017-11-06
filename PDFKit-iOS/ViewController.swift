//
//  ViewController.swift
//  PDFKit-iOS
//
//  Created by Parth on 11/07/17.
//  Copyright © 2017 Solution Analysts. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import SnapKit
import SocketIO

enum SocketEvents {
    static let addAnnotation = "add annotations"
    static let clearAnnotation = "clear annotations"
    static let editAnnotation = "edit annotations"
    static let deleteAnnotation = "delete annotations"
}

class ViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFDocView!
//    let socketURL = "http://192.168.1.40:8484/"
    let socketURL = "http://pdf-annotate.herokuapp.com/"
    var socket: SocketIOClient!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        configureSocketIO()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configureSocketIO() {
        socket = SocketIOClient(socketURL: URL(string: socketURL)!, config: [.log(true), .compress])

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.pdfView.socket = self.socket
        }

        socket.on(SocketEvents.addAnnotation) { data, ack in
            self.pdfView.addAnnotationSocketEvent(data: data)
        }

        socket.on(SocketEvents.clearAnnotation) { data, ack in
            self.pdfView.clearAnnotationsSocketEvent(data: data)

        }

        socket.on(SocketEvents.editAnnotation) { data, ack in
            self.pdfView.editAnnotationSocketEvent(data: data)

        }

        socket.on(SocketEvents.deleteAnnotation) { data, ack in
            self.pdfView.deleteAnnotationSocketEvent(data: data)

        }

        socket.connect()
    }
}
