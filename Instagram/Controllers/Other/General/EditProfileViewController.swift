//
//  EditProfileViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImage
import FirebaseStorage

struct EditProfileFormModel {
    let label: String
    let placeholder: String
    var value: String?
}


/// Edit Profile View Controller
final class EditProfileViewController: UIViewController {
    
    private let database = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private var tempImage: UIImage?
    
    private var header: UIView = {
        let header = UIView()
        return header
    }()
    
    private var profilePhotoButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()
    
    private var models = [[EditProfileFormModel]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        configureModels()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeaderView()
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureModels() {
        // Name, Username, Website, Bio
        let section1Labels = ["Name", "Bio"]
        let section1placeholders = ["\(UsefulValues.user.name)", "\(UsefulValues.user.bio)"]
        var section1 = [EditProfileFormModel]()
        for i in 0..<section1Labels.count {
            let model = EditProfileFormModel(label: section1Labels[i],
                                             placeholder: "\(section1placeholders[i])",
                                             value: nil)
            section1.append(model)
        }
        models.append(section1)
        
        // Email, Phone, Gender
        let section2Labels = ["Email", "Phone", "Gender"]
        var section2 = [EditProfileFormModel]()
        for label in section2Labels {
            let model = EditProfileFormModel(label: label,
                                             placeholder: "Enter \(label)...",
                                             value: nil)
            section2.append(model)
        }
        models.append(section2)
    }
    
    @objc private func didTapSave() {
        // Save info to database
        var name = models[0][0].value ?? models[0][0].placeholder
        print("Name: \(name)")
        var bio = models[0][1].value ?? models[0][1].placeholder
        print("Bio: \(bio)")
        database.collection("users").document(UsefulValues.user.username).updateData([
            "name" : "\(name)",
            "bio" : "\(bio)"
        ])
        
        if tempImage != nil {
            print("Image can be updated.")
            guard let data = tempImage!.pngData() else {  return }
            self.storage.child("\(UsefulValues.user.username)/\(UsefulValues.user.username).png").putData(data, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    print("Failed to upload because: \(error?.localizedDescription)")
                    return
                }
            }
            self.storage.child("\(UsefulValues.user.username)/\(UsefulValues.user.username).png").downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                UsefulValues.user.profilePhoto = url
                print("New url: \(UsefulValues.user.profilePhoto)")
                self.database.collection("users").document(UsefulValues.user.username).updateData([
                    "profilePhoto" : "\(url)",
                ])
            }
        }
        
        if navigationController == nil {
            dismiss(animated: true)
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    @objc private func didTapCancel() {
        if navigationController == nil {
            dismiss(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            dismiss(animated: true)
        }
        
    }
    
    @objc private func didTapChangeProfilePicture() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "Change profile picture",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default, handler: { _ in
            
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from Library",
                                            style: .default, handler: { _ in
            
            let imagePicker = UIImagePickerController()
            print("IMagePCiker")
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
            
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .default, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        actionSheet.popoverPresentationController?.sourceView = view
        
        present(actionSheet, animated: true)
        
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        tempImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        DispatchQueue.main.async {
            self.profilePhotoButton.setBackgroundImage(self.tempImage, for: .normal)
            print(2)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        
        picker.dismiss(animated: true)
    }
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func createTableHeaderView() -> UIView{
        header = UIView(frame: CGRect(x: 0,
                                      y: 0,
                                      width: view.width,
                                      height: view.height / 4).integral)
        
        let size = header.height / 1.5
        profilePhotoButton = UIButton(frame: CGRect(x: (view.width - size) / 2,
                                                    y: (header.height - size) / 2,
                                                    width: size,
                                                    height: size))
        header.addSubview(profilePhotoButton)
        profilePhotoButton.layer.masksToBounds = true
        profilePhotoButton.layer.cornerRadius = size / 2.0
        profilePhotoButton.addTarget(self, action: #selector(didTapChangeProfilePicture), for: .touchUpInside)

        profilePhotoButton.sd_setBackgroundImage(with: UsefulValues.user.profilePhoto, for: .normal)

        profilePhotoButton.layer.borderWidth = 1
        profilePhotoButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        return header
    }
    
    @objc private func didTapProfilePhoto() {
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier, for: indexPath) as! FormTableViewCell
        
        cell.configure(with: model)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "Private Information"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension EditProfileViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updateModel: EditProfileFormModel) {
        // Update the model
        if updateModel.label == "Name" {
            models[0][0].value = updateModel.value
        } else if updateModel.label == "Bio" {
            models[0][1].value = updateModel.value
        }
        print("Updated: \(updateModel.value ?? "nil")")
    }
}
