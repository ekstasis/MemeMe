//
//  MemeEditorVC.swift
//  imageTest
//
//  Created by Ekstasis on 9/16/15.
//  Copyright (c) 2015 Ekstasis. All rights reserved.
//

import UIKit

extension UIImageView {

    func displayedImageBounds() -> CGRect {
        
        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height
        let imageSize = image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRectMake(topLeftX, 0, width, boundsHeight)
        }
        let scale = boundsWidth / imageSize.width
        let height = scale * imageSize.height
        let topLeftY = (boundsHeight - height) * 0.5
        return CGRectMake(0,topLeftY, boundsWidth,height)
    }
}

class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toggleAspectButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    enum AspectMode {
        case Fill, Fit
    }
    
    var memeIndex : Int?
    var meme : Meme!
    var memedImage : UIImage!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // only slide view up when editing bottom text
    var bottomTextIsBeingEdited = false
    
    // used for toggling aspect fit vs fill
    var aspectMode : AspectMode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        shouldEnableTopButtons(false)
        picView.clipsToBounds = true
        setMemeTextAttributes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        subscribeToKeyboardNotification()
        if let index = memeIndex {
            meme = appDelegate.allMemes[index]
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotification()
    }
    
    func shouldEnableTopButtons(enabledOrNot: Bool) {
        shareButton.enabled = enabledOrNot
        toggleAspectButton.enabled = enabledOrNot
//        cancelButton.enabled = enabledOrNot
    }
    
    func setAspectMode(aspect: AspectMode) {
        
        aspectMode = aspect
        
        switch aspectMode! {
        case .Fit:
            picView.contentMode = UIViewContentMode.ScaleAspectFit
        case .Fill:
            picView.contentMode = UIViewContentMode.ScaleAspectFill
        }
    }
    
    @IBAction func toggleFitFill(sender: UIBarButtonItem) {
        switch aspectMode! {
        case .Fit:
            setAspectMode(.Fill)
        case .Fill:
            setAspectMode(.Fit)
        }
    }
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func showActivity(sender: UIBarButtonItem) {
        
        memedImage = renderMeme()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                self.saveMeme()
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
        
        //        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
        //            presentViewController(activityVC, animated: true, completion: nil)
        //        } else {
        //            let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
        //            popup.presentPopoverFromBarButtonItem(shareButton, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        //        }
    }
    
    func saveMeme() {
        let newMeme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: picView.image!, memedImage: memedImage)
        if let index = memeIndex {
            appDelegate.allMemes[index] = newMeme
        } else {
            appDelegate.allMemes.append(newMeme)
        }
        storeMemes()
    }
    
    func storeMemes() {
       appDelegate.saveMemes()
    }

    func renderMeme() -> UIImage {
        
        // Get bounds of album image only
        let imageBounds = picView.displayedImageBounds()
       
        print("image.size:  \(picView.image!.size)")
        print("imagebounds: \(imageBounds)")
        print("picview bounds: \(picView.bounds)")
        
        UIGraphicsBeginImageContext(imageBounds.size)
        
        // picView contains the album image and fits between top and bottom toolbars 
        picView.drawViewHierarchyInRect(imageBounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("memedimagesize: \(memedImage.size)")
        return memedImage
    }
    
    @IBAction func userCanceledEdit(sender: UIBarButtonItem) {
//        picView.image = nil
//        topTextField.text = nil
//        bottomTextField.text = nil
//        
//        shouldEnableTopButtons(false)
       navigationController?.popViewControllerAnimated(true)
    }
    
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unSubscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            
            view.frame.origin.y = 0
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let notificationInfo = notification.userInfo!
        let keyboardHeight = notificationInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardHeight.CGRectValue().height
    }
    
    func setMemeTextAttributes() {
        let memeMeTextAttributes : [String : AnyObject]  = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -5.0
        ]
        topTextField.defaultTextAttributes = memeMeTextAttributes
        bottomTextField.defaultTextAttributes = memeMeTextAttributes
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "Top", attributes: memeMeTextAttributes)
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "Bottom", attributes: memeMeTextAttributes)
    }
    
    
    
    /*
    *   Delegate Functions
    */
    
    // Image Picker Delegate Functions
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        picView.image = pickedImage
        dismissViewControllerAnimated(true, completion: nil)
        
        shouldEnableTopButtons(true)
//        setAspectMode(.Fit)
    }
    //    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    //
    //        let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
    //        picView.image = pickedImage
    //        dismissViewControllerAnimated(true, completion: nil)
    //
    //        shouldEnableTopButtons(true)
    //        setAspectMode(.Fit)
    //    }
    
    // Text Field Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // Tells keyboardWillShow whether to shift view up
        bottomTextIsBeingEdited = (textField == bottomTextField)
        
        return true
    }
}

