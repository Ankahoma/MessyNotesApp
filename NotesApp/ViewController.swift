//
//  ViewController.swift
//  NotesApp
//
//  Created by Анна Вертикова on 23.12.2022.
//

import UIKit
import CoreData

var notesList = [NotesItem]()
var firstLoad = true


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let thisNote: NotesItem!
        thisNote = notesList[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM y, HH:mm"
        
        noteCell.textLabel?.text = thisNote.noteTitle
        if thisNote.createdAt != nil {
            noteCell.detailTextLabel?.text = formatter.string(from: thisNote.createdAt!)
        }
        
        return noteCell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        table.delegate = self
        table.dataSource = self
        
        
        if(firstLoad) {  // fetch data from context if first load on known simulator
            firstLoad = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotesItem")
            
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! NotesItem
                    notesList.append(note)
                }
            } catch {
                print("Fetch Failed")
            }
            
            if notesList.isEmpty {  // if new simulator
                
                let titleField = "Привет, ШИФТ! =)"
                let noteField = NSAttributedString(string: "Хочу к вам в команду!", attributes: [.font: UIFont.systemFont(ofSize: 17)])
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "NotesItem", in: context)
                let newNote = NotesItem(entity: entity!, insertInto: context)
                
                newNote.noteTitle = titleField
                newNote.noteBody = noteField
                newNote.createdAt = Date()
                
                do {
                    try context.save()
                    notesList.append(newNote)
                } catch {
                    print("Save Failed")
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            let item = notesList[indexPath.row]
            notesList.remove(at: indexPath.row)
            context.delete(item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do {
                try context.save()
            } catch {
                print("Save Failed")
            }
            
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
            
            let indexPath = table.indexPathForSelectedRow!
            let noteDetail = segue.destination as? EntryViewController
            let selectedNoteLocal: NotesItem!
            selectedNoteLocal = notesList[indexPath.row]
            noteDetail!.selectedNote = selectedNoteLocal
            
            table.deselectRow(at: indexPath, animated: true)
        }
    }
}



