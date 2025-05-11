# Thomson MO5 PIA Implementation for FPGA

This document describes the implementation of the Peripheral Interface Adapter (PIA) for the Thomson MO5 computer FPGA recreation. The Motorola 6821 PIA was a critical component in the original MO5, handling most of the I/O functions including keyboard scanning, sound generation, and system control.

## Original MO5 PIA Architecture

In the original Thomson MO5, the Motorola 6821 PIA served as the primary interface between the CPU and the external world:

- Located at address $A7C0-$A7C3 in the memory map
- Two 8-bit bidirectional I/O ports (Port A and Port B)
- Four control lines (CA1, CA2, CB1, CB2)
- Support for both polling and interrupt-driven I/O
- Generated IRQ and FIRQ signals to the CPU

The PIA handled various functions in the MO5:
- Keyboard matrix scanning
- Video mode control (including the "FORME" signal)
- Border color selection
- Sound output
- Light pen control
- Tape drive motor and data management
- Video incrustation control
- System synchronization (via SYNLT signal)

## FPGA Implementation Overview

The FPGA implementation faithfully recreates the functionality of the Motorola 6821 PIA, with the same interface to the CPU and external devices. The implementation consists of several components:

1. **MO5_PIA** (`MO5_PIA.vhd`): Top-level PIA module that interfaces with the MO5 system
2. **MC6821** (`mc6821.vhd`): Core PIA functionality implementing the 6821 specification
3. **MC6821_PAR** (`mc6821_par.vhd`): Parallel port implementation for Port A and Port B
4. **MC6821_CTL** (`mc6821_ctl.vhd`): Control line management and interrupt generation

## Implemented and Unsupported Features

### Fully Implemented Features:
- Keyboard interface
- Sound generation
- Video mode control (FORME signal)
- Border color selection
- Interrupt generation (IRQ and FIRQ)

### Currently Unsupported Features:
- **Tape Drive**: The cassette tape interface is not yet implemented. While the PIA signals for the tape motor control and data I/O are defined in the code, they are not connected to actual tape drive emulation.
- **Light Pen**: Although the light pen signals are defined in the PIA interface, the light pen functionality is not currently operational. The code includes placeholders for light pen button detection and position input/output signals, but they are not connected to actual light pen functionality.
- **Video Incrustation**: The video incrustation feature (CB2 signal) is defined in the interface but not functionally implemented. This feature was used in the original MO5 to mix external video with the computer's output.

These features may be implemented in future updates to the FPGA recreation.

## Component Details

### 1. MO5_PIA Module

The `MO5_PIA` module serves as the top-level wrapper that connects the 6821 PIA to the specific MO5 peripherals:

Key interfaces:
- CPU connections (address, data_in, data_out, rw, cs_n, etc.)
- Interrupt signals (irq_n, firq_n)
- Video control signals (border_color, forme)
- Keyboard interface (kbd_row, kbd_col, kbd_data)
- Sound output (sound)
- Light pen signals (lep_in, lep_out, lep_mtr) - currently placeholders
- System timing (synlt_clock)
- Incrustation control (incrust) - currently a placeholder

The module handles the mapping between generic PIA signals and MO5-specific peripherals.

### 2. MC6821 Module

The `mc6821` module implements the core 6821 PIA functionality:

Key features:
- Full implementation of both Port A and Port B with data direction registers
- Control registers for both ports
- Interrupt control logic
- Support for all PIA operating modes

Implementation details:
- Separates parallel port functionality and control line handling into submodules
- Integrates these submodules into a complete PIA implementation
- Provides the same register interface as the original 6821

### 3. MC6821_PAR Module

The `mc6821_par` module handles one 8-bit parallel port of the PIA:

Key features:
- 8-bit data direction register (DDR) to configure each bit as input or output
- 8-bit output register for data written by the CPU
- Input buffering for data read by the CPU
- Control register handling

Implementation details:
- Manages the data direction register (DDR) to control pin direction
- Implements the read/write logic for both the DDR and data registers
- Handles the multiplexing of input and output data based on pin direction

### 4. MC6821_CTL Module

The `mc6821_ctl` module manages the control lines and interrupt generation:

Key features:
- Control line (C1, C2) edge detection
- Interrupt flag management
- Configurable operating modes for the control lines
- Generation of interrupt requests

Implementation details:
- Supports different edge detection modes (rising or falling edge)
- Manages interrupt flags based on control line activity
- Implements the control register bits that determine operating mode
- Generates interrupt signals based on flag status and control register settings

## PIA Functionality in the MO5 System

### Keyboard Interface

The PIA handles the keyboard matrix scanning:

```vhdl
-- Port B bits 1-3 select the keyboard row
kbd_row <= pb_out(3 downto 1) when ddrb(3 downto 1) = "111" else (others => '0');

-- Port B bits 4-6 select the keyboard column  
kbd_col <= pb_out(6 downto 4) when ddrb(6 downto 4) = "111" else (others => '0');

-- Port B bit 7 reads the keyboard data
pb_in(7) <= kbd_data;
```

The CPU selects a specific row and column in the keyboard matrix and reads the key state through bit 7 of Port B.

### Video Control

The PIA manages key video control signals:

```vhdl
-- Port A bit 0 controls the FORME (shape/color) signal
forme <= pa_out(0) when ddra(0) = '1' else '0';

-- Port A bits 1-4 control the border color
border_color <= pa_out(4 downto 1) when ddra(4 downto 1) = "1111" else (others => '0');
```

The FORME signal selects between displaying pixel data (shape) or color data, while the border color bits determine the color of the screen border.

### Sound Generation

The PIA produces the 1-bit sound output:

```vhdl
-- Port B bit 0 generates the sound signal
sound <= pb_out(0) when ddrb(0) = '1' else '0';
```

The CPU creates sound by toggling this bit at specific frequencies.

### Light Pen Control (Placeholders)

The PIA includes placeholders for the light pen interface:

```vhdl
-- Port A bit 5 reads the light pen button (not functional)
pa_in(5) <= lightpen_btn;

-- Port A bit 7 reads the light pen input (not functional)
pa_in(7) <= lep_in;

-- Port A bit 6 controls the light pen output (not functional) 
lep_out <= pa_out(6) when ddra(6) = '1' else '0';

-- Control line CA2 controls the light pen motor (not functional)
lep_mtr <= ca2_out when ca2_oe = '1' else '0';
```

These signals are defined but not connected to actual light pen functionality.

### System Synchronization

The PIA synchronizes with the system timing:

```vhdl
-- Control line CB1 receives the SYNLT clock
cb1 <= synlt_clock;
```

The 50Hz SYNLT signal is used for timing and synchronization purposes.

### Video Incrustation (Placeholder)

The control line CB2 is defined for video incrustation, but not functionally implemented:

```vhdl
-- Control line CB2 controls incrustation (not functional)
incrust <= cb2_out when cb2_oe = '1' else '0';
```

## PIA Register Map

The MO5 PIA occupies four consecutive memory addresses:

| Address | Register when CR(2)=0 | Register when CR(2)=1 |
|---------|----------------------|----------------------|
| $A7C0   | Port A DDR           | Port A Data          |
| $A7C1   | Port A CR            | Port A CR            |
| $A7C2   | Port B DDR           | Port B Data          |
| $A7C3   | Port B CR            | Port B CR            |

CR = Control Register
DDR = Data Direction Register

## Interrupt Handling

The PIA can generate two types of interrupts:

1. **IRQ**: Generated by Port B control lines
2. **FIRQ**: Generated by Port A control lines

```vhdl
-- Connect interrupt outputs
irqa_n => firq_n,  -- Port A interrupt goes to FIRQ
irqb_n => irq_n    -- Port B interrupt goes to IRQ
```

The interrupts are used for events like keyboard scanning and system timing.

## Integration with MO5 System

The PIA integrates with the rest of the MO5 system through:

1. Connection to the CPU address and data bus
2. Keyboard matrix interface
3. Video control signals
4. Sound output
5. Interrupt generation
6. Light pen interface (placeholder)
7. System timing synchronization
8. Tape drive control (placeholder)
9. Incrustation control (placeholder)

## Technical Implementation Details

### Register Access Logic

The PIA implements proper register selection based on address lines and the control register state:

```vhdl
-- Register selection based on address lines
rs(0) <= address(1);
rs(1) <= address(0);
```

Note that in the Thomson MO5, the address lines are wired in the opposite order from what might be expected.

### Data Direction Control

The data direction register controls whether each pin is an input or output:

```vhdl
for i in 0 to 7 loop
    if ddr_reg(i) = '0' then
        port_read(i) <= port_in(i);  -- Input
    else
        port_read(i) <= output_reg(i);  -- Output
    end if;
end loop;
```

This allows dynamic configuration of each pin's direction.

### Control Register Functions

The control register bits determine various aspects of PIA operation:

- Bit 0: IRQ1 enable
- Bit 1: IRQ1 trigger polarity
- Bit 2: DDR/Data register selection
- Bit 3: Control line 2 function
- Bit 4: Control line 2 edge select
- Bit 5: Control line 2 direction
- Bit 6: IRQ2 enable
- Bit 7: IRQ2 trigger polarity

## Future Enhancements

Future versions of the FPGA implementation may include:

1. **Tape Drive Emulation**: Full emulation of the MO5 cassette interface, allowing loading and saving of programs from virtual cassettes.

2. **Light Pen Support**: Implementation of the light pen functionality, either through emulation or by interfacing with physical light pen hardware.

3. **Video Incrustation**: Emulation of the video mixing capabilities of the original MO5.

## Conclusion

This PIA implementation faithfully recreates the core functionality of the Motorola 6821 PIA as used in the Thomson MO5 computer. While some peripheral features (tape drive, light pen, and incrustation) are not yet fully implemented, the keyboard interface, sound generation, video control, and interrupt handling are fully operational.

The modular design with separate components for parallel ports and control lines makes the implementation both maintainable and accurate. The hierarchical structure allows for clear separation of concerns while ensuring that all aspects of the original PIA functionality are properly represented, with room for future enhancements to complete the peripheral support.
