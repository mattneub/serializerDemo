import UIKit

class Printer {
    func doPrint(_ value: Int) {
        print(value)
    }
}

class ViewController: UIViewController {

    let serializer: any SerializerType<Int> = Serializer()

    let printer = Printer()

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { 
            await serializer.startStream { @MainActor [weak self] value in
                print("starting long-running process", value)
                try await Task.sleep(for: .seconds(2))
                self?.printer.doPrint(value)
            }
        }
    }

    var count = 0

    @IBAction func doCountButton(_ sender: Any) {
        count += 1
        print("button press", count)
        Task {
            await serializer.vend(count)
        }
    }

    @IBAction func doCancelButton(_ sender: Any) {
        Task {
            await serializer.cancel()
        }
    }

    deinit {
        print("deinit view controller")
    }
}

