import UIKit
 
class CollectionViewLayout: UICollectionViewLayout{
    let columns = 8
    private var layoutData = [UICollectionViewLayoutAttributes]()//レイアウト
    //レイアウトの準備
    override func prepare() {
        self.layoutData.removeAll()
        let allWidth  = collectionView!.bounds.width
        let columnWidth = allWidth / CGFloat(self.columns)
        let columnHeight = columnWidth
        var x:CGFloat = 0
        var y:CGFloat = 0
        for count in 0 ... collectionView!.numberOfItems(inSection: 0){
            let indexPath = NSIndexPath(item: count, section: 0)
            //レイアウトの配列に位置とサイズを登録する。
            let frame = CGRect(x: x, y: y, width: columnWidth, height: columnHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
            attributes.frame = frame
            layoutData.append(attributes)
            
            if ((count + 1) % columns != 0){
                x += columnWidth
            }else{
                x = 0
                y += columnHeight
            }
        }
    }
    
    //レイアウトを返す
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutData
    }
    
    
}
