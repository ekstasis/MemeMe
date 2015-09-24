//
//  MemeEditorVC.swift
//  imageTest
//
//  Created by Ekstasis on 9/16/15.
//  Copyright (c) 2015 Ekstasis. All rights reserved.
//

import UIKit

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
    
    var meme : Meme!
    var memedImage : UIImage!
    
    //  ##### DEBUG
    var hideShowCount = 0
    
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotification()
    }
    
    func shouldEnableTopButtons(enabledOrNot: Bool) {
        shareButton.enabled = enabledOrNot
        toggleAspectButton.enabled = enabledOrNot
        cancelButton.enabled = enabledOrNot
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
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            presentViewController(activityVC, animated: true, completion: nil)
        } else {
            let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
            popup.presentPopoverFromBarButtonItem(shareButton, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        }
    }
    
    @IBAction func userCanceledEdit(sender: UIBarButtonItem) {
        picView.image = nil
        topTextField.text = nil
        bottomTextField.text = nil
        
        shouldEnableTopButtons(false)
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
            
            //   ######################## DEBUG
            // view.frame.origin.y = 0
            view.frame.origin.y -= getKeyboardHeight(notification)
            print("\(hideShowCount) : : \(view.frame.origin.y)  Show")
            hideShowCount++
        }
    }
    
    func keyboardWillHide(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            view.frame.origin.y = 0
            print("\(hideShowCount) : : \(view.frame.origin.y)  Hide")
            hideShowCount++
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
    
    func saveMeme() {
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: picView.image!, memedImage: memedImage)
    }
    
    func renderMeme() -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
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
        setAspectMode(.Fit)
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

