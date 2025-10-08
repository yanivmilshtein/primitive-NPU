# Mini Neural Processing Unit (NPU) — Verilog Implementation

A small-scale **Neural Processing Unit (NPU)** designed and implemented in **Verilog HDL**, synthesized and analyzed using **Intel Quartus**.  
This project was created as a learning exercise to deepen understanding of **hardware acceleration**, **digital design**, and **neural computation**.

---

## 🧠 Project Overview
This mini NPU simulates the basic computation flow of a neural network layer — performing **multiply–accumulate (MAC)** operations, adding a **bias vector**, and applying a **ReLU activation**.

It’s a simplified and modular design intended as a foundation (v1) for future versions with features such as pipelining, zero-detection, and support for larger network sizes.

---

## ⚙️ Design Hierarchy

### 1. `MAC_Element.v`
- Performs a single multiply–accumulate operation:  
  `acc_out = acc_in + (x_i * w_i)`
- Detects falling edge of reset (`rst`).
- Works on **negative clock edge** for easier testbench synchronization.

### 2. `ROW_Element.v`
- Instantiates **three MAC elements** (3×3 layer).  
- Accumulates outputs to produce one neuron output (dot product of input and weight vectors).

### 3. `controller.v`
- Top-level module.  
- Instantiates **three ROW elements** to compute all neuron outputs.  
- Adds **bias vector (b)** and applies **ReLU activation**.  
- Provides the final output vector.

---

## 🧩 Simulation
All modules were simulated using **ModelSim**.  
The testbenches verify correct accumulation, activation, and reset behavior.

Example testbench:  
`tb_MAC_Element.v`  
`tb_ROW_Element.v`  
`tb_controller.v`

---

## 🖥️ Synthesis and RTL View
Synthesized in **Intel Quartus Prime Lite Edition**.  
RTL Viewer confirms proper hierarchical structure (MAC → ROW → Controller).  
The screenshot below shows the v1 design synthesized into logic blocks:

<img width="1249" height="399" alt="MAC_Element_RTL" src="https://github.com/user-attachments/assets/ab4b6edd-123a-4b6a-b391-d4f148a8d7b3" />
<img width="792" height="677" alt="ROW_Elemnt_RTL" src="https://github.com/user-attachments/assets/08bc679c-f12c-4218-8c9f-aebd248f2566" />
<img width="1608" height="816" alt="top_view_RTL" src="https://github.com/user-attachments/assets/32208be6-7659-459d-8aba-46365847ab9a" />





---

## 🚀 Next Steps (v2 Plan)
- Add **pipelining** for higher throughput  
- Introduce **FSM control** for sequential operations  
- Implement **zero-detection** optimization  
- Explore integration into a small multi-layer network

---

## 📚 Learning Goals
This project was an opportunity to:
- Bridge the gap between **theoretical neural computation** and **hardware implementation**
- Strengthen skills in **Verilog**, **simulation**, and **FPGA synthesis**
- Explore how modern NPUs can be represented at the RTL level

---

## 📂 Repository Structure
mini-npu-verilog/
├── src/
│ ├── MAC_Element.v
│ ├── ROW_Element.v
│ └── controller.v
├── testbench/
│ ├── tb_MAC_Element.v
│ ├── tb_ROW_Element.v
│ └── tb_controller.v
└── README.md
## 🧑‍💻 Author
**Yaniv Milshtein**  
Electrical Engineering Student | Hardware Enthusiast  
📫 [LinkedIn Profile] https://www.linkedin.com/in/yanivmilshtein/)

---

## 🏷️ Tags
`#FPGA` `#Verilog` `#HardwareDesign` `#DigitalSystems` `#StudentProjects` `#NPU`
