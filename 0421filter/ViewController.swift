//
//  ViewController.swift
//  0421filter
//
//  Created by 이성근 on 21/04/2020.
//  Copyright © 2020 Draw_corp. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    var originalImage : UIImage?
    var filterImage : UIImage?

    @IBOutlet weak var imgView: UIImageView!

    @IBOutlet weak var take: UIButton!
    @IBOutlet weak var seuge: UISegmentedControl!

    //이미지뷰 두번터치시 초기화
    @IBAction func handledoubleTab(_ sender: UITapGestureRecognizer) {
        // 터치가 끝나면 초기화
        if sender.state == .ended {
            originalImage = nil
            filterImage = nil
            imgView.image = nil
            seuge.selectedSegmentIndex = 0
        }
    }
    // 이미지뷰 길게 눌렀을떄 오리지널 이미지 보여주기
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {

        switch sender.state {
        case .began:
            seuge.selectedSegmentIndex = 0
            imgView.image = originalImage
        case .ended:
            imgView.image = filterImage
            seuge.selectedSegmentIndex = 1
        default:
            return
        }
    }

    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            imgView.image = originalImage
        }else {
            imgView.image = filterImage
        }
    }

    @IBAction func takeAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeImage as String]  // 사지만 가져오게 할수있음
            controller.allowsEditing = false
            controller.delegate = self

            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func pickAction(_ sender: Any) {
        // imagePicker는 무조건 코딩으로
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let controller = UIImagePickerController()
            controller.sourceType = .photoLibrary
            controller.mediaTypes = [kUTTypeImage as String]  // 사진만 가져오게 할수있음
            controller.allowsEditing = false
            controller.delegate = self

            present(controller, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    // imegePresent Cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // 필터적용하기
    func applyFilter(source : UIImage) {
        // 이미지를 UIImage -> cgImage 로 변경
        guard let cgImage = source.cgImage else {return}
        // opengl을 이용하여 cgImage -> CIImage 로 변경
        guard let openGlContext = EAGLContext(api: .openGLES2) else {return}
        let context = CIContext(eaglContext: openGlContext)
        let ciImage = CIImage(cgImage: cgImage)

        // 필터명을 적는다
        let filter =  CIFilter(name: "CIPhotoEffectNoir")
        // 필터 셋팅
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
//        let filter2 = CIFilter(name: "CIVignette")
//          다른 필터 적용
//        filter2?.setValue(filter?.outputImage, forKey: kCIInputImageKey)
//        filter2?.setValue(0.6, forKey: kCIInputIntensityKey)
//        filter2?.setValue(1.62, forKey: kCIInputRadiusKey)

        if let output = filter?.outputImage , let resulet = context.createCGImage(output, from: output.extent){
            filterImage = UIImage(cgImage: resulet)
            seuge.selectedSegmentIndex = 1
            imgView.image = filterImage
        }
    }

    //image select
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let type = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if type == kUTTypeImage as String {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    let nomalized = image.fixOrigentaion()
                    originalImage = nomalized
                    applyFilter(source: nomalized) // 필터적용 메서드호출
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func fixOrigentaion() -> UIImage {
        //사진이 up상태에서 찍엇을경우는 리턴
        if imageOrientation == .up {
            return self
        }
        // 그외 사진은 다시그린다.
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        if let nomalizedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return nomalizedImage
        } else {
            return self
        }
    }
}
