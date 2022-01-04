//
//  Culture.swift
//  metal-mold
//
//  Created by Moishe Lettvin on 1/3/22.
//

import MetalKit

struct Actor {
  var position: float2
  var direction: Float
  var speed: Float
  var goalColor: float4
  var remainingLife: Int
}

struct ActorDescriptor {
  var position: float2 = [0, 0]
  var positionXRange: ClosedRange<Float> = 0...0
  var positionYRange: ClosedRange<Float> = 0...0
  var direction: Float = 0
  var directionRange: ClosedRange<Float> = 0...0
  var speed: Float = 0
  var speedRange: ClosedRange<Float> = 0...0
  var life: Int = 0
  var lifeRange: ClosedRange<Int> = 1...1
  var goalColor: float4 = [0, 0, 0, 1]
}

class Emitter {
  var position: float2 = [0, 0]
  var currentActors = 0
  var actorCount: Int = 0 {
    didSet {
      let bufferSize = MemoryLayout<Actor>.stride * actorCount
      actorBuffer = Renderer.device.makeBuffer(length: bufferSize)!
    }
  }
  var birthRate = 0
  var birthDelay = 0 {
    didSet {
      birthTimer = birthDelay
    }
  }
  private var birthTimer = 0
  
  var actorTexture: MTLTexture!
  var actorBuffer: MTLBuffer?
  
  var actorDescriptor: ActorDescriptor?
  
  func emit() {
    if currentActors >= actorCount {
      return
    }
    guard let actorBuffer = actorBuffer,
          let ad = actorDescriptor else {
            return
          }
    birthTimer += 1
    if birthTimer < birthDelay {
      return
    }
    birthTimer = 0
    var pointer = actorBuffer.contents().bindMemory(to: Actor.self,
                                                       capacity: actorCount)
    pointer = pointer.advanced(by: currentActors)
    for _ in 0..<birthRate {
      let positionX = ad.position.x + .random(in: ad.positionXRange)
      let positionY = ad.position.y + .random(in: ad.positionYRange)
      pointer.pointee.position = [positionX, positionY]
      pointer.pointee.direction = ad.direction + .random(in: ad.directionRange)
      pointer.pointee.speed = ad.speed + .random(in: ad.speedRange)
      pointer.pointee.remainingLife = ad.life + .random(in: ad.lifeRange)
      pointer = pointer.advanced(by: 1)
    }
    currentActors += birthRate
  }
  
  static func loadTexture(imageName: String) -> MTLTexture? {
    let textureLoader = MTKTextureLoader(device: Renderer.device)
    var texture: MTLTexture?
    let textureLoaderOptions: [MTKTextureLoader.Option : Any]
    textureLoaderOptions = [.origin: MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
    do {
      let fileExtension: String? = URL(fileURLWithPath: imageName).pathExtension.count == 0 ? "png" : nil
      if let url: URL = Bundle.main.url(forResource: imageName, withExtension: fileExtension) {
        texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
      } else {
        print("Failed to load \(imageName)")
      }
    } catch let error {
      print(error.localizedDescription)
    }
    return texture
  }
}
