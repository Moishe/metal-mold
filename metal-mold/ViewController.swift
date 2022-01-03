//
//  ViewController.swift
//  metal-mold
//
//  Created by Moishe Lettvin on 1/3/22.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
          fatalError("View of controller is not an MTKView")
        }
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
          fatalError("Metal is not supported")
        }
        metalView.device = defaultDevice
        
        guard let renderer = Renderer(metalView: metalView) else {
          fatalError("Renderer cannot be initialized")
        }
        self.renderer = renderer
        renderer.mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
        metalView.delegate = renderer
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

