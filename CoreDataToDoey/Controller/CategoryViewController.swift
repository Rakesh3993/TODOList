//
//  CategoryViewController.swift
//  CoreDataToDoey
//
//  Created by Rakesh Kumar on 18/09/24.
//

import UIKit
import CoreData
import RealmSwift
import Firebase
import ChameleonFramework

class CategoryViewController: UIViewController {
    
    var categoryArray: Results<Category>?
    
    var realm = try! Realm()
        
    private var categoryTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todoey"
        var image = UIImage(systemName: "plus")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(categoryPlusButtonClicked))
        
        view.addSubview(categoryTableView)
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        loadCategory()
        contraints()
    }
    
    private func contraints(){
        NSLayoutConstraint.activate([
            categoryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: -33),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    func categoryPlusButtonClicked(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { alertAction in
            if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                let newCategory = Category()
                newCategory.name = textField.text ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM, yyyy"
                let currentDate = Date()
                let formatterDate = dateFormatter.string(from: currentDate)
                newCategory.dateInput = formatterDate
                newCategory.colour = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
            }
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "create new category"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    func save(category: Category){
        do{
            try realm.write({
                realm.add(category)
            })
        }catch{
            print(error.localizedDescription)
        }
        categoryTableView.reloadData()
    }
    
    func loadCategory(){
        categoryArray  = realm.objects(Category.self)
        categoryTableView.reloadData()
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        if let category = categoryArray?[indexPath.row] {
            cell.configure(with: ItemModel(name: category.name, date: category.dateInput))
            cell.backgroundColor = UIColor(hexString: category.colour)
            print(category)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemViewController()
        vc.selectedCategories = categoryArray?[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
