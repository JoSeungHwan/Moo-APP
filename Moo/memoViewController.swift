//
//  memoViewController.swift
//  management
//
//  Created by 조승환 on 2022/07/21.
//

import UIKit

enum MemoEditorMode {
    case new
    case edit(IndexPath, Memo)
}

protocol memoViewDelegate: AnyObject {
    func didSelectReigstar(memo: Memo)
}

class memoViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextField: UITextView!
    @IBOutlet var datepickerTextField: UITextField!
    @IBOutlet var registrationButton: UIBarButtonItem!
    
    let datePicker = UIDatePicker()
    var memoDate : Date?
    weak var delegate: memoViewDelegate?
    var memoEditorMode : MemoEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurelayer()
        configureDatePicker()
        registrationButton.isEnabled = false
        inputField()
        configureEditMode()
    }
    
    private func configureEditMode() {
        switch self.memoEditorMode {
            case let .edit(_, memo):
            self.titleTextField.text = memo.title
            self.contentTextField.text = memo.contents
            self.datepickerTextField.text = self.dateToString(date: memo.date)
            self.memoDate = memo.date
            self.registrationButton.title = "수정"
            
        default:
          break
      }
    }
    private func dateToString(date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
      formatter.locale = Locale(identifier: "ko_KR")
      return formatter.string(from: date)
    }
    func emptytextField() {
        registrationButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.datepickerTextField.text?.isEmpty ?? true) && !self.contentTextField.text.isEmpty
    }
    func inputField() {
        contentTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(titleinPutField(_:)), for: .editingChanged)
        datepickerTextField.addTarget(self, action: #selector(dateinputField(_:)), for: .editingChanged)
    }
    @objc func titleinPutField(_ textField: UITextField) {
        self.emptytextField()
    }
    @objc func dateinputField(_ textField: UITextField) {
        self.emptytextField()
    }
    

    func configurelayer() {
        let bordercoloer = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 220/255)
        contentTextField.layer.borderColor = bordercoloer.cgColor
        contentTextField.layer.borderWidth = 0.5
        contentTextField.layer.cornerRadius = 5.0
    }
    func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        datePicker.locale = Locale(identifier: "ko-KR")
        datepickerTextField.inputView = self.datePicker
    }
    @objc func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        self.memoDate = datePicker.date
        self.datepickerTextField.text = formmater.string(from: datePicker.date)
        self.datepickerTextField.sendActions(for: .editingChanged)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    @IBAction func tepRegistrationbutton(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text else { return }
        guard let contents = contentTextField.text else { return }
        guard let date = memoDate else { return }

        switch self.memoEditorMode {
            case .new:
            let memo = Memo(
            uuidString: UUID().uuidString,
            title: title,
            contents: contents,
            date: date
            )
          self.delegate?.didSelectReigstar(memo: memo)
        
        case let .edit(indexPath, memo):
          let memo = Memo(
            uuidString: memo.uuidString,
            title: title,
            contents: contents,
            date: date
          )
          NotificationCenter.default.post(
            name: NSNotification.Name("editMemo"),
            object: memo,
            userInfo: [
                "indexPath.row": indexPath.row
            ]
            )
            }
            
        navigationController?.popViewController(animated: true)
        
    }
}
extension memoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        emptytextField()
    }
}

