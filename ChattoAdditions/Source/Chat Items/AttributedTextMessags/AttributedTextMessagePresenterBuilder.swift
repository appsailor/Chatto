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

import Foundation
import Chatto
import ChattoAdditions

open class AttributedTextMessagePresenterBuilder<ViewModelBuilderT, InteractionHandlerT>
: ChatItemPresenterBuilderProtocol where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: AttributedTextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    typealias ViewModelT = ViewModelBuilderT.ViewModelT
    typealias ModelT = ViewModelBuilderT.ModelT

    public init(
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT? = nil) {
            self.viewModelBuilder = viewModelBuilder
            self.interactionHandler = interactionHandler
    }

    let viewModelBuilder: ViewModelBuilderT
    let interactionHandler: InteractionHandlerT?
    let layoutCache = NSCache<AnyObject, AnyObject>()

    lazy var sizingCell: AttributedTextMessageCollectionViewCell = {
        var cell: AttributedTextMessageCollectionViewCell?
        if Thread.isMainThread {
            cell = AttributedTextMessageCollectionViewCell.sizingCell()
        } else {
            DispatchQueue.main.sync(execute: {
                cell =  AttributedTextMessageCollectionViewCell.sizingCell()
            })
        }

        return cell!
    }()

    public lazy var textCellStyle: AttributedTextMessageCollectionViewCellStyleProtocol = AttributedTextMessageCollectionViewCellDefaultStyle()
    public lazy var baseMessageStyle: BaseMessageCollectionViewCellStyleProtocol = BaseMessageCollectionViewCellDefaultStyle()

    open func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return self.viewModelBuilder.canCreateViewModel(fromModel: chatItem)
    }

    open func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        return self.createPresenter(withChatItem: chatItem,
                                    viewModelBuilder: self.viewModelBuilder,
                                    interactionHandler: self.interactionHandler,
                                    sizingCell: self.sizingCell,
                                    baseCellStyle: self.baseMessageStyle,
                                    textCellStyle: self.textCellStyle,
                                    layoutCache: self.layoutCache)
    }

    open func createPresenter(withChatItem chatItem: ChatItemProtocol,
                              viewModelBuilder: ViewModelBuilderT,
                              interactionHandler: InteractionHandlerT?,
                              sizingCell: AttributedTextMessageCollectionViewCell,
                              baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
                              textCellStyle: AttributedTextMessageCollectionViewCellStyleProtocol,
                              layoutCache: NSCache<AnyObject, AnyObject>) -> AttributedTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT> {
        assert(self.canHandleChatItem(chatItem))
        return AttributedTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>(
            messageModel: chatItem as! ModelT,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            baseCellStyle: baseCellStyle,
            textCellStyle: textCellStyle,
            layoutCache: layoutCache
        )
    }

    open var presenterType: ChatItemPresenterProtocol.Type {
        return AttributedTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>.self
    }
}
