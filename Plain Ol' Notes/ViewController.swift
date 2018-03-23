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
    var fileUrl : URL!
    var data : [String] = []
    var selectedRow : Int = -1
    var newRowText : String = ""
    
    // MARK: Overloads
    override func viewDidLoad()
    {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        self.title = "Notes"
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationItem.largeTitleDisplayMode = .always

        // add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        self.navigationItem.rightBarButtonItem = addButton
        
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        let baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        fileUrl = baseURL.appendingPathComponent("note.txt")
        
        
        load()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if selectedRow == -1
        {
            return
        }
        data[selectedRow] = newRowText
        if newRowText == ""
        {
            data.remove(at: selectedRow)
        }
        table.reloadData()
        save()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        table.setEditing(editing, animated: animated)
        
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
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = data[indexPath.row]
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
        print(data[indexPath.row])
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let detailViewControll = segue.destination as! DetailViewController
        selectedRow = table.indexPathForSelectedRow!.row
        detailViewControll.masterView = self
        detailViewControll.setText(t: data[selectedRow])        
    }

}

