import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controller: Controller
    
    #if os(macOS)
    var body: some View {
        HStack {
            TabView {
                PilotProfileView()
                    .environmentObject(controller.pilot)
                    .tabItem { Text("Pilot") }
                QuestionnaireView(pilot: controller.pilot)
                    .environmentObject(controller.questionnaire)
                    .tabItem { Text("Questions") }
            }.padding()
            ResultsView()
                .environmentObject(controller)
                .padding(.top, 20)
                .tabItem { Text("Results") }
        }.navigationTitle("Flight Assessment of Risk Tool")
    }
    
    #else
    var body: some View {
        TabView {
            NavigationView {
                PilotProfileView()
                    .environmentObject(controller.pilot)
                    .navigationTitle("Pilot Profile")
            }.tabItem { Label("Pilot", image: "Pilot") }
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                QuestionnaireView(pilot: controller.pilot)
                    .environmentObject(controller.questionnaire)
                    .navigationTitle("Questionnaire")
            }.tabItem { Label("Questions", image: "Questionnaire") }
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                ResultsView()
                    .environmentObject(controller)
                    .navigationTitle("Results")
            }.tabItem { Label("Results", image: "Results") }
            .navigationViewStyle(StackNavigationViewStyle())

            
            NavigationView {
                AboutView().navigationTitle("About")
            }.tabItem { Label("About", systemImage: "info.circle") }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Controller())
    }
}
