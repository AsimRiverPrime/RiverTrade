//
//  CreateAccountSlideCell.swift
//  RiverPrime
//
//  Created by abrar ul haq on 04/08/2024.
//

import UIKit

class CreateAccountSlideCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recommendedStackView: UIStackView!
    @IBOutlet weak var clockImage: UIImageView!
    @IBOutlet weak var recommendedTitle: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var ListStack: UIStackView!
    
    @IBOutlet weak var minimumDepositTitleLabel: UILabel!
    @IBOutlet weak var minimumDepositDetailLabel: UILabel!
    @IBOutlet weak var spreadTitleLabel: UILabel!
    @IBOutlet weak var spreadDetailLabel: UILabel!
    @IBOutlet weak var commissionTitleLabel: UILabel!
    @IBOutlet weak var commissionDetailLabel: UILabel!
    
    @IBOutlet weak var swapTitleLabel: UILabel!
    @IBOutlet weak var swapDetailLabel: UILabel!
    
    @IBOutlet weak var stopOutTitleLabel: UILabel!
    @IBOutlet weak var stopOutDetailLabel: UILabel!
    
    @IBOutlet weak var pageControler: UIPageControl!
    
    var onContinusButtonClick: ((UIButton)->Void)?
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recommendedStackView.layer.cornerRadius = 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellForTableView(_ tableView: UITableView,  atIndexPath indexPath: IndexPath) -> CreateAccountSlideCell {
        let cell = tableView.dequeueReusableCell(with: CreateAccountSlideCell.self, for: indexPath)
        
        return cell
    }
    
    @IBAction func continusBtnAction(_ sender: UIButton) {
        self.onContinusButtonClick?(sender)
    }
    
}
