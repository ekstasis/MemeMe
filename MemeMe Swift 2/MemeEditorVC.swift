//
//  MemeEditorVC.swift
//  imageTest
//
//  Created by Ekstasis on 9/16/15.
//  Copyright (c) 2015 Ekstasis. All rights reserved.
//

import UIKit


/* 
* Class Definition
*/
class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // To faclitate keeping text fields within image bounds
    @IBOutlet weak var topTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextToViewWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomTextToViewWidth: NSLayoutConstraint!
    
    var memeIndex : Int?       // nil if not editing existing meme
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
        
        cancelButton.title = "Cancel"
        
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unSubscribeToKeyboardNotification()
    }
    
    func setMemeTextAttributes() {
        
        let memeMeTextAttributes : [String : AnyObject] =
        [
            NSStrokeColorAttributeName:      UIColor.blackColor(),
            NSForegroundColorAttributeName:  UIColor.whiteColor(),
            NSFontAttributeName:             UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName:      -5.0
        ]
        
        topTextField.defaultTextAttributes = memeMeTextAttributes
        bottomTextField.defaultTextAttributes = memeMeTextAttributes
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "Pick a Photo", attributes: memeMeTextAttributes)
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "Share Meme to Save", attributes: memeMeTextAttributes)
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
    
    @IBAction func userCanceledEdit(sender: UIBarButtonItem) {
        // Returns to Sent Memes as per Rubrick unless editing previous meme in which case return to detail view
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showActivity(sender: UIBarButtonItem) {
        
        memedImage = renderMeme()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
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
        
//        appDelegate.saveMemes()
    }
    
    func renderMeme() -> UIImage {
        
        // User hasn't changed text, we don't want placeholder text in image
        if topTextField.text == "" {
            topTextField.placeholder = nil
        }
        if bottomTextField.text == "" {
            bottomTextField.placeholder = nil
        }
        
        
        // Get bounds of album image only.  See UIImageView extension end of file.
        let imageFrame = picView.displayedImageFrame()
        
        // take snapshot of image -- returns a UIView, not an image
        let imageY = imageFrame.origin.y + picView.frame.origin.y
        let imageX = imageFrame.origin.x
        let imageOrigin = CGPoint(x: imageX, y: imageY)
        let imageRect = CGRect(origin: imageOrigin, size: imageFrame.size)
        let renderedImageView = view.resizableSnapshotViewFromRect(imageRect, afterScreenUpdates: true, withCapInsets:  UIEdgeInsetsZero)
        
        // convert snapshot from UIView to UIImage
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, true, 0)
        renderedImageView.drawViewHierarchyInRect(renderedImageView.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func positionTextFields() {
        
        // To deal with incorrect image bounds being reported
        picView.setNeedsLayout()
        picView.layoutIfNeeded()
        
        // Get bounds of album image only.  See UIImageView extension end of file.
        let imageFrame = picView.displayedImageFrame()
        let imageWidth = imageFrame.size.width
        let imageViewWidth = picView.bounds.size.width
        
        topTextToViewWidth.constant = imageViewWidth - imageWidth
        // Bottom text field is first item in constraint unlike top text field
        bottomTextToViewWidth.constant = -topTextToViewWidth.constant
        
        topTextVerticalConstraint.constant = imageFrame.origin.y + 5
        bottomTextVerticalConstraint.constant = -(picView.bounds.height - imageFrame.height) / 2
        bottomTextVerticalConstraint.constant -= 5
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Otherwise positionTextFields tries to deal with nil image
        if picView.image != nil {
            coordinator.animateAlongsideTransition(nil, completion: { context in
                self.positionTextFields() } )
        }
    }
    
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
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
        dismissViewControllerAnimated(true, completion: {
            
            self.positionTextFields()
            
            self.shareButton.enabled = true
            self.topTextField.enabled = true
            self.bottomTextField.enabled = true
        })
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
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRectMake(topLeftX, 0, width, boundsHeight)
            
        } else {
            //image is landscape
            let scale = boundsWidth / imageSize.width
            let height = scale * imageSize.height
            let topLeftY = (boundsHeight - height) * 0.5
            return CGRectMake(0, topLeftY, boundsWidth,height)
        }
    }
}

