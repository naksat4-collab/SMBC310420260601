import Foundation
import Vision
import AppKit

guard CommandLine.arguments.count > 1 else {
    print("Please provide an image path")
    exit(1)
}

let imagePath = CommandLine.arguments[1]
let url = URL(fileURLWithPath: imagePath)

guard let image = NSImage(contentsOf: url),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to load image")
    exit(1)
}

let imageWidth = CGFloat(cgImage.width)
let imageHeight = CGFloat(cgImage.height)

let request = VNRecognizeTextRequest { request, error in
    guard let observations = request.results as? [VNRecognizedTextObservation] else {
        return
    }
    
    for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { continue }
        
        let string = topCandidate.string
        // Vision's coordinate system has origin at bottom-left
        let boundingBox = observation.boundingBox
        let x = boundingBox.minX * imageWidth
        let y = (1 - boundingBox.maxY) * imageHeight
        let width = boundingBox.width * imageWidth
        let height = boundingBox.height * imageHeight
        
        print(String(format: "Text: %@ | Rect: x: %.1f, y: %.1f, w: %.1f, h: %.1f", string, x, y, width, height))
    }
}

request.recognitionLevel = .accurate
request.recognitionLanguages = ["ja", "en"]
request.usesLanguageCorrection = true

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
do {
    try handler.perform([request])
} catch {
    print("Failed to perform OCR: \(error)")
}
