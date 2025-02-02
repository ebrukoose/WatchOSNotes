//
//  ContentView.swift
//  Notes Watch App
//
//  Created by EBRU KÖSE on 11.08.2024.
//
import SwiftUI

struct ContentView: View {
    // MARK: - Property
    @State private var notes: [Note] = [Note]()
    @State private var text: String = ""

    // MARK: FUNCTION
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            let url = getDocumentDirectory().appendingPathComponent("notes")
            try data.write(to: url)
        } catch {
            print("Saving data has failed")
        }
    }

    func load() {
        DispatchQueue.main.async {
            do {
                let url = getDocumentDirectory().appendingPathComponent("notes")
                let data = try Data(contentsOf: url)
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                // do nothing
            }
        }
    }

    func delete(offsets: IndexSet) {
        withAnimation {
            notes.remove(atOffsets: offsets)
            save()
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {  // NavigationView burada eklendi
            VStack {
                HStack(alignment: .center, spacing: 6) {
                    TextField("Add new notes", text: $text)
                    Button {
                        guard text.isEmpty == false else { return }

                        let note = Note(id: UUID(), text: text)
                        notes.append(note)
                        text = ""
                        save()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .font(.system(size: 42, weight: .semibold))
                    .fixedSize()
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.yellow)
                }
                Text("Notes")
                    .font(.headline)
                    .padding(.top, -150)
                    .foregroundColor(.yellow)

                Spacer()

                if notes.count >= 1 {
                    List {
                        ForEach(0..<notes.count, id: \.self) { i in
                            NavigationLink(destination: DetailView(note: notes[i], count: notes.count, index: i)) {
                                HStack {
                                    Capsule()
                                        .frame(width: 4)
                                        .foregroundColor(.accentColor)
                                    Text(notes[i].text)
                                        .lineLimit(1)
                                        .padding(.leading, 5)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                } else {
                    Spacer()
                    Image(systemName: "note.text")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .opacity(0.25)
                        .padding(25)
                    Spacer()
                }

                Text("\(notes.count)")
            }
            .onAppear(perform: load)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

