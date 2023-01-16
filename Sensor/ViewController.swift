//
//  ViewController.swift
//  Sensor
//
//  Created by 숙명pc on 2023/01/15.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    //Capture Session
    var session: AVCaptureSession?
    //AVCaptureSession은 클래스이다.
    //capture activity 를 다루며 input device 에서 outputs을 capture 할 수 있도록 데이터의 흐름을 관리하는 object 이다.
    
    //Photo Output
    let output = AVCapturePhotoOutput()
    
    //Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    //Shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        button.layer.cornerRadius = 50
        //view의 모서리를 둥글게 만들 때
        
        button.layer.borderWidth = 10
        //view의 테두리를 만들 때
        
        button.layer.borderColor = UIColor.white.cgColor
        //view의 테두리를 만들 때
        
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        previewLayer.backgroundColor = UIColor.systemRed.cgColor
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        checkCameraPermissions()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
    }
    private func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
            //Request permission
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            //give permission
            setUpCamera()
        @unknown default:
             break
        }
    }
    
    private func setUpCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            //디바이스 카메라의 어떤 부분 쓸건지 지정해주고
            
            do{
                let input = try AVCaptureDeviceInput(device: device)
                    //실제 기기에서도 사용 가능하면, 우리가 인풋으로 받아들일 카메라를 지정
                
                if session.canAddInput(input){
                    session.addInput(input)
                }
                //그 이후로는 CanAddInput을 통해 세션에 넣을 수 있는지 물어본 다음에 (실패할 수 있는 작업이여서 먼저 물어보는게 우선)
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            }
            catch{
                print(error)
            }
        }
    }
    @objc private func didTapTakePhoto(){
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

}
extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}

