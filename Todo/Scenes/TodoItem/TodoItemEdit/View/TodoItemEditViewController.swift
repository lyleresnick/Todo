//  Copyright (c) 2018 Lyle Resnick. All rights reserved.

import UIKit

class TodoItemEditViewController: UIViewController {
    
    var presenter: TodoItemEditPresenter!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        TodoItemEditConnector(viewController: self).configure()
    }
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var completeBySwitch: UISwitch!
    @IBOutlet weak var completeByLabel: BackingInputViewLabel!
    @IBOutlet weak var completeByPickerView: DatePickerView!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var completedSwitch: UISwitch!

    private var titleTextFieldDelegate: TodoItemEditTitleTextFieldDelegate!
    private var noteTextViewDelegate: TodoItemEditNoteTextViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextFieldDelegate = TodoItemEditTitleTextFieldDelegate(presenter: presenter)
        titleTextField.delegate = titleTextFieldDelegate
        
        noteTextViewDelegate = TodoItemEditNoteTextViewDelegate(presenter: presenter)
        noteTextView.delegate = noteTextViewDelegate
        
        completeByLabel.inputView = completeByPickerView
        
        presenter.eventViewReady()
    }
    
    @IBAction func completeByLabelTouched(_ sender: Any) {
        presenter.eventEnableEditCompleteBy()
    }
    
    @IBAction func completeBySwitchTouched(_ sender: UISwitch) {
        
        if sender.isOn {
            presenter.eventCompleteByToday()
        }
        else {
            presenter.eventCompleteByClear()
        }
    }
    
    @IBAction func priorityTouched(_ sender: UISegmentedControl) {
        presenter.eventEditedPriority(index: sender.selectedSegmentIndex)
}
    
    @IBAction func completedTouched(_ sender: UISwitch) {
        presenter.event(completed: sender.isOn)
    }
    
    @IBAction func saveTouched(_ sender: UIBarButtonItem) {
        
        view.endEditing(true)
        presenter.eventSave()
    }
    
    @IBAction func cancelTouched(_ sender: UIBarButtonItem) {
        
        presenter.eventCancel()
    }
    
    @IBAction func completeByCancelTouched(_ sender: UIButton) {
        completeByLabel.resignFirstResponder()
    }
    
    @IBAction func completeBySetTouched(_ sender: UIButton) {
        
        presenter.eventEdited(completeBy: completeByPickerView.date! )
        completeByLabel.resignFirstResponder()
    }
    
    @IBAction func mainViewTouched(_ sender: Any) {
        view.endEditing(true)
    }
}

extension TodoItemEditViewController: TodoItemEditPresenterOutput {}

extension TodoItemEditViewController: TodoItemEditViewReadyPresenterOutput {
    
    func show(model: TodoItemEditViewModel, titlePlaceholder: String, priorityLabels: [String]) {
        
        DispatchQueue.main.async {
            self.titleTextField.placeholder = titlePlaceholder
            for (index, title) in priorityLabels.enumerated() {
                self.prioritySegmentedControl.setTitle(title, forSegmentAt: index)
            }
            self.titleTextField.text = model.title
            self.noteTextView.text = model.note
            self.completeBySwitch.isOn = (model.completeByAsString != "")
            self.completeByLabel.text = model.completeByAsString
            self.prioritySegmentedControl.selectedSegmentIndex =  model.priority
            self.completedSwitch.isOn = model.completed
        }
    }
}

extension TodoItemEditViewController: TodoItemEditCompleteByPresenterOutput {
    
    func showCompleteByClear() {
        
        DispatchQueue.main.async {
            self.completeByLabel.text = ""
            self.completeByLabel.resignFirstResponder()
        }
    }
    
    func showEnableEdit(completeBy: Date?) {
        
        DispatchQueue.main.async {
            self.completeByPickerView.date = completeBy
            self.completeByLabel.becomeFirstResponder()
        }
    }
    
    func show(completeBy: String) {
        
        DispatchQueue.main.async {
            self.completeByLabel.text = completeBy
        }
    }
}

extension TodoItemEditViewController: TodoItemEditSavePresenterOutput {
    
    func showAlert(alertTitle: String, message: String, actionTitle: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}





