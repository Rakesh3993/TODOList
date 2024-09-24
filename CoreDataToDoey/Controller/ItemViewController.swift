//
//  ViewController.swift
//  CoreDataToDoey
//
//  Created by Rakesh Kumar on 17/09/24.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class ItemViewController: UIViewController {
    
    var itemArray: Results<Item>?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let realm = try! Realm()
    
    var selectedCategories: Category? {
        didSet{
            loadItems()
        }
    }
    
    var filePathManager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    private var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.placeholder = "search items"
        return search
    }()
    
    private var itemTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Items"
        var image = UIImage(systemName: "plus")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(plusButtonClicked))
        view.addSubview(itemTableView)
        view.addSubview(searchBar)
        itemTableView.delegate = self
        itemTableView.dataSource = self
        searchBar.delegate = self
        contraints()
    }
    
    private func contraints(){
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            itemTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -20),
            itemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    func plusButtonClicked(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add To Do List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { alertAction in
            if let currentCategory = self.selectedCategories {
                if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    do{
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = text
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd MMM, yyyy"
                            let currentDate = Date()
                            let formatterdate = dateFormatter.string(from: currentDate)
                            newItem.dateInput = formatterdate
                            newItem.dateCreated = Date()
                            currentCategory.item.append(newItem)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
            self.itemTableView.reloadData()
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "create item"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    private func loadItems(){
        itemArray = selectedCategories?.item.sorted(byKeyPath: "title", ascending: true)
        itemTableView.reloadData()
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifier, for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        if let data = itemArray?[indexPath.row] {
            cell.configure(with: ItemModel(name: data.title, date: data.dateInput))
            if let color = UIColor(hexString: selectedCategories!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray!.count)){
                cell.backgroundColor = color
                cell.dateLabel.textColor = ContrastColorOf(color, returnFlat: true)
                cell.itemLabel.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = data.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = itemArray?[indexPath.row] {
            do{
                try realm.write {
                    data.done = !data.done
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        itemTableView.reloadData()
        itemTableView.deselectRow(at: indexPath, animated: true)
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


extension ItemViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        itemTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
