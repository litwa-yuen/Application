import UIKit
protocol DamageViewDataSource: class {
    func damagePercentForDamageView(_ sender:DamageView) -> CGFloat?
    func damageForDamageLabel(_ sender:DamageView) -> String?
}

@IBDesignable
class DamageView: UIView {
    @IBInspectable
    var lineWidth: CGFloat = 2 {didSet{setNeedsDisplay()}}
    @IBInspectable
    var color: UIColor = UIColorFromRGB("00C853") {didSet{setNeedsDisplay()}}
    
    weak var dataSource: DamageViewDataSource?
    var damageLabelSet = Bool()
    var damageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
    
    override func draw(_ rect: CGRect) {
        let r = CGRect(x: 0, y: 0, width: bounds.size.width, height: 20)
        let damgeFrame = UIBezierPath(roundedRect: r, byRoundingCorners: [UIRectCorner.topLeft , UIRectCorner.bottomLeft], cornerRadii: CGSize(width: 1.0, height: 1.0))
        damgeFrame.lineWidth = lineWidth
        color.set()
        damgeFrame.stroke()
        let damagePercent = dataSource?.damagePercentForDamageView(self) ?? 0
        if damageLabelSet == false {
            damageLabel = UILabel(frame: r)
            damageLabel.textAlignment = .center
            damageLabel.text = dataSource?.damageForDamageLabel(self) ?? "0"
            damageLabel.font = UIFont(name: "Helvetica", size: 12)
            damageLabel.textColor = UIColor.black
            self.addSubview(damageLabel)
            damageLabelSet = true
        }
        else {
            damageLabel.text = dataSource?.damageForDamageLabel(self) ?? "0"
        }
        
        bezierPathFor(damagePercent).stroke()
        
    }
    
    fileprivate func bezierPathFor(_ damgePercent: CGFloat) -> UIBezierPath {
        let r = CGRect(x: 0, y: 0, width: bounds.size.width*damgePercent, height: 20)
        let damgePath = UIBezierPath(roundedRect: r, byRoundingCorners: [UIRectCorner.topLeft , UIRectCorner.bottomLeft], cornerRadii: CGSize(width: 1.0, height: 1.0))
        damgePath.lineWidth = lineWidth
        UIColorFromRGB("00C853").setFill()
        damgePath.fill()
        return damgePath
    }
    
    
}
