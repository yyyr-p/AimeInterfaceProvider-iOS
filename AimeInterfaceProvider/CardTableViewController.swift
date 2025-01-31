//
//  CardTableViewController.swift
//  nfc
//
//  Created by ST22245 on 2019/10/23.
//  Copyright © 2019 kalan. All rights reserved.
//

import UIKit

class CardTableViewController: UITableViewController {
    var card: FeliCaCard?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return card?.entryExitHistory.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CardCell {
            let history = card?.entryExitHistory[indexPath.row]
            cell.machineType.text = "機器類別：" + history!.machineType.description
            cell.paymentType.text = "付款類別：" + history!.paymentType
            cell.usageType.text = "使用類別：" + history!.usageType.description
            cell.entryExitType.text = "出入場類別：" + history!.entryExitType.description
            
            cell.date.text = "日期：\(history?.date.description ?? "0")"
            cell.title.text = "餘額：\(history?.balance?.description ?? "0")"
            cell.entry.text = "進場車站號碼：" + String(describing: history!.entryStationCode)
            cell.exit.text = "出場車站號碼：" + String(describing: history!.exitStationCode)
            

            return cell
        }

        return tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
    }
}
