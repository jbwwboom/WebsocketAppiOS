//
//  ViewController.swift
//  WebsocketAppiOS
//
//  Created by Jop on 06/10/2018.
//  Copyright © 2018 Jop. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {
    @IBOutlet weak var orientationLabel: UILabel!
    let manager = SocketManager(socketURL: URL(string: "http://192.168.178.24:3000")!, config: [.log(true), .compress])
    var socket : SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.socket = manager.defaultSocket
        
        self.socket.on("orientation"){data, ack in
            if let bool = data[0] as? String {
                self.changeOrientation(value: bool.toBool()!)
            }
        }
        
        self.socket.connect()
        
        getOrientation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //To be sure it gets send on startup.
        getOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        getOrientation()
    }
    
    func getOrientation(){
        var orientation = ""
        if(UIDevice.current.orientation.isLandscape){
            orientation = "Landscape"
            sendOrientation(orientation: orientation)
        }else if(UIDevice.current.orientation.isPortrait){
            orientation = "Portrait"
            sendOrientation(orientation: orientation)
        }
    }
    
    func changeOrientation(value : Bool){
        if(value){
            self.view.backgroundColor = UIColor.green
            orientationLabel.text = "CORRECT"
        }else{
            self.view.backgroundColor = UIColor.red
            orientationLabel.text = "FALSE"
        }
    }
    
    func sendOrientation(orientation: String){
        self.socket.emit("change orientation", orientation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.socket.disconnect()
    }
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

