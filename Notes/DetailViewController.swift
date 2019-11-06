//
//  DetailViewController.swift
//  Plain Ol' Notes
//
//  Created by AliasLab UK Dev on 23/03/2018.
//  Copyright © 2018 AliasLab UK. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{

    @IBOutlet weak var textView: UITextView!
    
    var text : String = ""
    var masterView : ViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textView.text = text
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    func setText(t:String)
    {
        text = t
        if  isViewLoaded
        {
            textView.text = text
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if masterView != nil && textView != nil
        {
            masterView.newRowText = textView.text
            textView.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
