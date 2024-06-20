//
//  UIImage+GIF.swift
//  KaizenX
//
//  Created by Cristi Sandu on 02.06.2024.
//
//
//  UIImage+GIF.swift
//  KaizenX
//
//  Created by Cristi Sandu on 02.06.2024.
//
import SwiftUI
import UIKit
import ImageIO

struct GIFImageView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.loadGif(from: url)
    }
}

extension UIImageView {
    func loadGif(from url: URL) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                let image = UIImage.gif(data: data)
                self.image = image
            }
        }
    }
}

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        var images = [UIImage]()
        var duration: TimeInterval = 0.0
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                   let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval {
                    duration += delayTime
                }
            }
        }
        // Ajustează durata totală a GIF-ului pentru a încetini animația
        duration = duration * 1.5
        if duration == 0.0 {
            duration = 1.0
        }
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
