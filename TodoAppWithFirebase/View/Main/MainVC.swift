//
//  ViewController.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/11/24.
//

import UIKit
import SnapKit
import FirebaseDatabaseInternal

struct TodoEntity {
    var todo: String?
    //    var detail: String?
    //    var date: String?
}

class MainVC: UIViewController {
    
    // 상단뷰
    lazy var aboveView = UIView()
    // 하단뷰
    lazy var belowView = UIView()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTodoButton: UIButton!
    
    @IBOutlet weak var testTextField: UITextField!
    
    var todoList: [TodoEntity] = []
    
    var loginVC = LoginVC()
    var userId: String?
    
    
    var ref: DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let savedUid = UserDefaults.standard.string(forKey: "uid") {
            userId = savedUid
            // uid를 사용하여 원하는 작업 수행
        }
        
        guard let userId = userId else { return }
        
        print(#fileID, #function, #line, "- MainVC:userID = \(userId)")
        
        ref = Database.database(url: "https://todoappwithfirebase-7367f-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child(userId ?? "error")
        
        ref?.observe(.value) { snapshot in
            
            self.todoList = []
            
            for child in snapshot.children {
                let childSnapShot = child as? DataSnapshot
                let value = childSnapShot?.value as? NSDictionary
                let todo = value?["todo"] as? String ?? ""
                let fetchedTodoEntity = TodoEntity(todo: todo)
                print(#fileID, #function, #line, "- fetchedTodoEntity: \(fetchedTodoEntity)")
                self.todoList.append(fetchedTodoEntity)
            }
            self.tableView.reloadData()
        }
        
        self.tableView.register(TodoListCell.uinib, forCellReuseIdentifier: TodoListCell.reuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        
        // snapkit을 이용한 view 설정
        setupUI()
        // configure setting
        configureUI()
    }
    
    private func setupUI() {
        
        self.view.sendSubviewToBack(tableView)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 253.0/255.0, green: 250.0/255.0, blue: 175.0/255.0, alpha: 1.0)
        
        // 1. 상단 뷰
        self.view.addSubview(aboveView)
        aboveView.backgroundColor = UIColor(red: 21.0/255.0, green: 55.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        aboveView.layer.shadowColor = UIColor.black.cgColor
        aboveView.layer.shadowOpacity = 1
        aboveView.layer.shadowOffset = CGSize(width: 2, height: 2)
        aboveView.layer.shadowRadius = 4
        aboveView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.top.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(-750)
            make.right.equalTo(self.view).offset(0)
            
        }
        
        // 2. 하단 뷰
        self.view.addSubview(belowView)
        // 버튼 보이게끔 하기 위해 뒤로 보냄
        self.view.sendSubviewToBack(belowView)
        belowView.backgroundColor = UIColor(red: 253.0/255.0, green: 250.0/255.0, blue: 175.0/255.0, alpha: 1.0)
        belowView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.top.equalTo(aboveView).offset(104)
            make.left.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(-0)
            make.right.equalTo(self.view).offset(0)
        }
        
    } //setupUI
    
    private func configureUI() {
        addTodoButton.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        
    } // configureUI
    
    @objc func addTodo() {
        print(#fileID, #function, #line, "- 할 일 추가")
        guard let newInput = testTextField.text else { return }
        let newTodo = TodoEntity(todo: newInput)
        
        self.ref?.child("todos").setValue(["todo": newTodo.todo])
        
        testTextField.text = ""
    }
    
}

extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else {
            return UITableViewCell()
        }
        
        let cellData: TodoEntity = todoList[indexPath.row]
        cell.WhatTodo.text = cellData.todo
        
        
        return cell
    }
    
    
}

extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제", handler: { _,_,_  in
            print(#fileID, #function, #line, "- 삭제: \(indexPath)")
            // 1. 데이터 지우기
            self.todoList.remove(at: indexPath.row)
            
            // 2. 셀 reload
            tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        let cellConfig = UISwipeActionsConfiguration(actions: [
            deleteAction
        ])
        //        cellConfig.performsFirstActionWithFullSwipe = false
        
        return cellConfig
    }
}
