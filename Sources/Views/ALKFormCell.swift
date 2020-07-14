//
//  ALKFormCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 08/07/20.
//

import UIKit

class ALKFormCell: ALKChatBaseCell<ALKMessageViewModel>, UITextFieldDelegate {
    public var tapped: ((_ index: Int, _ name: String, _ formDataSubmit: FormDataSubmit) -> Void)?
    let itemListView = NestedCellTableView()
    var formDataSubmit = FormDataSubmit()
    var submitButton: CurvedImageButton?
    var activeTextField: UITextField? {
        didSet {
            activeTextFieldChanged?(activeTextField)
        }
    }
    var activeTextFieldChanged: ((UITextField?) -> Void)?

    private var items: [FormViewModelItem] = []
    private var template: FormTemplate? {
        didSet {
            items = template?.viewModeItems ?? []
            itemListView.reloadData()
            guard let submitButtonTitle = template?.submitButtonTitle else { return }
            setUpSubmitButton(title: submitButtonTitle)
        }
    }
    private var selectedIndexes: [Int: Int] = [:]

    override func setupViews() {
        super.setupViews()
        setUpTableView()
    }

    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        template = viewModel.formTemplate()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        guard formDataSubmit.listOfUITextFieldWithPos != nil else {
            return
        }
        formDataSubmit.listOfUITextFieldWithPos?[textField.tag] = textField
    }

    private func setUpTableView() {
        itemListView.backgroundColor = .white
        itemListView.estimatedRowHeight = 50
        itemListView.estimatedSectionHeaderHeight = 50
        itemListView.rowHeight = UITableView.automaticDimension
        itemListView.separatorStyle = .singleLine
        itemListView.allowsSelection = false
        itemListView.delegate = self
        itemListView.dataSource = self
        itemListView.tableFooterView = UIView(frame: .zero)
        itemListView.register(ALKFormItemHeaderView.self)
        itemListView.register(ALKFormTextItemCell.self)
        itemListView.register(ALKFormPasswordItemCell.self)
        itemListView.register(ALKFormSingleSelectItemCell.self)
        itemListView.register(ALKFormMultiSelectItemCell.self)
    }

    private func setUpSubmitButton(title: String) {
        let button = CurvedImageButton(title: title)
        button.delegate = self
        button.index = 1
        submitButton = button
    }
}

extension ALKFormCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .text:
            let cell: ALKFormTextItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = item
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            return cell
        case .password:
            let cell: ALKFormPasswordItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = item
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            return cell
        case .singleselect:
            guard let singleselectItem = item as? FormViewModelSingleselectItem else {
                return UITableViewCell()
            }
            let cell: ALKFormSingleSelectItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellSelected = {
                guard self.formDataSubmit.singleSelect != nil else {
                    return
                }
                self.selectedIndexes[indexPath.section] = indexPath.row
                self.formDataSubmit.singleSelect?[indexPath.section] = indexPath.row
                tableView.reloadSections([indexPath.section], with: .none)
            }
            cell.item = singleselectItem.options[indexPath.row]
            if let rowSelected = selectedIndexes[indexPath.section], rowSelected == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case .multiselect:
            guard let multiselectItem = item as? FormViewModelMultiselectItem else {
                return UITableViewCell()
            }
            let cell: ALKFormMultiSelectItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellSelected = {
                guard var multiSelect = self.formDataSubmit.multiSelect else {
                    return
                }

                if let array = multiSelect[indexPath.section] {
                    var newArray = array
                    if array.contains(indexPath.row) {
                        newArray.remove(at: indexPath.row)
                    } else {
                        newArray.append(indexPath.row)
                    }

                    if newArray.isEmpty {
                        multiSelect.removeValue(forKey: indexPath.section)
                    } else {
                        multiSelect[indexPath.section] = newArray
                    }

                    self.formDataSubmit.multiSelect = multiSelect
                } else {
                    self.formDataSubmit.multiSelect?[indexPath.section] = [indexPath.row]
                }
            }

            cell.item = multiselectItem.options[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = items[section]
        guard !item.sectionTitle.isEmpty else { return nil }
        let headerView: ALKFormItemHeaderView = tableView.dequeueReusableHeaderFooterView()
        headerView.item = item
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let item = items[section]
        guard !item.sectionTitle.isEmpty else { return 0 }
        return UITableView.automaticDimension
    }
}

extension ALKFormCell: Tappable {
    func didTap(index: Int?, title: String) {
        print("tapped submit button in the form")
        guard let tapped = tapped, let index = index else { return }
        tapped(index, title, formDataSubmit)
    }
}

class NestedCellTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
}

class FormDataSubmit {
    var listOfUITextFieldWithPos : [Int: UITextField]?
    var singleSelect : [Int : Int]?
    var multiSelect : [Int : [Int]]?

    init() {
        listOfUITextFieldWithPos = [Int: UITextField]()
        singleSelect = [Int : Int]()
        multiSelect = [Int : [Int]]()
    }
}