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
    
    private var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        
    }
    
    func setupUI() {
        self.backgroundColor = UIColor(red: 253.0/255.0, green: 250.0/255.0, blue: 175.0/255.0, alpha: 1.0)
        
        // Separator View 생성
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 21.0/255.0, green: 55.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        contentView.addSubview(separatorView)
        
        // Separator View의 Auto Layout 설정
        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(16) // 시작점 설정
            make.trailing.equalTo(contentView).offset(-16) // 끝점 설정
            make.bottom.equalTo(contentView) // 아래쪽에 붙이기
            make.height.equalTo(1) // 선의 높이 설정
        }
        
        // 세로선 뷰 생성
        let verticalLineView = UIView()
        verticalLineView.backgroundColor = UIColor(red: 21.0/255.0, green: 55.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        contentView.addSubview(verticalLineView)

        // 세로선 뷰의 Auto Layout 설정
        verticalLineView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView) // 세로선의 센터를 contentView의 센터로 정렬
            make.leading.equalTo(contentView).offset(100) // leading으로부터 100만큼 떨어져서 시작
            make.width.equalTo(1) // 선의 너비 설정
            make.height.equalTo(contentView) // 세로선의 높이를 contentView와 같도록 설정
        }

        // 두 번째 세로선 뷰 생성
        let secondVerticalLineView = UIView()
        secondVerticalLineView.backgroundColor = UIColor(red: 21.0/255.0, green: 55.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        contentView.addSubview(secondVerticalLineView)

        // 두 번째 세로선 뷰의 Auto Layout 설정
        secondVerticalLineView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView) // 세로선의 센터를 contentView의 센터로 정렬
            make.leading.equalTo(contentView).offset(110) // leading으로부터 110만큼 떨어져서 시작
            make.width.equalTo(1) // 선의 너비 설정
            make.height.equalTo(contentView) // 세로선의 높이를 contentView와 같도록 설정
        }
    } // setupUI

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
