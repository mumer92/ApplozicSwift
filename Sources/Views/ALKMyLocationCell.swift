//
//  ALKMyLocationCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

final class ALKMyLocationCell: ALKLocationCell {
    
    // MARK: - Declare Variables or Types
    // MARK: Environment in chat
    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    // MARK: - Lifecycle
    override func setupViews() {
        super.setupViews()

        bubbleView.backgroundColor = UIColor.background(.redC0)

        // add view to contenview and setup constraint
        contentView.addViewsForAutolayout(views: [stateView])


        if(ALKMessageStyle.sentBubble.style == ALKMessageStyle.BubbleStyle.edge){
            bubbleViewBottom.constant = -6.0
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0).isActive = true
        }else{
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        }
        bubbleViewBottom.isActive = true

        bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14.0).isActive = true

        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true
        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        
        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }
    
    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)

        if(ALKMessageStyle.sentBubble.style == ALKMessageStyle.BubbleStyle.round){
            if(!isHideProfilePicOrTimeLabel){
                bubbleViewBottom.constant = -Padding.BubbleView.bottomUnClubedPadding
            }else{
                bubbleViewBottom.constant = -Padding.BubbleView.bottomClubedPadding
            }
        }

        timeLabel.isHidden = isHideProfilePicOrTimeLabel

        if viewModel.isAllRead {
            stateView.image = UIImage(named: "read_state_3", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor(netHex: 0x0578FF)
        } else if viewModel.isAllReceived {
            stateView.image = UIImage(named: "read_state_2", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else if viewModel.isSent {
            stateView.image = UIImage(named: "read_state_1", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else {
            stateView.image = UIImage(named: "seen_state_0", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor.red
        }
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {
        return super.rowHeigh(viewModel: viewModel, width: width) + 12.0
    }

}
