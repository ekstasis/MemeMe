//
//  MemeEditorVC.swift
//  imageTest
//
//  Created by Ekstasis on 9/16/15.
//  Copyright (c) 2015 Ekstasis. All rights reserved.
//

import UIKit

/*
* Extension that gives bounds of the image that was picked from album/camera
*/
extension UIImageView {
    
    func displayedImageFrame() -> CGRect {
        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height
        let imageSize = image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        
        // image is portrait
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
        //  because image above was grainy, try drawView technique again
//            let topLeftX = CGFloat(0.0)
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRectMake(topLeftX, 0, width, boundsHeight)
        } else {
            //image is landscape
            let scale = boundsWidth / imageSize.width
            let height = scale * imageSize.height
        //  because image above was grainy, try drawView technique again
//            let topLeftY = CGFloat(0.0)
            let topLeftY = (boundsHeight - height) * 0.5
            return CGRectMake(0, topLeftY, boundsWidth,height)
        }
    }
}

// CLASS
class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // To faclitate positioning text fields within image bounds
    @IBOutlet weak var topTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextVerticalConstraint: NSLayoutConstraint!
    
    var memeIndex : Int? // nil if not editing existing meme
    var memedImage : UIImage!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // only slide view up when editing bottom text
    var bottomTextIsBeingEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        setMemeTextAttributes()
        
        // Load existing meme
        if let index = memeIndex {
            let meme = appDelegate.allMemes[index]
            picView.image = meme.image
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
        } else {
            // Don't allow text editing until image chosen for new meme
            topTextField.enabled = false
            bottomTextField.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        shareButton.enabled = (picView.image != nil)
        
        subscribeToKeyboardNotification()
        
            cancelButton.title = "Cancel"
        
        if picView.image != nil {
            positionTextFields()
            cancelButton.enabled = true
        } else {
            cancelButton.enabled = false
        
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unSubscribeToKeyboardNotification()
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
    
//    func hideTextFields(trueOrNot: Bool) {
//        topTextField.hidden = trueOrNot
//        bottomTextField.hidden = trueOrNot
//    }
    
    func positionTextFields() {
        
//        hideTextFields(true)
        
        // To fix to deal with incorrect image bounds being reported
        picView.setNeedsLayout()
        picView.layoutIfNeeded()
        
        let imageFrame = picView.displayedImageFrame()
        
        topTextVerticalConstraint.constant = 0
        bottomTextVerticalConstraint.constant = 0
        
        topTextVerticalConstraint.constant = imageFrame.origin.y
        bottomTextVerticalConstraint.constant = -(picView.bounds.height - imageFrame.height) / 2
        
//        hideTextFields(false)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition(nil, completion: { context in
            self.positionTextFields() } )
    }
    
    @IBAction func showActivity(sender: UIBarButtonItem) {
        
        memedImage = renderMeme()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                self.cancelButton.enabled = true
                self.saveMeme()
                self.cancelButton.title = "Done"
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
        
        // TODO:  Make this work for iPad
    }
    
    func saveMeme() {
        
        let newMeme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: picView.image!, memedImage: memedImage)
        
        if let index = memeIndex {
            appDelegate.allMemes[index] = newMeme     // resave edited meme
        } else {
            appDelegate.allMemes.append(newMeme)      // new meme
        }
        
        appDelegate.saveMemes()
    }
    
    func renderMeme() -> UIImage {
        
        // Get bounds of album image only
        let imageSize = picView.displayedImageFrame()
        
       //  because image above was grainy, try drawView technique again
        UIGraphicsBeginImageContext(imageBounds.size)
        picView.bounds = imageBounds
        picView.drawViewHierarchyInRect(imageBounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
          // take snapshot of image -- returns a UIView, not an image
//        let imageY = imageFrame.origin.y + picView.frame.origin.y
//        let imageX = imageFrame.origin.x
//        let imageOrigin = CGPoint(x: imageX, y: imageY)
//        let imageRect = CGRect(origin: imageOrigin, size: imageFrame.size)
//        let renderedImageView = view.resizableSnapshotViewFromRect(imageRect, afterScreenUpdates: true, withCapInsets:  UIEdgeInsetsZero)
//        
//        // convert snapshot UIView to UIImage
//        UIGraphicsBeginImageContext(imageFrame.size)
//        renderedImageView.drawViewHierarchyInRect(renderedImageView.bounds, afterScreenUpdates: true)
//        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
       
        
        
        return memedImage
    }
    
    @IBAction func userCanceledEdit(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // To deal with sliding view up AND positioning text again when done
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func unSubscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            view.frame.origin.y = 0
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if bottomTextIsBeingEdited {
            positionTextFields()
        }
    }
    
    func keyboardWillHide(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            view.frame.origin.y = 0
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        positionTextFields()
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let notificationInfo = notification.userInfo!
        let keyboardFrame = notificationInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardFrame.CGRectValue().height
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
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "Pick a Photo", attributes: memeMeTextAttributes)
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "Share Meme to Save", attributes: memeMeTextAttributes)
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
        
        positionTextFields()
        
        shareButton.enabled = true
        topTextField.enabled = true
        bottomTextField.enabled = true
        cancelButton.enabled = true
    }
    
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

