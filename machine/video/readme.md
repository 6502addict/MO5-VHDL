# MO5 Video System Implementation for Intel/Altera FPGA

This repository contains a VHDL implementation of the Thomson MO5 video system for Intel/Altera FPGA platforms. The implementation recreates the distinctive dual-memory video architecture of the original MO5 computer.

## Overview of MO5 Video Architecture

The Thomson MO5 computer (released in 1984) featured a unique video memory architecture that used two separate 8K memory banks:

1. **FORME (Shape) Memory**: Contains the pixel/shape data (1 bit per pixel, 8 pixels per byte)
2. **COULEUR (Color) Memory**: Contains the color information where each byte defines foreground (4 bits) and background (4 bits) colors for a corresponding 8-pixel group in the FORME memory

A special signal named "FORME" from the system's PIA (Peripheral Interface Adapter) selects which memory bank is mapped to the CPU address space at any given time:
- When FORME = 1: CPU accesses the pixel/shape data
- When FORME = 0: CPU accesses the color data

## Technical Implementation

### Memory Mapping

The MO5's video memory is mapped into the FPGA's SRAM at specific locations. The `MO5_RAM` module handles the address translation:

```vhdl
ram_address <= "000" & x"0" & address(11 downto 0) when (address(15 downto 12) = x"0") and forme = '1'    else  -- $0000 forme memory
               "000" & x"1" & address(11 downto 0) when (address(15 downto 12) = x"0") and forme = '0'    else  -- $0000 color memory
               "000" & x"2" & address(11 downto 0) when (address(15 downto 12) = x"1") and forme = '1'    else  -- $1000 forme memory
               "000" & x"3" & address(11 downto 0) when (address(15 downto 12) = x"1") and forme = '0'    else  -- $0000 color memory
```

This implementation places:
- FORME memory for first 4K at SRAM address 0x00000-0x00FFF
- COLOR memory for first 4K at SRAM address 0x01000-0x01FFF
- FORME memory for second 4K at SRAM address 0x02000-0x02FFF
- COLOR memory for second 4K at SRAM address 0x03000-0x03FFF

### Video Generation Pipeline

The video generation uses a multi-stage pipeline:

1. **VGA Controller** (`vga_ctrl.vhd`): Generates standard VGA timing signals (HSYNC, VSYNC) and provides current row/column coordinates

2. **Address Translation** (`vga_translate_1024x768.vhd`): Converts VGA coordinates to MO5 memory addresses
   - Scales the MO5's 320x200 resolution to display properly on a VGA monitor
   - Generates border areas when outside the active display region

3. **Memory Access**:
   - `shape.vhd`: Dual-port RAM implementation for the FORME (pixel) memory
   - `color.vhd`: Dual-port RAM implementation for the COULEUR (color) memory

4. **Pixel Selection** (`pixel_selector.vhd`): Extracts the appropriate bit from each byte in the FORME memory

5. **Color Selection** (`color_selector.vhd`): Determines the final pixel color based on:
   - The pixel value from FORME memory (0 or 1)
   - The foreground/background colors from COULEUR memory
   - Border color when in border regions
   - Display mode (blanking, border, or active area)

6. **Palette** (`vga_mo5_palette.vhd`): Converts the 4-bit color indices to RGB values

### Color Palette

The MO5 had a fixed 16-color palette:

| Index | Color Name    | RGB Value (Decimal) |
|-------|---------------|---------------------|
| 0     | BLACK         | R=0, G=0, B=0       |
| 1     | RED           | R=255, G=0, B=0     |
| 2     | GREEN         | R=0, G=255, B=0     |
| 3     | YELLOW        | R=255, G=255, B=0   |
| 4     | BLUE          | R=42, G=42, B=255   |
| 5     | MAGENTA       | R=255, G=0, B=255   |
| 6     | CYAN          | R=42, G=255, B=255  |
| 7     | WHITE         | R=255, G=255, B=255 |
| 8     | GREY          | R=170, G=170, B=170 |
| 9     | PINK          | R=255, G=170, B=170 |
| 10    | LIGHT GREEN   | R=170, G=255, B=170 |
| 11    | LIGHT YELLOW  | R=255, G=255, B=170 |
| 12    | LIGHT BLUE    | R=42, G=170, B=255  |
| 13    | LIGHT PINK    | R=255, G=170, B=255 |
| 14    | LIGHT CYAN    | R=170, G=255, B=255 |
| 15    | ORANGE        | R=255, G=170, B=42  |

## Resolution and Scaling

The original MO5 had a resolution of 320×200 pixels. This implementation scales the display to work on standard VGA modes:
- 640×480 (with a vga_translate_640x480 module)
- 1024×768 (with a vga_translate_1024x768 module)

## Implementation Details

### CPU Interface

The CPU can access the video memory through standard memory operations. The `forme` signal from the PIA determines which memory (FORME or COULEUR) is accessed. Write operations are handled by:

```vhdl
shape_wren <= '1' when vma = '1' and address(15 downto 13) = "000" and rw = '0' and forme = '1' else '0'; 
color_wren <= '1' when vma = '1' and address(15 downto 13) = "000" and rw = '0' and forme = '0' else '0';
```

### Memory Components

The implementation uses Altera's `altsyncram` megafunction configured for dual-port RAM operation:
- One port connected to the CPU for read/write
- One port connected to the video system for read-only

## FPGA Hardware Platform

This implementation targets the Terasic DE1 board with Altera Cyclone II FPGA. The main components used are:
- Built-in VGA interface with 4-bit per color DACs
- SRAM for video memory storage
- PS/2 interface for keyboard input
- Audio codec for sound output

## License

This implementation is provided for educational and historical preservation purposes.

## Credits

Based on the original Thomson MO5 hardware design (1984).
