//
//  CameraCapture.swift
//  GlowFit
//
//  غلاف SwiftUI حول UIImagePickerController لالتقاط صورة مباشرة من الكاميرا.
//  (PhotosPicker بتاع iOS 16 ما بيدعم التقاط كاميرا مباشرة، بس اختيار من المعرض)
//

import SwiftUI
import UIKit

struct CameraCapture: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front // كاميرا أمامية افتراضياً، مناسبة لصور الوجه
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCapture

        init(_ parent: CameraCapture) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

/// يتأكد إن الكاميرا فعلياً متوفرة على الجهاز (مش متوفرة أبداً بالمحاكي/Simulator)
enum CameraAvailability {
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}
