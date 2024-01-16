//
//  TodoListCell.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/16/24.
//

import UIKit
import SnapKit

class TodoListCell: UITableViewCell {
    
    @IBOutlet weak var DateWhenTodo: UILabel!
    @IBOutlet weak var WhatTodo: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
