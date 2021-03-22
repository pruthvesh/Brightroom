
import AsyncDisplayKit
import GlossButtonNode
import TextureSwiftSupport
import UIKit
import MosaiqueAssetsPicker

import PixelEditor
import PixelEngine

final class DemoCropMenuViewController: StackScrollNodeViewController {
  private lazy var stackForHorizontal: EditingStack = Mocks.makeEditingStack(image: Asset.horizontalRect.image)
  private lazy var stackForVertical: EditingStack = Mocks.makeEditingStack(image: Asset.verticalRect.image)
  private lazy var stackForSquare: EditingStack = Mocks.makeEditingStack(image: Asset.squareRect.image)
  private lazy var stackForSmall: EditingStack = Mocks.makeEditingStack(image: Asset.superSmall.image)
  private lazy var stackForNasa: EditingStack = Mocks.makeEditingStack(
    fileURL:
    Bundle.main.path(
      forResource: "nasa",
      ofType: "jpg"
    ).map {
      URL(fileURLWithPath: $0)
    }!
  )
  
  private let resultCell = Components.ResultImageCell()

  override init() {
    super.init()
    title = "Crop"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
        
    stackScrollNode.append(nodes: [
      
      resultCell,
      
      Components.makeSelectionCell(title: "Horizontal rect from UIImage", onTap: { [unowned self] in
        _presentCropViewConroller(stackForHorizontal)
      }),

      Components.makeSelectionCell(title: "Vertical rect from UIImage", onTap: { [unowned self] in
        _presentCropViewConroller(stackForVertical)
      }),

      Components.makeSelectionCell(title: "Square rect from UIImage", onTap: { [unowned self] in
        _presentCropViewConroller(stackForSquare)
      }),

      Components.makeSelectionCell(title: "Super small rect from UIImage", onTap: { [unowned self] in
        _presentCropViewConroller(stackForSmall)
      }),

      Components.makeSelectionCell(title: "Super large rect from file URL", onTap: { [unowned self] in
        _presentCropViewConroller(stackForNasa)
      }),
      
      Components.makeSelectionCell(
        title: "Square only",
        description: """
        CropViewController supports to disable the selecting aspect-ratio.
        Instead specify which aspect ratio fixes the cropping guide.
        """,
        onTap: { [unowned self] in
          
          var options = CropViewController.Options()
          options.aspectRatioOptions = .fixed(.square)
          
          let controller = CropViewController(editingStack: stackForVertical, options: options)
          _presentCropViewConroller(controller)
      }),
      
      Components.makeSelectionCell(
        title: "Specified extent",
        description: """
        EditingStack can specify the extent of cropping while creating.
        """,
        onTap: { [unowned self] in
          
          let editingStack = EditingStack(imageProvider: .init(image: Asset.l1002725.image), modifyCrop: { image, crop in
            crop.setCropExtentNormalizing(CGRect(origin: .zero, size: .init(width: 100, height: 300)))
          })
          
//          var options = CropViewController.Options()
//          options.aspectRatioOptions = .fixed(.square)
          
          let controller = CropViewController(editingStack: editingStack)
          _presentCropViewConroller(controller)
        }),
      
      Components.makeSelectionCell(title: "Pick from library", onTap: { [unowned self] in
        
        self.__pickPhoto { (image) in
          
          let stack = EditingStack(imageProvider: .init(image: image))
          _presentCropViewConroller(stack)
        }
        
      }),
    ])
  }
  
  private func _presentCropViewConroller(_ crop: CropViewController) {
    crop.modalPresentationStyle = .fullScreen
    crop.handlers.didCancel = { controller in
      controller.dismiss(animated: true, completion: nil)
    }
    crop.handlers.didFinish = { [weak self] controller in
      controller.dismiss(animated: true, completion: nil)
      controller.editingStack.makeRenderer().render { [weak self] (image) in
        self?.resultCell.image = image
      }
    }
    present(crop, animated: true, completion: nil)
  }

  private func _presentCropViewConroller(_ editingStack: EditingStack) {
    let crop = CropViewController(editingStack: editingStack)
    _presentCropViewConroller(crop)
  }
}