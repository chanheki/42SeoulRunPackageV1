//
//  AppDelegate.swift
//  Run42Pack
//
//  Created by Chan on 2022/09/20.
//

import Cocoa

@main
class AppDelegate: NSWorkspace, NSApplicationDelegate, URLSessionDelegate {
	// MARK: - Setting
	
	private let nC = NSWorkspace.shared.notificationCenter
	private var isRunning: Bool = false
	private var interval: Double = 1.0
	private let cpu = CPU()
	private var cpuTimer: Timer? = nil
	private var usage: (value: Double, description: String) = (0.0, "")
	private var isShowUsage: Bool = false
	
	// MARK: - Menu Setting
	
	let mainMenu: NSMenu! = {
		.init(title: "42")
	}()
	
	var showCpuUsage: NSMenuItem! {
		.init(title: "Show CPU Usage", action: #selector(self.toggleShowUsage(_:)), keyEquivalent: "")
	}
	
	var intra42: NSMenuItem! {
		.init(title: "42 Intra", action: #selector(self.intra(_:)), keyEquivalent: "")
	}
	
	var jip42: NSMenuItem! {
		.init(title: "42 JIPHYEONJEON", action: #selector(self.jipheyonjeon(_:)), keyEquivalent: "")
	}
	
	var HANE24: NSMenuItem! {
		.init(title: "24 HANE", action: #selector(self.tfHANE(_:)), keyEquivalent: "")
	}
	
	var coding80000: NSMenuItem! {
		.init(title: "80k Coding", action: #selector(self.eightyK(_:)), keyEquivalent: "")
	}
	
	var about42Pack: NSMenuItem! {
		.init(title: "About 42 Pack", action: #selector(self.showAbout(_:)), keyEquivalent: "")
	}
	
	var quit: NSMenuItem! {
		.init(title: "Quit", action: #selector(applicationShouldTerminate(_:)), keyEquivalent: "")
	}
	
	var logo42: NSMenuItem! {
		.init(title: "logo42", action: nil, keyEquivalent: "")
	}
	
	var logoList: NSMenuItem! {
		.init(title: "logoList", action: #selector(submenuDrop(_:)), keyEquivalent: "")
	}
	
	var submenu: NSMenu! {
		.init(title: "subMenu")
	}
	
	func menuListInit() {
		logoList.target = self
		mainMenu.setSubmenu(submenu, for: logoList)
		submenu.addItem(logo42)
		submenu.addItem(withTitle: "down", action: nil, keyEquivalent: "")
		mainMenu.addItem(showCpuUsage)
		mainMenu.addItem(NSMenuItem.separator())
		mainMenu.addItem(intra42)
		mainMenu.addItem(jip42)
		mainMenu.addItem(HANE24)
		mainMenu.addItem(coding80000)
		mainMenu.addItem(NSMenuItem.separator())
		mainMenu.addItem(logoList)
		mainMenu.addItem(NSMenuItem.separator())
		mainMenu.addItem(about42Pack)
		mainMenu.addItem(quit)
	}
	
	// MARK: - status Bar setting
	
	private var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	private var frames = [NSImage]()
	private var cnt: Int = 0
	
	func barButtonInit() {
		let statusBarButton = statusBarItem.button
		imageInit("42")
		statusBarButton?.target = self
		statusBarButton?.action = #selector(self.statusBarButtonClicked(_:))
		statusBarButton?.sendAction(on: [.leftMouseDown, .rightMouseUp])
		statusBarButton?.image = frames[cnt]
		cnt = (cnt + 1) % frames.count
	}
	
	func imageInit(_ imgName: String) {
		switch imgName {
		case "cat": for i in (0 ..< 5) {frames.append(NSImage(imageLiteralResourceName: "cat_page\(i)"))}
		case "gon": for i in (1...5) {frames.append(NSImage(imageLiteralResourceName: "gon_\(i)"))}
		case "gun":	for i in (1...5) {frames.append(NSImage(imageLiteralResourceName: "gun_\(i)"))}
		case "lee":	for i in (1...5) {frames.append(NSImage(imageLiteralResourceName: "lee_\(i)"))}
		case "gam":	for i in (1...5) {frames.append(NSImage(imageLiteralResourceName: "gam_\(i)"))}
		default : for i in (1...11) {frames.append(NSImage(imageLiteralResourceName: "42flip_0\(i)"))}
		}
	}
	
	@objc func submenuDrop(_ sender: NSStatusBarButton) {
		let event = NSApp.currentEvent!
		if event.type == NSEvent.EventType.rightMouseDown {
			statusBarItem.menu = nil
		} else {
			statusBarItem.menu = nil
		}
	}
	
	@objc func statusBarButtonClicked(_ sender: NSStatusBarButton?) {
		print(sender!.title)
		
		let event = NSApp.currentEvent!
		if event.type == NSEvent.EventType.rightMouseDown {
			statusBarItem.menu = nil
		} else {
			statusBarItem.menu = mainMenu
			statusBarItem.button?.performClick(nil)
			statusBarItem.menu = nil
		}
	}
	
	@objc func logo42Selected(_ sender: Any?) {
		frames.removeAll()
		for i in (1...11) {
			frames.append(NSImage(imageLiteralResourceName: "42flip_0\(i)"))
		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		barButtonInit()
		menuListInit()
		startRunning()
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		stopRunning()
	}
	
	func setNotifications() {
		nC.addObserver(self, selector: #selector(AppDelegate.receiveSleepNote),
					   name: NSWorkspace.willSleepNotification, object: nil)
		nC.addObserver(self, selector: #selector(AppDelegate.receiveWakeNote),
					   name: NSWorkspace.didWakeNotification, object: nil)
	}
	
	@objc func receiveSleepNote() {
		stopRunning()
	}
	
	@objc func receiveWakeNote() {
		startRunning()
	}
	
	func startRunning() {
		cpuTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (t) in
			self.usage = self.cpu.usageCPU()
			self.interval = 0.02 * (100 - max(0.0, min(99.0, self.usage.value))) / 6
			self.statusBarItem.button?.title = self.isShowUsage ? self.usage.description : ""
		})
		cpuTimer?.fire()
		isRunning = true
		animate()
	}
	
	func stopRunning() {
		isRunning = false
		cpuTimer?.invalidate()
	}
	
	func animate() {
		statusBarItem.button?.image = frames[cnt]
		cnt = (cnt + 1) % frames.count
		if !isRunning { return }
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
			self.animate()
		}
	}
	
	@IBAction func toggleShowUsage(_ sender: NSMenuItem) {
		isShowUsage = sender.state == .off
		sender.state = isShowUsage ? .on : .off
		statusBarItem.button?.title = isShowUsage ? usage.description : ""
	}
	
	@IBAction func showAbout(_ sender: Any) {
		NSApp.activate(ignoringOtherApps: true)
		NSApp.orderFrontStandardAboutPanel(nil)
	}
	
	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		 The persistent container for the application. This implementation
		 creates and returns a container, having loaded the store for the
		 application to it. This property is optional since there are legitimate
		 error conditions that could cause the creation of the store to fail.
		 */
		let container = NSPersistentContainer(name: "Run42Pack")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				fatalError("Unresolved error \(error)")
			}
		})
		return container
	}()
	
	// MARK: - Core Data Saving and Undo support
	
	@IBAction func saveAction(_ sender: AnyObject?) {
		// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
		let context = persistentContainer.viewContext
		
		if !context.commitEditing() {
			NSLog("\(NSStringFromClass(Swift.type(of: self))) unable to commit editing before saving")
		}
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Customize this code block to include application-specific recovery steps.
				let nserror = error as NSError
				NSApplication.shared.presentError(nserror)
			}
		}
	}
	
	func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
		// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
		return persistentContainer.viewContext.undoManager
	}
	
	@objc func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		// Save changes in the application's managed object context before the application terminates.
		let context = persistentContainer.viewContext
		
		if !context.commitEditing() {
			NSLog("\(NSStringFromClass(Swift.type(of: self))) unable to commit editing to terminate")
			return .terminateCancel
		}
		
		if !context.hasChanges {
			return .terminateNow
		}
		
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			
			// Customize this code block to include application-specific recovery steps.
			let result = sender.presentError(nserror)
			if (result) {
				return .terminateCancel
			}
			
			let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
			let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
			let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
			let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
			let alert = NSAlert()
			alert.messageText = question
			alert.informativeText = info
			alert.addButton(withTitle: quitButton)
			alert.addButton(withTitle: cancelButton)
			
			let answer = alert.runModal()
			if answer == .alertSecondButtonReturn {
				return .terminateCancel
			}
		}
		// If we got here, it is time to quit.
		return .terminateNow
	}
	// MARK: - 42 intra feature (link)
	
	@objc func intra(_ sender: NSMenuItem) {
		let urlString = "https://profile.intra.42.fr/"
		NSWorkspace.shared.open(URL(string: urlString)!)
	}
	
	// MARK: - 42 JIP feature (link)
	
	@objc func jipheyonjeon(_ sender: NSMenuItem) {
		NSWorkspace.shared.open(URL(string: "https://42library.kr")!)
	}
	
	// MARK: - 42 24 HANE (link)
	
	@objc func tfHANE(_ sender: NSMenuItem) {
		NSWorkspace.shared.open(URL(string: "https://24hoursarenotenough.42seoul.kr/")!)
	}
	
	// MARK: - 42 80000coding (link)
	@objc func eightyK(_ sender: NSMenuItem) {
		NSWorkspace.shared.open(URL(string: "https://80000coding.oopy.io/")!)
	}
}
