# MO5 FPGA Implementation Setup Guide

## Hardware Requirements

- DE1 Development Board with Altera/Intel FPGA
- PS/2 keyboard
- VGA monitor
- SD card
- Micro USB cable for programming
- Speaker or headphones (optional)

## Software Requirements

- Quartus Prime Programmer (or Quartus II)
- MO5 FPGA configuration file (.sof or .pof)
- MO5 BASIC ROM image
- SD card utility software

## Setup Procedure

### 1. Preparing the FPGA Configuration

#### Using .sof file (Volatile Programming)

1. Connect your DE1 board to your computer using the USB cable
2. Launch Quartus Programmer
3. Click "Add File" and select the MO5 .sof file
4. Check the "Program/Configure" box
5. Click "Start" to program the FPGA
6. The configuration will be lost when power is removed

#### Using .pof file (Non-volatile Programming)

1. Connect your DE1 board to your computer using the USB cable
2. Launch Quartus Programmer
3. Set mode to "Active Serial Programming"
4. Click "Add File" and select the MO5 .pof file
5. Check the "Program/Configure" and "Verify" boxes
6. Click "Start" to program the flash memory
7. The configuration will persist across power cycles

### 2. Flash Memory Setup

The DE1 board's flash memory must be programmed with the MO5 BASIC ROM:

1. Prepare your MO5 BASIC ROM image (.bin format)
2. Convert the ROM image to a compatible hex format if needed:
   ```
   $ bin2hex basic.bin basic.hex
   ```
3. Program the flash memory with the BASIC ROM at the correct address (either through Quartus or use Altera's flash programmer)
4. Verify the programming was successful

### 3. SD Card Preparation

Based on the information available at dcmoto.free.fr:

1. Format an SD card as FAT16 or FAT32
2. Create a directory structure matching the MO5 disk organization:
   ```
   SD_CARD/
   ├── MO5/
   │   ├── BASIC/
   │   ├── GAMES/
   │   └── APPS/
   ```
3. Download MO5 software from dcmoto.free.fr
4. Convert the software to the appropriate format:
   - For cassette files (.k7), use the conversion tools mentioned on dcmoto.free.fr
   - For disk images (.fd), extract them using the appropriate utility
5. Place the converted files in the corresponding directories

### 4. Physical Connections

1. Insert the prepared SD card into the DE1 board's SD slot
2. Connect a PS/2 keyboard to the PS/2 port
3. Connect a VGA monitor to the VGA port
4. Connect speakers to the audio output (if desired)
5. Connect the power supply to the DE1 board

### 5. System Configuration

After powering on the DE1 board:

1. Set the keyboard layout using the switches SW[1:0]:
   - 00: QWERTY layout
   - 01: AZERTY (French) layout
   - 10/11: Direct mapping

2. Set the CPU speed using switch SW[2]:
   - 0: 1MHz (original MO5 speed)
   - 1: 10MHz (accelerated mode)

3. The system should boot into MO5 BASIC automatically

### 6. Troubleshooting

- If the system doesn't boot, press KEY[0] to perform a hardware reset
- Check the LED indicators for system status:
  - LEDG[4-5]: Light pen status
  - LEDR: Switch status
  - LEDG[3:0]: Key status
- The 7-segment displays show the current CPU address for debugging

## Usage Notes

- Use Ctrl+Alt+Del to perform a software reset
- The MO5 BASIC commands should work as in the original system
- To access files on the SD card, use the appropriate BASIC commands or utilities from dcmoto.free.fr
- The system emulates the original MO5 hardware but with enhanced capabilities (higher resolution, faster CPU option, etc.)

## Additional Resources

- dcmoto.free.fr: Source for MO5 software and documentation
- DE1 board manual: For details on FPGA board configuration
- MO5 user manual: For information on MO5 BASIC commands and usage

## Common Issues

- SD card not recognized: Ensure it's formatted correctly and contains the proper directory structure
- Keyboard not working: Check PS/2 connection and keyboard layout setting
- No display: Verify VGA connection and monitor compatibility
- Flash memory issues: Re-program the flash with the BASIC ROM
