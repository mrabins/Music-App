/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
    @IBOutlet var scroller: HorizontalScroller!
    
    fileprivate var allAlbums = [Album]()
    fileprivate var currentAlbumData : (titles: [String], values: [String])?
    fileprivate var currentAlbumIndex = 0

    var undoStack: [(Album, Int)] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isTranslucent = false
        currentAlbumIndex = 0
        
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        
        dataTable.backgroundView = nil
        view.addSubview(dataTable!)
        
        self.showDataFromAlbum(currentAlbumIndex)
        loadPreviousState()
        scroller.delegate = self
        reloadScroller()
        
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(ViewController.undoAction))
        undoButton.isEnabled = false
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target:  nil, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: . trash, target: self, action: #selector(ViewController.deleteAlbum))
        let toolbarButtonItems = [undoButton, space, trashButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
    }
    
    func showDataFromAlbum(_ albumIndex: Int) {
        
        //defensive code: make sure the requested index is lower than the amount of albums
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            //fetch the album
            let album = allAlbums[albumIndex]
            //save the albums data to present it later in the tableview
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        dataTable!.reloadData()
    }
    
    func initialViewIndex(_ scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if let albumData = currentAlbumData {
                return albumData.titles.count
            } else {
                return 0
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
            if let albumData = currentAlbumData {
                cell.textLabel!.text = albumData.titles[(indexPath as NSIndexPath).row]
                cell.detailTextLabel!.text = albumData.values[(indexPath as NSIndexPath).row]
            }
            return cell
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: HorizontalScrollerDelegate {
    func horizontalScrollerClickedViewAtIndex(_ scroller: HorizontalScroller, index: Int) {
        //1
        let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(false)
        //2
        currentAlbumIndex = index
        //3
        let albumView = scroller.viewAtIndex(index) as! AlbumView
        albumView.highlightAlbum(true)
        //4
        (index)
    }
    
    func  numberOfViewsForHorizontalScroller(_ scroller: HorizontalScroller) -> Int {
        return allAlbums.count
    }
    
    func horizontalScrollerViewAtIndex(_ scroller: HorizontalScroller, index: Int) -> UIView {
        let album = allAlbums[index]
        let albumView = AlbumView(frame:  CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(true)
        } else {
            albumView.highlightAlbum(false)
        }
        return albumView
    }
    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        scroller.reload()
        showDataFromAlbum(currentAlbumIndex)
    }
    
    //MARK: Memento Pattern
    func saveCurrentState(){
        UserDefaults.standard.set(currentAlbumIndex, forKey: "currentAlbumIndex")
        LibraryAPI.sharedInstance.saveAlbums()

    }
    func loadPreviousState() {
        currentAlbumIndex = UserDefaults.standard.integer(forKey: "currentAlbumIndex")
        showDataFromAlbum(currentAlbumIndex)
    }
    
    func addAlbumAtIndex(_ album: Album, index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    func deleteAlbum() {
        let deletedAlbum : Album = allAlbums[currentAlbumIndex]
        
        let undoAction = (deletedAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, at: 0)
        
        LibraryAPI.sharedInstance.deleteAlbum(currentAlbumIndex)
        reloadScroller()
        
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
    
        
            
        let undoButton : UIBarButtonItem = barButtonItems[0]
        undoButton.isEnabled = true
        
        if (allAlbums.count) == 0 {
            let trashButton : UIBarButtonItem = barButtonItems[2]
            trashButton.isEnabled = false
        }

    }
    
    func undoAction() {
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.remove(at: 0)
            addAlbumAtIndex(deletedAlbum, index: index)
        }
        if undoStack.count == 0 {
            let undoButton: UIBarButtonItem = barButtonItems[0]
            undoButton.isEnabled = false
        }
        let trashButton : UIBarButtonItem = barButtonItems[2]
        trashButton.isEnabled = true
    }

}



