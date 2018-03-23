//
//  ViewController.swift
//  Plain Ol' Notes
//
//  Created by AliasLab UK Dev on 23/03/2018.
//  Copyright © 2018 AliasLab UK. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    // MARK: Data Values
    @IBOutlet weak var table: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)

    var fileUrl : URL!
    var data : [String] = []
    var filteredData : [String] = []

    var selectedDataRow : Int = -1
    var newRowText : String = ""

    // MARK: Overloads
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // set tableview deleage and datasource to self
        table.dataSource = self
        table.delegate = self
        
        // setup title
        self.title = "Notes"
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationItem.largeTitleDisplayMode = .always

        // add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        self.navigationItem.rightBarButtonItem = addButton
        
        // edit button
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        // set file url and load saved notes
        let baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        fileUrl = baseURL.appendingPathComponent("note.txt")
        load()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search notes"
        navigationItem.searchController = data.count > 7 ? searchController : nil
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        searchController.isActive = false
        if selectedDataRow == -1
        {
            return
        }
        
        data[selectedDataRow] = newRowText
        if newRowText == ""
        {
            data.remove(at: selectedDataRow)
        }
        
        save()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        table.setEditing(editing, animated: animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let detailViewControll = segue.destination as! DetailViewController
        
        selectedDataRow = table.indexPathForSelectedRow!.row
        if isFiltering()
        {
            let item = filteredData[selectedDataRow]
            selectedDataRow = data.index(of: item)!
        }
        detailViewControll.masterView = self
        
        detailViewControll.setText(t: data[selectedDataRow])
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Helpers
    @objc func addNote()
    {
        if table.isEditing
        {
            return
        }
        let name = ""
        data.insert(name, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        table.insertRows(at: [indexPath], with: .automatic)
        table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    func save()
    {
        navigationItem.searchController = data.count > 10 ? searchController : nil
        
//        UserDefaults.standard.setValue(data, forKey: "notes")
        let a = NSArray(array: data)
        do
        {
            try a.write(to: fileUrl)
        }
        catch
        {
            print("error writing file")
        }
    }
    
    func load()
    {
//        if let loadedData: [String] = UserDefaults.standard.value(forKey: "notes") as? [String]
        if let loadedData : [String] = NSArray(contentsOf: fileUrl) as? [String]
        {
            data = loadedData
            table.reloadData()
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isFiltering()
        {
            return filteredData.count
        }
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        var text = ""
        if isFiltering()
        {
            text = filteredData[indexPath.row]
        }
        else
        {
            text = data[indexPath.row]
        }
        cell.textLabel?.text = text
        return cell
    }

    // MARK: Table View Delegate

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        data.remove(at: indexPath.row)
        table.deleteRows(at: [indexPath], with: .fade)
        save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let movedItem = data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(movedItem, at: destinationIndexPath.row)
        table.reloadData()
    }

    func isFiltering() -> Bool
    {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool
    {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        filteredData = data.filter({ (value) -> Bool in
            return value.lowercased().contains(searchText.lowercased())
        })
        
        table.reloadData()
    }
}

extension ViewController: UISearchResultsUpdating
{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

