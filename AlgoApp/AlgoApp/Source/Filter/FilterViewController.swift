//
//  FilterViewController.swift
//  AlgoApp
//
//  Created by Huong Do on 2/20/19.
//  Copyright © 2019 Huong Do. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Tags

class FilterViewController: UIViewController {

    @IBOutlet private weak var difficultyTagsView: TagsView!
    @IBOutlet private weak var categoryTagsView: TagsView!
    @IBOutlet private weak var companyTagsView: TagsView!
    @IBOutlet private weak var otherTagsView: TagsView!
    
    @IBOutlet private weak var clearAllButton: UIBarButtonItem!
    @IBOutlet private weak var applyButton: UIBarButtonItem!
    
    @IBOutlet private var titleLabels: [UILabel]!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var viewModel: FilterViewModel!
    private let disposeBag = DisposeBag()
    
    var reminderMode = false
    var initialFilter: QuestionFilter?
    var completionBlock: ((QuestionFilter) -> Void)?
    
    var currentFilterDriver: Driver<QuestionFilter?> {
        return viewModel.currentFilterRelay.asDriver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = FilterViewModel()
        
        applyButton.tintColor = .appBlueColor()
        clearAllButton.tintColor = .appOrangeColor()
        
        difficultyTagsView.tags = Question.DifficultyLevel.allCases.map { $0.title }.joined(separator: ",")
        
        let remarkTags = Question.Remarks.allCases.map { $0.title } + (reminderMode ? [] : [viewModel.savedTag, viewModel.notSavedTag, viewModel.solvedTag, viewModel.unsolvedTag])
        otherTagsView.tags = remarkTags.joined(separator: ",")
        
        viewModel.allTags.asDriver()
            .drive(onNext: { [weak self] in
                self?.categoryTagsView.tags = $0.joined(separator: ",")
            })
            .disposed(by: disposeBag)
        
        viewModel.allCompanies.asDriver()
            .drive(onNext: { [weak self] in
                self?.companyTagsView.tags = $0.joined(separator: ",")
            })
            .disposed(by: disposeBag)
        
        [difficultyTagsView, otherTagsView, categoryTagsView, companyTagsView].forEach { [unowned self] tagView in
            tagView?.delegate = self
            tagView?.tagLayerColor = .borderColor()
            tagView?.tagTitleColor = .titleTextColor()
            tagView?.backgroundColor = .clear
            tagView?.tagFont = UIFont.preferredFont(forTextStyle: .callout)
        }
        
        if reminderMode {
            viewModel.updateRemark(viewModel.unsolvedTag)
        }
        
        updateColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let filter = initialFilter {
            loadInitialFilter(filter)
        }
    }
    
    private func loadInitialFilter(_ filter: QuestionFilter) {
        for level in filter.levels {
            let difficulty = Question.DifficultyLevel(rawValue: level) ?? .easy
            if let button = difficultyTagsView.tagArray.first(where: { $0.title(for: .normal) == difficulty.title }) {
                tagsTouchAction(difficultyTagsView, tagButton: button)
            }
        }
        
        for tag in filter.tags {
            if let button = categoryTagsView.tagArray.first(where: { $0.title(for: .normal) == tag }) {
                tagsTouchAction(categoryTagsView, tagButton: button)
            }
        }
        
        for company in filter.companies {
            if let button = companyTagsView.tagArray.first(where: { $0.title(for: .normal) == company }) {
                tagsTouchAction(companyTagsView, tagButton: button)
            }
        }
        
        if filter.topLiked, let button = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == Question.Remarks.topLiked.title }) {
            tagsTouchAction(otherTagsView, tagButton: button)
        }
        
        if filter.topInterviewed, let button = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == Question.Remarks.topInterviewed.title }) {
            tagsTouchAction(otherTagsView, tagButton: button)
        }
        
        if filter.saved == true, let button = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.savedTag }) {
            tagsTouchAction(otherTagsView, tagButton: button)
        } else if filter.saved == false, let button = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.notSavedTag }) {
            tagsTouchAction(otherTagsView, tagButton: button)
        }
        
        if filter.solved == true, let button = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.solvedTag }) {
            tagsTouchAction(otherTagsView, tagButton: button)
        } else if filter.solved == false, let button = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.unsolvedTag }) {
            tagsTouchAction(otherTagsView, tagButton: button)
        }
    }
    
    func updateColors() {
        navigationController?.navigationBar.tintColor = .titleTextColor()
        navigationController?.navigationBar.barTintColor = .primaryColor()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.titleTextColor()]
        
        view.backgroundColor = .primaryColor()
        
        titleLabels.forEach { $0.textColor = .titleTextColor() }
    }

    @IBAction func clearAllFilters(_ sender: Any) {
        let filter = viewModel.buildFilter(shouldClearAll: true)
        completionBlock?(filter)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        let filter = viewModel.buildFilter(shouldClearAll: false)
        completionBlock?(filter)
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: TagsDelegate {
    func tagsTouchAction(_ tagsView: TagsView, tagButton: TagButton) {
        if tagButton.layer.borderColor != UIColor.clear.cgColor {
            tagButton.backgroundColor = .secondaryColor()
            tagButton.setTitleColor(.primaryColor(), for: .normal)
            tagButton.layer.borderColor = UIColor.clear.cgColor
            
            toggleButtons(for: tagButton, in: tagsView)
            
        } else {
            tagButton.backgroundColor = .clear
            tagButton.setTitleColor(.titleTextColor(), for: .normal)
            tagButton.layer.borderColor = UIColor.borderColor().cgColor
        }
        
        let title = tagButton.title(for: .normal)!
        if tagsView == difficultyTagsView {
            viewModel.updateLevel(title)
        } else if tagsView == categoryTagsView {
            viewModel.updateCategory(title)
        } else if tagsView == companyTagsView {
            viewModel.updateCompany(title)
        } else if tagsView == otherTagsView {
            viewModel.updateRemark(title)
        }
    }
    
    private func toggleButtons(for tagButton: TagButton, in tagsView: TagsView) {
        if tagButton.title(for: .normal) == viewModel.savedTag,
            let notSavedButton = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.notSavedTag }),
            notSavedButton.layer.borderColor == UIColor.clear.cgColor {
            tagsTouchAction(tagsView, tagButton: notSavedButton)
        } else if tagButton.title(for: .normal) == viewModel.notSavedTag,
            let savedButton = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.savedTag }),
            savedButton.layer.borderColor == UIColor.clear.cgColor {
            tagsTouchAction(tagsView, tagButton: savedButton)
        } else if tagButton.title(for: .normal) == viewModel.solvedTag,
            let unsolvedButton = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.unsolvedTag }),
            unsolvedButton.layer.borderColor == UIColor.clear.cgColor {
            tagsTouchAction(tagsView, tagButton: unsolvedButton)
        } else if tagButton.title(for: .normal) == viewModel.unsolvedTag,
            let solvedButton = otherTagsView.tagArray.first(where: { $0.title(for: .normal) == viewModel.solvedTag }),
            solvedButton.layer.borderColor == UIColor.clear.cgColor {
            tagsTouchAction(tagsView, tagButton: solvedButton)
        }
    }
}
