//
//  CameraViewController.swift
//  parsestagram
//
//  Created by Isaac Perez on 8/4/21.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Post")
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground { success, error in
            if success{
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            }else{
                print("error!")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        //when user is done
        picker.delegate = self
        //allows editing after photo has been taken
        picker.allowsEditing = true
        //check if camera is available because we are using a simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            //if camer is not availabe use the image library
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
        
    }
    
    //make image show up instead of place holder photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        //resize image
        //choose size
        let size = CGSize(width: 300, height: 300)
        //give scaled image its size
        let scaledImage = image.af_imageScaled(to: size)
        //make image view contain new scaled image
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
