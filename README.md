# Java Practice Programs

[![Java Programs - Compile & Run All](https://github.com/Abhijeet-Kumar-Prajapati/MULTIPLE-JAVA-PRACTICE-PROGRAMS---ALL-IN-ONE-LAUNCHER/actions/workflows/java-programs.yml/badge.svg)](https://github.com/Abhijeet-Kumar-Prajapati/MULTIPLE-JAVA-PRACTICE-PROGRAMS---ALL-IN-ONE-LAUNCHER/actions/workflows/java-programs.yml)

A collection of **40 Java programs** I wrote while learning core programming concepts —
covering DSA, OOP, data structures and small projects.

> Part of my BTech (IT) coursework and self-practice.

---

## 🚀 Quick Start (Windows)

Saare 40 programs ek hi jagah se chalane ke liye — **bas `RUN_ME.bat` double-click karo.**

```
CHOOSE KYA KARNA HAI
  1   Ek ya kai programs chalao    (number ya range: 3,7,12 | 5-9 | all)
  2   Category se chalao            (DSA / OOP / Core / Basic / Projects)
  3   Naam se search               (jaise: sort, inherit, matrix)
  4   RUN ALL - sab ek saath       (poora output ek hi jagah)
  5   Output report kholo          (pichli run ka pura record)
  6   Sab dobara compile karo
  7   Project folder kholo
  0   Exit
```

Kuch points:

- **Ek ya kai chuno** — `7`, `3,7,12`, `5-9`, `2,5-8` ya `all`. Ek se zyada chunne par
  har program ka output screen par hi dikhta hai.
- **Input wale programs** (Factorial, Matrix, Prime Check…) batch me sample input khud
  bharte hain, taaki koi atke nahi.
- **GUI programs** (Snake Game, Library Management, Scientific Calculator,
  Event Handling) window kholte hain, isliye batch me skip hote hain — menu se number
  daal ke khud chala sakte ho.
- Har program ka **time limit** 5 second hai, taaki koi atke nahi.

Compiled output `build/` folder me jaata hai (`.gitignore` me already hai),
aur pura report `build/run-all-output.txt` me milta hai.

---

## ☁️ GitHub Actions

Har push par ye workflow **apne aap** saare programs compile aur run karta hai.

[![Actions](https://github.com/Abhijeet-Kumar-Prajapati/MULTIPLE-JAVA-PRACTICE-PROGRAMS---ALL-IN-ONE-LAUNCHER/actions/workflows/java-programs.yml/badge.svg)](https://github.com/Abhijeet-Kumar-Prajapati/MULTIPLE-JAVA-PRACTICE-PROGRAMS---ALL-IN-ONE-LAUNCHER/actions/workflows/java-programs.yml)

Kya hota hai:

1. Java 17 install hota hai
2. 40 programs compile hote hain
3. 36 console programs **actually chala ke** har ek ka output nikalta hai
4. Bada markdown report Actions page par dikhta hai — har program ka status + output
5. Output artifact ki tarah download bhi ho jaata hai

Workflow file: [`.github/workflows/java-programs.yml`](.github/workflows/java-programs.yml)
Engine: [`.github/run-all.sh`](.github/run-all.sh)

Manually chalana hai? **Actions tab → "Java Programs - Compile & Run All" → Run workflow**

---

## 📂 What's inside

### 🧮 Data Structures & Algorithms

| Topic | Folder |
|---|---|
| Sorting | `BubbleSort` · `MergeSort` · `QuickSort` |
| Searching | `Linear_Binary_Search` |
| Linear | `Stack` · `Queue` |
| Graphs | `DFS_BFS` · `Dijktra's` · `Kruskal's` · `Huffman` |

### 🎓 Object-Oriented Programming

| Concept | Folder |
|---|---|
| Inheritance | `Inheritance` |
| Multiple Inheritance (via interface) | `Multiple_Inheritance` |
| Method Overloading | `Method_Overloading` |
| Method Overriding | `Method_Overriding` |
| Classes, Objects & Methods | `Class_Object_Method` |
| Static variables & blocks | `Employee/Static_varaible` · `Static_Block` |
| Method Dispatch | `Method_Dispatch` |

### ⚙️ Core Concepts

| Topic | Folder |
|---|---|
| Exception Handling | `Exception_Handling` |
| Event Handling | `Event_Handling` |
| Encapsulation | `Student` |

### 🛠️ Standalone Projects

| Project | File |
|---|---|
| Scientific Calculator | `ScientificCalculator.java` |
| Library Management System | `Library_Management.java` |
| Snake Game | `SnakeGame.java` |
| Sandglass Pattern | `sandglass_pattern.java` |

### 🔢 Basic Practice

Factorial · Matrix Addition · Matrix Multiplication · Max/Min Finder ·
Prime Check · Reverse Array · Sum of Natural Numbers · Operators ·
OOP Basics · Method Dispatch · Negative Value Exception

### 🌐 JS Practice

`console.js` · `Sorry_babe.js`

---

## 🛠️ How to run (manually)

Compile and run any file:

```bash
javac Main.java
java Main
```

Or run a single file directly (Java 11+):

```bash
java Main.java
```

Ya Linux/macOS par launcher:

```bash
chmod +x .github/run-all.sh
./.github/run-all.sh
```

---

## 📌 Note

- Aapke **kisi `.java` source file ko touch nahi kiya gaya** — launcher aur workflow
  bilkul naye files hain, sirf output `build/` me jaata hai.
- Compiled `.class` files aur `build/` folder `.gitignore` me hain — wo build
  output hai, source code nahi.
- `.gitattributes` ensure karta hai ke shell scripts LF line-endings ke saath rahein,
  warna GitHub Actions par `bad interpreter` error aa jaata hai.
- These are learning programs. Some are intentionally simple as they were
  written while practising each concept for the first time.

---

## 📫 Contact

- **Email:** [abhijeet943935@gmail.com](mailto:abhijeet943935@gmail.com)
- **GitHub:** [@Abhijeet-Kumar-Prajapati](https://github.com/Abhijeet-Kumar-Prajapati)

---

<sub>Made with ☕ while learning Java · Abhijeet Kumar Prajapati</sub>