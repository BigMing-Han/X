//
//  TableView.swift
//  Pods
//
//  Created by 刘强 on 2017/8/22.
//
//

import UIKit

public class TableList: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    
    private var sectionRows:[Int]? = nil
    private var cells:[[UITableViewCell]]? = nil
    
    //cell选中状态
    private var offCellSelected = false
    
    //监听事件
    private var onFooter:(() -> Void)? = nil
    private var onHeader:(() -> Void)? = nil
    private var onClick:((UITableViewCell, IndexPath) -> Void)? = nil
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化数组cell
    public func initCells(cells: [[UITableViewCell]])
    {
        self.cells = cells
        var sectionRows: [Int] = []
        for i in cells
        {
            sectionRows.append(i.count)
        }
        
        self.sectionRows = sectionRows
    }
    
    //获取单个cell
    public func getCell(section: Int, row: Int) -> UITableViewCell?
    {
        if let Scells = self.cells?[section]
        {
            if row < Scells.count
            {
                return Scells[row]
            }
        }
        
        return nil
    }
    
    //插入一组cell
    public func insertSection(cells:[UITableViewCell], section:Int? = nil)
    {
        var section = section
        if section == nil
        {
            section = (self.cells?.count)!
        }
        
        //更改数组
        self.cells?.insert(cells, at: section!)
        self.sectionRows?.insert(cells.count, at: section!)
        
        self.beginUpdates()
        let indexset = NSIndexSet(index: section!) as IndexSet
        self.insertSections(indexset, with: UITableViewRowAnimation.fade)
        self.endUpdates()
    }
    
    //重载一组cell
    public func reloadSectionData(cells: [UITableViewCell], section: Int)
    {
        if self.cells?[section] != nil
        {
            self.cells?[section] = cells
            let indexset = IndexSet.init(integer: section)
            self.reloadSections(indexset, with: UITableViewRowAnimation.fade)
        }
    }
    
    //插入某组的一个cell
    public func insertRow(cell: UITableViewCell, section:Int, row:Int? = nil)
    {
        if section >= (self.cells?.count)!
        {
            return
        }
        
        var row = row
        if row == nil
        {
            if section < (self.cells?.count)!
            {
                row = (self.cells?[section].count)!
            }else
            {
                row = 0
            }
        }
        
        //更改数组
        self.cells?[section].insert(cell, at: row!)
        self.sectionRows?[section] += 1
        
        self.beginUpdates()
        let indexPaths:[IndexPath] = [IndexPath.init(row: row!, section: section)]
        self.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        self.endUpdates()
        
    }
    
    //重载某组的一个cell
    public func reloadRowData(cell: UITableViewCell, section:Int, row: Int)
    {
        if let _ = self.getCell(section: section, row: row)
        {
            self.cells?[section][row] = cell
            self.reloadRows(at: [IndexPath(row: row, section: section)], with: UITableViewRowAnimation.fade)
        }
    }
    
    //添加到底监听
    public func addListener(onFooter: @escaping () -> Void)
    {
        self.onFooter = onFooter
    }
    
    //添加到顶监听
    public func addListener(onHeader: @escaping () -> Void)
    {
        self.onHeader = onHeader
    }
    
    //添加点击监听
    public func addListener(onClick: @escaping (UITableViewCell, IndexPath) -> Void)
    {
        self.onClick = onClick
    }
    
    //关闭cell选中效果
    public func offCellSelectedStyle()
    {
        self.offCellSelected = true
    }
    
    
    //代理
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("number:\(tableView.numberOfSections) section:\(section)" )
        
        if section < (self.sectionRows?.count)!
        {
            return self.sectionRows![section]
        }else
        {
            return 1
        }
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if let cell = self.getCell(section: section, row: row)
        {
            if self.offCellSelected
            {
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }else{
                cell.selectionStyle = UITableViewCellSelectionStyle.default
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return (self.sectionRows?.count)!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if let cell = self.getCell(section: section, row: row)
        {
            return cell.frame.height
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.onFooter != nil
        {
            if tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height
            {
                self.onFooter!()
            }
        }
        
        if self.onHeader != nil
        {
            if tableView.contentOffset.y < -20
            {
                self.onHeader!()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        
        
        if let cell = self.getCell(section: section, row: row)
        {
            if self.onClick != nil
            {
                self.onClick!(cell, indexPath)
            }
        }
    }
    
    
}
