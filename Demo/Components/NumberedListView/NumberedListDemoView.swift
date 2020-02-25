//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import FinniversKit

class NumberedListDemoView: UIView {
    private lazy var numberedListView: NumberedListView = NumberedListView(numberOfSteps: 2, delegate: self, withAutoLayout: true)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        addSubview(numberedListView)
        numberedListView.fillInSuperview()
    }
}

extension NumberedListDemoView: NumberedListViewDelegate {
    func numberedListView(_ numberedListView: NumberedListView, textForStep step: Int) -> String {
        switch step {
        case 0:
            let text = "Ved oppmøte registrerer dere først eierskiftet digitalt hos Statens vegvesen."
            return text
        case 1:
            let text = "Deretter må begge bekrefte at overleveringen har skjedd, og at pengene skal utbetales."
            return text
        default:
            return ""
        }
    }
}
