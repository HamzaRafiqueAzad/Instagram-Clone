//
//  CameraViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import AVFoundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

class CameraViewController: UIViewController {
    
    let storage = Storage.storage().reference()
    
    let database = Database.database().reference()
    
    private let captureButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .thin, scale: .large)
        button.setImage(UIImage(systemName: "record.circle", withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let previewView = PreviewView()
    
    var captureSession = AVCaptureSession()
    var backCam : AVCaptureDevice!
    var frontCam : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    var photoOutput = AVCapturePhotoOutput()
    var backCamOn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath.camera"), style: .done, target: self, action: #selector(didTapSwitch))
        
        // Do any additional setup after loading the view.
//        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(previewView)
        view.addSubview(captureButton)
        captureButton.addTarget(self, action: #selector(didTapTakePicture), for: .touchUpInside)
        
        setupVideo()
        setupAudio()
        
        self.previewView.videoPreviewLayer.session = self.captureSession
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        captureButton.frame = CGRect(x: (tabBarController?.tabBar.center.x)! - 42,
                                     y: (tabBarController?.tabBar.top)! - 75,
                                     width: 80,
                                     height: 75)
        previewView.frame = CGRect(x: 0, y: -80, width: view.width, height: view.height)
        
        
    }
    
    func setupAudio() {
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if captureSession.canAddInput(audioInput) {
                
                captureSession.addInput(audioInput)
            }
        } catch {
            print("Error")
        }
    }
    
    func setupVideo() {
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCam = device
        } else {
            fatalError("Back camera not found.")
        }
        
        //get front camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCam = device
        } else {
            fatalError("Front camera not found.")
        }
        
        //now we need to create an input objects from our devices
        guard let bInput = try? AVCaptureDeviceInput(device: backCam) else {
            fatalError("could not create input device from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCam) else {
            fatalError("could not create input device from front camera")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        //connect back camera input to session
        captureSession.addInput(backInput)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            captureSession.startRunning()
            print("MovieFileOutput Added.")
        }
        
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.previewView.videoPreviewLayer.session = self.captureSession
        
    }
    
    @objc private func didTapSwitch() {
        captureSession.beginConfiguration()
        
        if backCamOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCamOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCamOn = true
        }
        
        captureSession.commitConfiguration()
        
    }
    
    @objc private func didTapTakePicture() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        let previewImage = UIImage(data: imageData)
        
        print("Photo taken.")
        
        guard let data = previewImage?.pngData() else {  return }
        
        DispatchQueue.main.async {
            self.storage.child("\(UsefulValues.user.username)/\(UsefulValues.user.counts.posts+1).heic").putData(data, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    print("Failed to upload because: \(error?.localizedDescription)")
                    return
                }
                
                print("Photo Uploaded.")
                
                do {
                    UsefulValues.user.counts.posts += 1
                    let user = try PropertyListEncoder().encode(UsefulValues.user)
                    UserDefaults.standard.setValue(user, forKey: "user")
                } catch {
                    
                }
                
                self.storage.child("\(UsefulValues.user.username)/\(UsefulValues.user.counts.posts).heic").downloadURL { url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("Url: \(urlString)")
                }
            }
        }
        
        
    }
    
}
