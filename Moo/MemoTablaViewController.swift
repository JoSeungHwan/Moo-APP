//
//  MemoTablaViewController.swift
//  management
//
//  Created by 조승환 on 2022/07/21.
//

import UIKit

class memoTableViewController: UITableViewController {
    
    

    @IBOutlet var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem?
    
    private var memoList = [Memo]() {
      didSet {
        self.saveMemoList()
      }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemoList()
        self .doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donebuttonTap))
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(editMemoNotification(_:)),
          name: NSNotification.Name("editMemo"),
          object: nil
        )
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(deleteDiaryNotification(_:)),
          name: Notification.Name("deleteMemo"),
          object: nil
        )
    }
    
    @objc func editMemoNotification(_ notification: Notification) {
      guard let memo = notification.object as? Memo else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
      self.memoList[row] = memo
      self.memoList = self.memoList.sorted(by: {
          $0.date.compare($1.date) == .orderedDescending
      })
      self.tableView.reloadData()
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.memoList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.memoList.remove(at: index)
        self.tableView.reloadData()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        tableView.rowHeight = 120
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as? memoCell else { return UITableViewCell() }
        let memo = self.memoList[indexPath.row]
        cell.titleLabel.text = memo.title
        cell.dateLabel.text = self.dateToString(date: memo.date)
        return cell
      }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewContoller = self.storyboard?.instantiateViewController(identifier: "memoSelectViewController") as? memoSelectViewController else { return }
        let memo = self.memoList[indexPath.row]
        viewContoller.memo = memo
        viewContoller.indexPath = indexPath
        self.navigationController?.pushViewController(viewContoller, animated: true)
    }
    
    private func saveMemoList() {
      let date = self.memoList.map {
        [
          "uuidString": $0.uuidString,
          "title": $0.title,
          "contents": $0.contents,
          "date": $0.date,
        ]
      }
      let userDefaults = UserDefaults.standard
      userDefaults.set(date, forKey: "memoList")
    }
    
    private func loadMemoList() {
      let userDefaults = UserDefaults.standard
      guard let data = userDefaults.object(forKey: "memoList") as? [[String: Any]] else { return }
      self.memoList = data.compactMap {
        guard let uuidString = $0["uuidString"] as? String else { return nil}
        guard let title = $0["title"] as? String else { return nil }
        guard let contents = $0["contents"] as? String else { return nil }
        guard let date = $0["date"] as? Date else { return nil }
        return Memo(uuidString: uuidString, title: title, contents: contents, date: date)
      }
      self.memoList = self.memoList.sorted(by: {
        $0.date.compare($1.date) == .orderedDescending
      })
    }
    
    @IBAction func TapEditButton(_ sender: UIBarButtonItem) {
        guard !self .memoList.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
   
    @objc func donebuttonTap() {
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
   
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var memo = self.memoList
        let memoo = memo[sourceIndexPath.row]
        memo.remove(at: sourceIndexPath.row)
        memo.insert(memoo, at: destinationIndexPath.row)
        self.memoList = memo
    }
   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.memoList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.memoList.isEmpty {
            self.donebuttonTap()
            
        }
    }
    
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
   

        

    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let memoViewController = segue.destination as? memoViewController {
            memoViewController.delegate = self
    }
    }
}


extension memoTableViewController: memoViewDelegate {
    func didSelectReigstar(memo: Memo) {
        memoList.append(memo)
    }
}

class memoCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
}
