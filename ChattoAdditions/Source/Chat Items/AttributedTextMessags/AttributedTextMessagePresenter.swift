/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit
import Chatto
import ChattoAdditions

open class AttributedTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>
: BaseMessagePresenter<AttributedTextBubbleView, ViewModelBuilderT, InteractionHandlerT> where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: AttributedTextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT

    public init (
        messageModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: AttributedTextMessageCollectionViewCell,
        baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
        textCellStyle: AttributedTextMessageCollectionViewCellStyleProtocol,
        layoutCache: NSCache<AnyObject, AnyObject>) {
            self.layoutCache = layoutCache
            self.textCellStyle = textCellStyle
            super.init(
                messageModel: messageModel,
                viewModelBuilder: viewModelBuilder,
                interactionHandler: interactionHandler,
                sizingCell: sizingCell,
                cellStyle: baseCellStyle
            )
    }

    let layoutCache: NSCache<AnyObject, AnyObject>
    let textCellStyle: AttributedTextMessageCollectionViewCellStyleProtocol
    
    var isItemUpdateSupported: Bool = false

    public final override class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(AttributedTextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "attr-text-message-incoming")
        collectionView.register(AttributedTextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "attr-text-message-outcoming")
    }

    public final override func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = self.messageViewModel.isIncoming ? "attr-text-message-incoming" : "attr-text-message-outcoming"
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    open override func createViewModel() -> ViewModelBuilderT.ViewModelT {
        let viewModel = self.viewModelBuilder.createViewModel(self.messageModel)
        let updateClosure = { [weak self] (old: Any, new: Any) -> Void in
            self?.updateCurrentCell()
        }
        viewModel.avatarImage.observe(self, closure: updateClosure)
        return viewModel
    }

    public var textCell: AttributedTextMessageCollectionViewCell? {
        if let cell = self.cell {
            if let textCell = cell as? AttributedTextMessageCollectionViewCell {
                return textCell
            } else {
                assert(false, "Invalid cell was given to presenter!")
            }
        }
        return nil
    }

    open override func configureCell(_ cell: BaseMessageCollectionViewCell<AttributedTextBubbleView>, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionalConfiguration: (() -> Void)?) {
        guard let cell = cell as? AttributedTextMessageCollectionViewCell else {
            assert(false, "Invalid cell received")
            return
        }

        super.configureCell(cell, decorationAttributes: decorationAttributes, animated: animated) { () -> Void in
            cell.layoutCache = self.layoutCache
            cell.textMessageViewModel = self.messageViewModel
            cell.textMessageStyle = self.textCellStyle
            additionalConfiguration?()
        }
    }

    public func updateCurrentCell() {
        if let cell = self.textCell, let decorationAttributes = self.decorationAttributes {
            self.configureCell(cell, decorationAttributes: decorationAttributes, animated: self.itemVisibility != .appearing, additionalConfiguration: nil)
        }
    }

    open override func canShowMenu() -> Bool {
        return true
    }

    open override func canPerformMenuControllerAction(_ action: Selector) -> Bool {
        let selector = #selector(UIResponderStandardEditActions.copy(_:))
        return action == selector
    }

    open override func performMenuControllerAction(_ action: Selector) {
        let selector = #selector(UIResponderStandardEditActions.copy(_:))
        if action == selector {
            //UIPasteboard.general.string = self.messageViewModel.text
        } else {
            assert(false, "Unexpected action")
        }
    }
}
