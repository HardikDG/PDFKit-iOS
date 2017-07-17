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
    let socketURL = "http://192.168.1.76:8484/"

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
        let socket = SocketIOClient(socketURL: URL(string: socketURL)!, config: [.log(true), .compress])

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }

        socket.on(SocketEvents.addAnnotation) { data, ack in
            self.pdfView.addAnnotation(data: data)
        }

        socket.on(SocketEvents.clearAnnotation) { data, ack in
            self.pdfView.clearAnnotations(data: data)

        }

        socket.on(SocketEvents.editAnnotation) { data, ack in
            self.pdfView.editAnnotation(data: data)

        }

        socket.on(SocketEvents.deleteAnnotation) { data, ack in
            self.pdfView.deleteAnnotation(data: data)

        }
//        socket.on("currentAmount") {data, ack in
//            if let cur = data[0] as? Double {
//                socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//                    socket.emit("update", ["amount": cur + 2.50])
//                }
//                
//                ack.with("Got your currentAmount", "dude")
//            }
//        }

        socket.connect()
    }
}
