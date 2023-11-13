//
//  CustomHStack.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 13.11.2023..
//

import SwiftUI

struct CustomHStack: Layout {
  let widthWeights: [CGFloat]
  let spacing: CGFloat

  init(widthWeights: [CGFloat], spacing: CGFloat? = nil) {
    self.widthWeights = widthWeights
    self.spacing = spacing ?? .zero
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let maxHeight = subviews
      .map { proxy in
        return proxy.sizeThatFits(.unspecified).height
      }
      .max() ?? .zero

    return CGSize(width: proposal.width ?? .zero, height: maxHeight)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let subviewSizes = subviews.map { proxy in
      return proxy.sizeThatFits(.infinity)
    }

    var x = bounds.minX
    let y = bounds.minY
    let parentTotalWith = (proposal.width ?? .zero) - (CGFloat((widthWeights.count - 1)) * spacing)

    for index in subviews.indices {
      let widthWeight = widthWeights[index]
      let proposedWidth = widthWeight * parentTotalWith

      let sizeProposal = ProposedViewSize(width: proposedWidth, height: subviewSizes[index].height)

      subviews[index]
        .place(
          at: CGPoint(x: x, y: y),
          anchor: .topLeading,
          proposal: sizeProposal
        )

      x += (proposedWidth + spacing)
    }
  }
}
