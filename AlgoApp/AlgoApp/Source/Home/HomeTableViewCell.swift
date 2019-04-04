//
//  HomeTableViewCell.swift
//  AlgoApp
//
//  Created by Huong Do on 2/4/19.
//  Copyright © 2019 Huong Do. All rights reserved.
//

import UIKit
import Reusable

final class HomeTableViewCell: UITableViewCell, Reusable {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 8.0
        cardView.dropCardShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            setSelected(false, animated: true)
        }
    }

    func configureCell(with model: QuestionCellModel) {
        updateColors()
        
        emojiLabel.text = model.emoji
        titleLabel.text = model.title
        tagsLabel.text = model.tags.joined(separator: "・")
        markLabel.text = model.remark
        difficultyLabel.text = model.difficulty
    }
    
    private func updateColors() {
        titleLabel.textColor = .titleTextColor()
        tagsLabel.textColor = .subtitleTextColor()
        markLabel.textColor = .subtitleTextColor()
        cardView.backgroundColor = .primaryColor()
        contentView.backgroundColor = .backgroundColor()
    }
}
