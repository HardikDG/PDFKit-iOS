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
    let socketURL = "https://pdf-annonate.herokuapp.com/"
    var socket: SocketIOClient!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        configureSocketIO()
        pdfView.configureView()
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

        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }

        socket.connect()
    }
}
