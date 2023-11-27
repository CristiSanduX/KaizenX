//
//  PhotoPicker.swift
//  KaizenX
//
//  Created by Cristi Sandu on 27.11.2023.
//

import SwiftUI
import UIKit

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var didSelectImage: () -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // Permite utilizatorilor să editeze imaginea - inclusiv crop.
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage {
                // Aici avem imaginea cropată pe care utilizatorul a selectat-o.
                parent.selectedImage = image
                parent.didSelectImage()
            } else if let image = info[.originalImage] as? UIImage {
                // Dacă utilizatorul nu a decis să editeze imaginea, folosim originalul.
                parent.selectedImage = image
                parent.didSelectImage()
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
