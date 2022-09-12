//
//  ToDoListViewController.swift
//  management
//
//  Created by 조승환 on 2022/07/21.
//

import UIKit



class ToDoListViewController: UIViewController {
   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var ToDoList = [ToDo]() {
        didSet {
            self.saveToDo()
        }
    }

    private let sections : [String] = ["Moo ToDoList"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 244, green: 243, blue: 232, alpha: 0.5)
        self.loadToDo()
//        checkbox.isSelected = UserDefaults.standard.bool(forKey: "Todododo")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func TapaddButton(_ sender: UIButton) {
        guard let detail = inputTextField.text, detail.isEmpty == false else { return }
        guard let title = inputTextField?.text else { return }
        let ToDo = ToDo(title: title, done: false)
        self.ToDoList.append(ToDo)
        self.collectionView.reloadData()
        inputTextField.text = ""
        
        
    }
    
    @IBAction func tapBG(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
    
    
    @objc private func adjustInputView(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        if notification.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            inputViewBottom.constant = adjustmentHeight
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
        } else {
            inputViewBottom.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
        }
    }
    
    private func saveToDo() {
      let data = self.ToDoList.map {
        [
          "title": $0.title,
          "done": $0.done,
        ]
      }
      let userDefaults = UserDefaults.standard
      userDefaults.set(data, forKey: "Tododo")
    }
    private func loadToDo() {
      let userDefaults = UserDefaults.standard
      guard let data = userDefaults.object(forKey: "Tododo") as? [[String: Any]] else { return }
      self.ToDoList = data.compactMap {
        guard let title = $0["title"] as? String else { return nil }
        guard let done = $0["done"] as? Bool else { return nil }
          return ToDo(title: title, done: done)
      }
    }
}


    

extension ToDoListViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ToDoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToDoListCell", for: indexPath) as? ToDoListCell else { return UICollectionViewCell() }
       
        
        
        var todo = self.ToDoList[indexPath.row]
        cell.checkBox.isSelected = todo.done
        cell.titleLabel.text = todo.title
        cell.titleLabel.alpha = todo.done ? 0.2 : 1
        cell.DeleteBox.isHidden = todo.done == false
        cell.showcheckline(todo.done)

            cell.doneButtonTap = { done in

                todo.done = !todo.done
                self.ToDoList[indexPath.row] = todo
                self.collectionView.reloadData()
                
        }

        cell.deleteButtonTap = {
            self.ToDoList.remove(at: indexPath.row)
            self.collectionView.reloadData()
        }
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader :
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ToDoHeaderView", for: indexPath)
            return headerView
        default:
            assert(false, "")
        }
    }

}

extension ToDoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 50
        return CGSize(width: width, height: height)
    }
}


class ToDoListCell: UICollectionViewCell {
    @IBOutlet var checkBox: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var DeleteBox: UIButton!
    @IBOutlet var checkline: UIView!
    @IBOutlet weak var checklineWidth: NSLayoutConstraint!
    
    
    var doneButtonTap: ((Bool) -> Void)?
    var deleteButtonTap: (() -> Void)?
    
   
    

    
    func showcheckline(_ show: Bool) {
        if show {
            checklineWidth.constant = 250
        } else {
            checklineWidth.constant = 0
        }
    }
   
    
    @IBAction func checkButton(_ sender: Any) {
        checkBox.isSelected = !checkBox.isSelected
        let done = checkBox.isSelected
        showcheckline(done)
        titleLabel.alpha = done ? 0.2 : 1
        DeleteBox.isHidden = !done
        
        
        doneButtonTap?(done)
    }
    @IBAction func deleteButton(_ sender: Any) {
       deleteButtonTap?()
    }
 }


