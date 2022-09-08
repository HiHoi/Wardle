//
//  ViewController.swift
//  Wardle
//
//  Created by Hosung Lim on 2022/09/02.
//

import UIKit


//Keyboard
//Gameboard
//UI
//orange and green

class ViewController: UIViewController {
    
    let answers = [
        "after", "there", "later", "broke", "ultra"
    ]
    
    var answer = ""
    
    
    
    private var guesses : [[Character?]] = Array(
        repeating: Array(repeating: nil, count: 5),
        count: 6
    )
    
    let keyboardVC = KeyboardViewController()
    let boardVC = BoardViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //단어 호출
        let urlString = "https://thatwordleapi.azurewebsites.net/get/"
        if let url = URL(string: urlString){
            let session = URLSession.shared
            session.dataTask(with: url) { data, reponse, error in
                if let data = data {
                    do {
                        let word : Word = try JSONDecoder().decode(Word.self, from: data)
                        print(word)
                    } catch let error {
                        print(error)
                    }
                }
            }.resume()
        }
        answer = answers.randomElement() ?? "after"
        view.backgroundColor = .systemGray6
        addChildren()
    }

    private func addChildren() {
        addChild(keyboardVC)
        keyboardVC.didMove(toParent: self)
        keyboardVC.delegate = self
        keyboardVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardVC.view)
        
        addChild(boardVC)
        boardVC.didMove(toParent: self)
        boardVC.view.translatesAutoresizingMaskIntoConstraints = false
        boardVC.datasource = self
        view.addSubview(boardVC.view)
        
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            boardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            boardVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            boardVC.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            boardVC.view.bottomAnchor.constraint(equalTo: keyboardVC.view.topAnchor),
            
            keyboardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension ViewController: KeyboardViewControllerDelegate {
    func keyboardViewController(_ vc: KeyboardViewController, didTapKey letter: Character) {
        
        //update guesses
        var stop = false
        
        for i in 0..<guesses.count {
            for j in 0..<guesses[i].count {
                if guesses[i][j] == nil {
                    guesses[i][j] = letter
                    stop = true
                    break
                }
            }
            if stop {
                break
            }
        }
        
        boardVC.reloadData()
    }
}

extension ViewController: BoardViewControllerDataSource {
    var currentGuesses: [[Character?]] {
        return guesses
    }
    
    func boxColor(at indexPath: IndexPath) -> UIColor? {
        let rowIndex =  indexPath.section
        
        let count = guesses[rowIndex].compactMap({ $0 }).count
        guard count == 5 else {
            return nil
        }
        
        let indexedAnswer = Array(answer)
        guard let letter = guesses[indexPath.section][indexPath.row],
              indexedAnswer.contains(letter) else {
            return nil
        }
        
        if indexedAnswer[indexPath.row] == letter {
            return .systemGreen
        }
        
        return .systemOrange
    }
}
