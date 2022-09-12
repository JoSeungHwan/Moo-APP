//
//  MemoSelectViewController.swift
//  management
//
//  Created by 조승환 on 2022/07/21.
//

import UIKit

protocol MemoSelectViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
}

class memoSelectViewController: UIViewController {

    let memoList = [Memo]()
    
    var memo: Memo?
    var indexPath: IndexPath?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    weak var delegate: MemoSelectViewDelegate?
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()

    }
    private func configureView() {
      guard let memo = self.memo else { return }
      self.titleLabel.text = memo.title
      self.contentLabel.text = memo.contents
      self.dateLabel.text = self.dateToString(date: memo.date)
    }
    
    @IBAction func tapEditbutton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "memoViewController") as? memoViewController else { return }
        guard let indexPath = indexPath else { return }
        guard let memo = self.memo else { return }
        viewController.memoEditorMode = .edit(indexPath, memo)
        NotificationCenter.default.addObserver(self, selector: #selector(editMemoNotification(_:)), name: NSNotification.Name("editMemo"), object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
            


    }
    
    @IBAction func TapDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.memo?.uuidString else { return }
        NotificationCenter.default.post(
          name: NSNotification.Name("deleteMemo"),
          object: uuidString,
          userInfo: nil
        )
        self.navigationController?.popViewController(animated: true)
      }
    
    @objc func editMemoNotification(_ notification: Notification) {
      guard let memo = notification.object as? Memo else { return }
      self.memo = memo
      self.configureView()
    }
        
    @objc func starMemoNotification(_ notifcation: Notification) {
        guard let memo = notifcation.object as? Memo else { return }
        self.memo = memo
        self.configureView()
    }

    private func dateToString(date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
      formatter.locale = Locale(identifier: "ko_KR")
      return formatter.string(from: date)

    }
    deinit {
      NotificationCenter.default.removeObserver(self)
    }
}
extension UITextView {
    func setTextView() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
    }
}
