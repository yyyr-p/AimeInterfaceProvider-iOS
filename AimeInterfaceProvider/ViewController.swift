import UIKit
import CoreNFC

class ViewController: UIViewController, FeliCaReaderDelegate {
    @IBOutlet weak var background: UIImageView!
    var reader: FeliCaReader?
    var server: SocketDelegate?
    
    func readerDidBecomeActive(_ reader: FeliCaReader) {
    }
    
    func feliCaReader(_ reader: FeliCaReader, withError error: Error) {
        guard let error = error as? FeliCaTagError else {
            return
        }
        
        switch error {
        case .cannotConnect:
            reader.session?.invalidate(errorMessage: "无法与卡片建立连接")
        case .countExceed:
            reader.session?.invalidate(errorMessage: "同时检测到超过 2 张卡片，请移除后再试")
        case .statusError:
            reader.session?.invalidate(errorMessage: "卡片状态错误")
        case .typeMismatch:
            reader.session?.invalidate(errorMessage: "卡片非 FeliCa 类型")
        case .userCancel: break
        case .becomeInvalidate: break
        }
        
        DispatchQueue.main.async {
            self.startPolling()
        }
    }
    
    func feliCaReader(_ reader: FeliCaReader, idmpmm card: Data) {
        self.reader?.session?.alertMessage = "完成"
        self.reader?.session?.invalidate()
        self.server?.broadcastFeliCaData(card)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        server = SocketDelegate()
        server!.viewController = self
        NSLog("server created")
    }

  
    @IBAction func tapScan(_ sender: UIButton) {
        NSLog("tapScan")
        // startPolling()
    }
    
    @objc func connected() {
        NSLog("connected")
    }
    
    @objc func startPolling() {
        NSLog("startPolling")
        self.reader = FeliCaReader(delegate: self)
        self.reader?.beginSession()
    }
    
    @objc func stopPolling() {
        NSLog("stopPolling")
        self.reader?.session?.invalidate(errorMessage: "读卡停止")
    }
    
    @objc func updateLed(_ r: Int, _ g: Int, _ b: Int) {
        NSLog("updateLed")
        background.backgroundColor = UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
    
    @objc func disconnected() {
        NSLog("disconnected")
    }
}
