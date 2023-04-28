//
//  ContentView.swift
//  ChatGPT3
//
//  Created by Abhijeet Ranjan  on 28/04/23.
//

import SwiftUI
import OpenAISwift


final class ViewModel: ObservableObject {
    init() {}

    private var client: OpenAISwift?

    func setup() {
        client = OpenAISwift(authToken: "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")
    }

    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()

    var body: some View {
        VStack {
            HStack {
                Text("Chat GPT")
                    .font(.largeTitle)
                    .bold()
                Image(systemName: "cpu.fill")
                    .font(.title)
                    .foregroundColor(.teal)
            }
            ScrollView {
                ForEach(models, id: \.self) { message in
                    if message.contains("[USER]") {
                        let newMessage = message.replacingOccurrences(of: "[USER]", with: "")
                        HStack {
                            Spacer()
                            Text(newMessage)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.teal.opacity(0.8))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                        }
                    } else {
                        HStack {
                            Text(message)
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                    }
                }.rotationEffect(.degrees(180))
                
            }.rotationEffect(.degrees(180))
            
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            HStack {
                TextField("Type your query", text: $text)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .onSubmit {
                        send()
                        self.text = ""
                    }
                Button {
                    send()
                    self.text = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title)
                        .padding(.horizontal, 10)
                        .foregroundColor(.teal)

                }
            }
            .onAppear {
                viewModel.setup()
            }
        }
    }

    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        models.append("[USER]" + text)
        viewModel.send(text: text){ response in
            DispatchQueue.main.async {
                self.models.append(response)
                
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
