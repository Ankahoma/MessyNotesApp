//
//  EntryViewController.swift
//  NotesApp
//
//  Created by Анна Вертикова on 23.12.2022.
//
import UIKit
import CoreData



class EntryViewController: UIViewController, UIColorPickerViewControllerDelegate,
                           UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var selectedNote: NotesItem? = nil
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var noteField: UITextView!
    
    @IBAction func SaveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if selectedNote == nil {  // add new note
            
            let entity = NSEntityDescription.entity(forEntityName: "NotesItem", in: context)
            let newNote = NotesItem(entity: entity!, insertInto: context)
            
            if let text = titleField.text, !text.isEmpty, !noteField.text!.isEmpty {
                newNote.noteTitle = titleField.text
                newNote.noteBody = noteField.attributedText
                newNote.createdAt = Date()
                if let imageData = imageView.image?.pngData() {
                    newNote.noteImage = imageData
                }
                
                do {
                    try context.save()
                    notesList.append(newNote)
                    navigationController?.popViewController(animated: true)
                } catch {
                    print("Save Failed")
                }
            }
        } else {  // edit existing note
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotesItem")
            
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! NotesItem
                    if note == selectedNote {
                        note.noteTitle = titleField.text
                        note.noteBody = noteField.attributedText
                        note.createdAt = Date()
                        if let imageData = imageView.image?.pngData() {
                            note.noteImage = imageData
                        }
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
                
            } catch {
                print("Fetch Failed")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(selectedNote != nil) {
            titleField.text = selectedNote?.noteTitle
            noteField.attributedText = selectedNote?.noteBody
            if let imageData = selectedNote?.noteImage as? NSData {
                if let image = UIImage(data:imageData as Data) {
                    imageView.image = image
                }
            }
        } else {
            noteField.delegate = self
            placeholderLabel = UILabel()
            placeholderLabel.text = "Enter Note"
            placeholderLabel.textColor = UIColor.lightGray
            placeholderLabel.font = .systemFont(ofSize: (noteField.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            noteField.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (noteField.font?.pointSize)! / 2)
            placeholderLabel.textColor = .tertiaryLabel
            placeholderLabel.isHidden = !noteField.text.isEmpty
            titleField.placeholder = "Enter Title"
        }
        
        titleField.allowsEditingTextAttributes = true;
        noteField.allowsEditingTextAttributes = true;
        
        // keyboard panel for Color, Attach Imaage and Done buttons
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0,
                                              width: view.frame.size.width,
                                              height: 50))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: self,
                                            action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                         target: self,
                                         action: #selector(DoneAction))
        let colorButton = UIBarButtonItem(title: "Color", style: .plain,
                                          target: self,
                                          action: #selector(ColorTextAction))
        let attachImageButton = UIBarButtonItem(title: "Attach Image", style: .done,
                                                target: self,
                                                action: #selector(AttachImageAction))
        
        let colorAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 16)]
        colorButton.setTitleTextAttributes(colorAttributes, for: .normal)
        
        
        toolBar.items = [colorButton, attachImageButton, flexibleSpace,  doneButton]
        toolBar.sizeToFit()
        titleField.inputAccessoryView = toolBar
        noteField.inputAccessoryView = toolBar
    }
    
    @objc func DoneAction() {
        titleField.resignFirstResponder()
        noteField.resignFirstResponder()
    }
    
    @objc func AttachImageAction() {
        let showImage = UIImagePickerController()
        showImage.sourceType = .photoLibrary
        showImage.delegate = self
        showImage.allowsEditing = true
        present(showImage, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        imageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func ColorTextAction() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let textColor = viewController.selectedColor
        
        if let text = noteField {
            let range = text.selectedRange
            let string = NSMutableAttributedString(attributedString:
                                                    noteField.attributedText)
            let colorAttribute = [NSAttributedString.Key.foregroundColor: textColor]
            
            string.addAttributes(colorAttribute, range: noteField.selectedRange)
            noteField.attributedText = string
            noteField.selectedRange = range
            
        }
    }
}

extension EntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !noteField.text.isEmpty
    }
}





