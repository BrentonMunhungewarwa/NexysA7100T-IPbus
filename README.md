# NexysA7100T-IPbus

The IPbus firmware is a scalable and efficient protocol designed for remote control and monitoring of hardware, primarily intended for FPGA-based systems. It facilitates seamless communication between a host PC and an FPGA over Ethernet or other transport protocols, enabling operations like register reads and writes.

For the Nexys A7 100T, your IPbus firmware would include:

Core Functionalities:

A lightweight, IP-based protocol for communication with the FPGA.
Support for various transport protocols like UDP/IP.
Efficient handling of register maps and firmware-controlled resources.
FPGA-Specific Implementation:

The firmware incorporates HDL modules (e.g., VHDL or Verilog) for Ethernet communication, memory-mapped register access, and decoding the IPbus protocol.
Custom logic for application-specific tasks, which can be accessed and controlled using IPbus.
Communication Link:

Ethernet MAC (Media Access Controller) integrated with the FPGA design.
UDP-based communication between the Nexys A7 board and the host machine.
Custom Features for Nexys A7 100T:

Use of the Ethernet port on the board for communication.
Integration with board peripherals like LEDs, buttons, and switches to test and verify the firmware.
Expansion of logic to interact with connected modules, sensors, or actuators.
Development and Deployment:

Developed using Xilinx Vivado for synthesis and implementation.
Ensures compatibility with the Artix-7 100T FPGA and the onboard Ethernet PHY.
Deployment via JTAG programming or storing the bitstream in the onboard SPI Flash for persistent use.
Applications:

Remote programming and monitoring of FPGA logic.
Real-time acquisition and control for embedded and experimental setups.
Suitable for lab experiments, industrial automation, and research tasks like monitoring particle detectors.
