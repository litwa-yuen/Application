import UIKit
protocol DamageViewDataSource: class {
    func damagePercentForDamageView(sender:DamageView) -> CGFloat?
    func damageForDamageLabel(sender:DamageView) -> String?
}

@IBDesignable
class DamageView: UIView {
    @IBInspectable
    var lineWidth: CGFloat = 2 {didSet{setNeedsDisplay()}}
    @IBInspectable
    var color: UIColor = UIColorFromRGB("00C853") {didSet{setNeedsDisplay()}}
    
    weak var dataSource: DamageViewDataSource?
    var damageLabelSet = Bool()
    var damageLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 50, 20))
    
    override func drawRect(rect: CGRect) {
        let r = CGRectMake(0, 0, bounds.size.width, 20)
        let damgeFrame = UIBezierPath(roundedRect: r, byRoundingCorners: [UIRectCorner.TopLeft , UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(1.0, 1.0))
        damgeFrame.lineWidth = lineWidth
        color.set()
        damgeFrame.stroke()
        let damagePercent = dataSource?.damagePercentForDamageView(self) ?? 0
        if damageLabelSet == false {
            damageLabel = UILabel(frame: r)
            damageLabel.textAlignment = .Center
            damageLabel.text = dataSource?.damageForDamageLabel(self) ?? "0"
            damageLabel.font = UIFont(name: "Helvetica", size: 12)
            damageLabel.textColor = UIColor.blackColor()
            self.addSubview(damageLabel)
            damageLabelSet = true
        }
        else {
            damageLabel.text = dataSource?.damageForDamageLabel(self) ?? "0"
        }
        
        bezierPathFor(damagePercent).stroke()
        
    }
    
    private func bezierPathFor(damgePercent: CGFloat) -> UIBezierPath {
        let r = CGRectMake(0, 0, bounds.size.width*damgePercent, 20)
        let damgePath = UIBezierPath(roundedRect: r, byRoundingCorners: [UIRectCorner.TopLeft , UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(1.0, 1.0))
        damgePath.lineWidth = lineWidth
        UIColorFromRGB("00C853").setFill()
        damgePath.fill()
        return damgePath
    }
    
    
}
