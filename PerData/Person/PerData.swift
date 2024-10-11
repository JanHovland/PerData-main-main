//
//  ContentView.swift
//  PerData    
//
//  Created by Jan Hovland on 05/10/2021.
//

//
//  Comment: Control + Command + * (number keyboard)
//  Indent:  Control + Command + / (number keyboard)
//

/// https://peterfriese.dev/swiftui-concurrency-essentials-part1/
/// https://peterfriese.dev/swiftui-listview-part3/
/// https://stackoverflow.com/questions/57888032/swiftui-navigation-on-ipad-how-to-show-master-list
///
/// https://sarunw.com/posts/how-to-present-alert-in-swiftui-ios15/

///     For å få frem lokalt navn på appen:
///
///     TARGETS under Info:
///     Bundle name må være $(PRODUCT_NAME)
///     Bundle identifier må være $(PRODUCT_BUNDLE_IDENTIFIER)
///     Legg til:
///         Application has localized display name
///

///
/// iOS 15 Brings Attributed Strings to SwiftUI:
/// https://betterprogramming.pub/ios-15-attributed-strings-in-swiftui-markdown-271204bec5c1
///


import SwiftUI
import CloudKit
import Network

/*
 MainActor is a new attribute introduced in Swift 5.5 as a global actor providing an executor which performs its tasks on the main thread. When building apps, it’s important to perform UI updating tasks on the main thread, which can sometimes be challenging when using several background threads. Using the @MainActor attribute will help you make sure your UI is always updated on the main thread.
 */

/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-a-menu-when-a-button-is-pressed

///
/// A brief explanation of the basics of SwiftUI
/// https://www.hackingwithswift.com/quick-start/swiftui/
///

///
/// Status Code Definitions for Hypertext Transfer Protocol -- HTTP/1.1
/// https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
///

///
///Custom SwiftUI Environment Values Cheatsheet https://www.fivestars.blog/articles/custom-environment-values-cheatsheet/?utm_campaign=%20SwiftUI%20Weekly&utm_medium=email&utm_source=Revue%20newsletter
///

///
/// `Har kommnentert bort innholdet i ** func updatePostNummerFromCSV()
/// *for å hindre en ekstra oppdatering av ZioCode  tabellen
///
/// **bold text**
/// *italics* eller _
/// ~~strikethrough~~
/// `inline code`
///  /// [Hyperlinks](https://hyperlink.com)

///
/// Text("To **learn more**, *please* feel free to visit [SwiftUIRecipes](https://swiftuirecipes.com) for details, or check the `source code` at [Github page](https://github.com/globulus).")
///

@MainActor

struct PerData: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var message: LocalizedStringKey = ""
    @State private var title: LocalizedStringKey = ""
    
    @State         var person = Person()
    @State private var persons = [Person]()
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
    
    @State private var showNewPersonSheet = false
    
    let internetMonitor = NWPathMonitor()
    let internetQueue = DispatchQueue(label: "InternetMonitor")
    @State private var hasConnectionPath = false
    @State private var device: LocalizedStringKey = ""
    
    ///
    ///Menyen
    ///
    
    @State private var menuZipCodeUpdate = false
    @State private var menuToDo = false
    @State private var menuBirthDay = false
    @State private var menuCabin = false
    @State private var menuUserRecordView = false
    @State private var indicatorShowing = false
    @State private var isAlertActive = false
    
    @State private var menuUpdatePersonsFromJsonBackupFileView = false
    @State private var menuBackupPersonsToJsonBackupFileView = false
    
    @State private var menuUpdateUserRecordsFromJsonBackupFileView = false
    @State private var menuBackupUserRecordsToJsonBackupFileView = false
    
    @State private var menuUpdateCabinsFromBackupFileView = false
    @State private var menuBackupCabinsToJsonBackupFileView = false
    
    @State private var searchFor = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                Text("Menu")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1)), Color(#colorLiteral(red: 0.5647058824, green: 0.462745098, blue: 0.9058823529, alpha: 1))]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(16)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 80)
                    .contextMenu {
                        Menu {
                            
                            Button {
                                menuUserRecordView.toggle()
                            } label: {
                                Label("UserRecords", systemImage: "square.and.pencil")
                            }
                            
                            Button {
                                menuBirthDay.toggle()
                            } label: {
                                Label("Birthdays", systemImage: "gift")
                            }
                            
                            Button {
                                menuCabin.toggle()
                            } label: {
                                Label("Cabin reservation", systemImage: "house")
                            }
                            
                            Button {
                                menuToDo.toggle()
                            } label: {
                                Label("ToDo", systemImage: "list.dash.header.rectangle")
                            }
                            
                        } label: {
                            Label("Overview", systemImage: "questionmark.app")
                        }
                        
                        Menu {
                            Menu {
                                Button {
                                    menuUpdatePersonsFromJsonBackupFileView.toggle()
                                } label: {
                                    Label("From Json", systemImage: "square.and.pencil")
                                }
                                Button {
                                    menuBackupPersonsToJsonBackupFileView.toggle()
                                } label: {
                                    Label("To Json", systemImage: "square.and.pencil")
                                }
                            } label: {
                                Label("Person", systemImage: "questionmark.app")
                            }
                            
                            Menu {
                                Button {
                                    menuUpdateUserRecordsFromJsonBackupFileView.toggle()
                                } label: {
                                    Label("From Json", systemImage: "square.and.pencil")
                                }
                                Button {
                                    menuBackupUserRecordsToJsonBackupFileView.toggle()
                                } label: {
                                    Label("To Json", systemImage: "square.and.pencil")
                                }
                            } label: {
                                Label("UserRecord", systemImage: "questionmark.app")
                            }
                            
                            Menu {
                                Button {
                                    menuUpdateCabinsFromBackupFileView.toggle()
                                } label: {
                                    Label("From Json", systemImage: "square.and.pencil")
                                }
                                Button {
                                    menuBackupCabinsToJsonBackupFileView.toggle()
                                } label: {
                                    Label("To Json", systemImage: "square.and.pencil")
                                }
                            } label: {
                                Label("Cabin reservation", systemImage: "questionmark.app")
                            }
                            
                            Menu {
                                Button {
                                    menuZipCodeUpdate.toggle()
                                } label: {
                                    Label("From Ascii", systemImage: "square.and.pencil")
                                }
                            } label: {
                                Label("ZipCode", systemImage: "questionmark.app")
                            }
                            
                        } label: {
                            Label("Update", systemImage: "questionmark.app")
                        }
                    }
                    .sheet(isPresented: $menuZipCodeUpdate, content: {
                        zipCodeUpdate()
                    })
                    .sheet(isPresented: $menuToDo, content: {
                        toDoView()
                    })
                    .sheet(isPresented: $menuBirthDay, content: {
                        
                    })
                    .sheet(isPresented: $menuCabin, content: {
                        cabinOverView()
                    })
                    .sheet(isPresented: $menuUpdatePersonsFromJsonBackupFileView, content: {
                        updatePersonsFromJsonBackupFileView()
                    })
                    .sheet(isPresented: $menuBackupPersonsToJsonBackupFileView, content: {
                        backupPersonsToJsonBackupFileView()
                    })
                    .sheet(isPresented: $menuUserRecordView, content: {
                        //                        userRecordOverView()
                        userRecordOverViewIndexed()
                    })
                    .sheet(isPresented: $menuBackupUserRecordsToJsonBackupFileView, content: {
                        backupUserRecordsToJsonBackupFileView()
                    })
                    .sheet(isPresented: $menuUpdateUserRecordsFromJsonBackupFileView, content: {
                        updateUserRecordsFromJsonBackupFileView()
                    })
                
                    .sheet(isPresented: $menuBackupCabinsToJsonBackupFileView, content: {
                        backupCabinsToJsonBackupFileView()
                    })
                
                    .sheet(isPresented: $menuUpdateCabinsFromBackupFileView, content: {
                        updateCabinsFromJsonBackupFileView()
                    })
                
                
                List {
                    ForEach(searchFor == "" ? persons : persons.filter { $0.firstName.starts(with: searchFor)}) { person in
                        NavigationLink(destination: PersonUpdateView(person: person)) {
                            VStack (alignment: .leading) {
                                PersonDetailView(person: person)
                                HStack {
                                    PersonDetailMapView(person: person)
                                    PersonDetailPhoneView(person: person)
                                    PersonDetailMessageView(person: person)
                                    PersonDetailMailView(person: person)
                                    PersonDetailCabinView(person: person)
                                }
                            }
                        }
                    }
                    
                    .onDelete { (indexSet) in
                        indexSetDelete = indexSet
                        recordID = persons[indexSet.first!].recordID
                        persons.removeAll()
                        Task.init {
                            await message = deletePerson(recordID!)
                            title = "Delete a person"
                            isAlertActive.toggle()
                            ///
                            /// Viser resten av personene
                            ///
                            await FindAllPersons()
                        }
                    }
                }
                .searchable(text: $searchFor, placement: .navigationBarDrawer, prompt: "Search firstName")
                .refreshable {
                    await FindAllPersons()
                }
            }
            .alert(title, isPresented: $isAlertActive) {
                Button("OK", action: {})
            } message: {
                Text(message)
            }
            
            ///
            /// Utføres  ved oppstart
            ///
            
            .task {
                startInternetTracking()
                ///
                /// Må legge inn en forsinkelse fordi
                /// usleep() takes millionths of a second
                usleep(500000) /// 0.5 S
                if hasInternet() == false {
                    if UIDevice.current.localizedModel == "iPhone" {
                        device = "iPhone"
                    } else if UIDevice.current.localizedModel == "iPad" {
                        device = "iPad"
                    }
                    title = device
                    message = "No Internet connection for this device."
                    isAlertActive.toggle()
                } else {
                    if persons.count == 0 {
                        indicatorShowing = true
                        await FindAllPersons()
                        indicatorShowing = false
                    }
                }
            }
            .navigationBarTitle("PersonOverView", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    ControlGroup {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            ReturnFromMenuView(text: "SignInView")
                        }
                    }
                    .controlGroupStyle(.navigation)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewPersonSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showNewPersonSheet, content: {
                        PersonNewView(person: person)
                    })
                }
                
            })
            
            .listStyle(.insetGrouped)
        }
        
        ///
        /// Enkel kolonne for iPad
        ///
        
        .navigationViewStyle(StackNavigationViewStyle())
        
        ///
        /// Dobbel kolonne for iPad
        /// .navigationViewStyle(DoubleColumnNavigationViewStyle())
        ///
        
    }
    
    func FindAllPersons() async {
        var value: (LocalizedStringKey, [Person], [String])
        await value = findPersons()
        if value.0 != "" {
            message = value.0
            title = "Error message from the Server"
            isAlertActive.toggle()
        } else {
            persons = value.1
        }
    }
    
    func startInternetTracking() {
//        // Only fires once
//        guard internetMonitor.pathUpdateHandler == nil else {
//            return
//        }
//        internetMonitor.pathUpdateHandler = { update in
//            if update.status == .satisfied {
//                self.hasConnectionPath = true
//            } else {
//                self.hasConnectionPath = false
//            }
//        }
//        internetMonitor.start(queue: internetQueue)
    }
    
    /// Will tell you if the device has an Internet connection
    /// - Returns: true if there is some kind of connection
    func hasInternet() -> Bool {
        return true // hasConnectionPath
    }
    
    
}
