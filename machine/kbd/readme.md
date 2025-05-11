# Thomson MO5 Keyboard Implementation for FPGA

This document describes the implementation of keyboard support for the Thomson MO5 computer FPGA recreation. The original MO5 used a key matrix system connected to a Motorola 6821 PIA (Peripheral Interface Adapter), while this FPGA implementation interfaces a modern PS/2 keyboard with the emulated system.

## Original MO5 Keyboard Architecture

The Thomson MO5 used an 8×8 key matrix (though not all positions were utilized) wired to a 6821 PIA. The keyboard was scanned by:

1. Setting row and column selection outputs through the PIA port B (PBIA)
2. Reading the keyboard state from a single input line on PIA port B (PB7)

The keyboard matrix was organized as follows:
- Rows were selected using PB1-PB3 (3 bits)
- Columns were selected using PB4-PB6 (3 bits)
- The key state was read on PB7 (active low, '0' = pressed)

## FPGA Implementation Overview

The FPGA implementation creates a virtual keyboard matrix that is filled based on PS/2 keyboard input. This allows modern keyboards to be connected to the MO5 emulation.

The implementation consists of several components:

1. **PS/2 Interface** (`ps2.vhd`): Handles the low-level PS/2 protocol
2. **PS/2 Assembler** (`ps2_assembler.vhd`): Processes raw PS/2 scancodes into a more usable format
3. **Keyboard Decoder** (`mo5_decode.vhd`): Maps PS/2 key events to the MO5 keyboard matrix
4. **Keyboard Mapping Tables** (`mo5_qwerty_kbd.vhd`, `mo5_azerty_kbd.vhd`, `mo5_null_kbd.vhd`): Define the mapping from PS/2 scancodes to MO5 matrix positions

## Component Details

### 1. PS/2 Interface (`ps2.vhd`)

The PS/2 interface handles the low-level PS/2 protocol, including:
- Clocking and data synchronization
- Bit-by-bit reception of PS/2 scancodes
- Parity checking
- Providing complete 8-bit scancodes along with a strobe signal

Notable features:
- Uses edge detection to identify PS/2 clock transitions
- Handles synchronization between the PS/2 clock domain and system clock
- Provides clean scan codes with a strobe signal to indicate new data

### 2. PS/2 Assembler (`ps2_assembler.vhd`)

The PS/2 Assembler component enhances raw PS/2 scancodes by handling:
- Extended keys that use the E0 prefix
- Break codes that use the F0 prefix
- Generating a 10-bit "extended scancode" that contains:
  * 8 bits for the PS/2 scancode
  * 1 bit to indicate if the key is extended (E0 prefix)
  * 1 bit to indicate if it's a break code (F0 prefix)

The resulting output is a 10-bit `escan_code` where:
- bit 9: Break/Make flag ('1' = break/release, '0' = make/press)
- bit 8: Extended flag ('1' = extended key, '0' = standard key)
- bits 7-0: The actual PS/2 scancode

### 3. Keyboard Decoder (`mo5_decode.vhd`)

The Keyboard Decoder is the core component that:
- Receives extended scancodes from the PS/2 Assembler
- Maintains the state of all keys, including shift and accent states
- Handles special cases and key combinations
- Maps PS/2 keys to the correct MO5 keyboard matrix positions
- Generates the MO5 matrix output requested by the PIA

Key features:
- Supports multiple keyboard layouts (QWERTY, AZERTY, or raw 1:1 mapping)
- Automatically handles accent keys for direct character mapping (e.g., pressing 'é' on an AZERTY keyboard)
- Manages the shift state differences between PS/2 and MO5 keyboards
- Emulates the timing required for proper MO5 key recognition
- Implements a state machine for complex key sequences
- Provides Ctrl+Alt+Del reset functionality

### 4. Keyboard Mapping Tables

Three different mapping tables are implemented:

1. **QWERTY Mapping** (`mo5_qwerty_kbd.vhd`): Maps a standard QWERTY keyboard to the MO5
2. **AZERTY Mapping** (`mo5_azerty_kbd.vhd`): Maps a French AZERTY keyboard to the MO5
3. **Null Mapping** (`mo5_null_kbd.vhd`): Provides a simple 1:1 mapping for debugging

Each mapping table defines a lookup system that converts:
- PS/2 scancode
- Extended flag
- Shift state
into:
- MO5 matrix position (row and column)
- Required shift state for MO5
- Required accent state for MO5

## Key Processing Flow

1. PS/2 physical interface receives keyboard signals (clk & data)
2. `ps2.vhd` decodes raw scancodes and generates a strobe signal
3. `ps2_assembler.vhd` processes special prefix codes (E0, F0) into an extended scancode
4. `mo5_decode.vhd` receives the extended scancode and updates internal key state
5. Based on the selected keyboard mode (QWERTY/AZERTY), the appropriate mapping table is used
6. The mapping provides MO5 matrix position and required shift/accent states
7. The decoder updates a virtual 64-bit MO5 keyboard matrix
8. When the MO5 PIA scans the keyboard, the decoder returns the requested matrix position state

## Special Features

### Automatic Accent Handling

The MO5 used a two-key sequence for accented characters:
1. Press the ACC key
2. Press the character key

This implementation automatically handles this sequence when an accented character is pressed on the PS/2 keyboard. For example, when pressing 'é' on an AZERTY keyboard:

1. The decoder identifies this as an accented character
2. It virtually presses and releases the MO5 ACC key
3. It then virtually presses the base character key
4. This produces the correct accented character on the MO5

### Shift State Management

Some keys are shifted on the PS/2 keyboard but unshifted on the MO5 (and vice versa). The decoder handles these cases by automatically pressing or releasing the virtual shift key as needed.

### MO5 Keyboard Matrix

The MO5 keyboard matrix is laid out as follows:

```
     0     1     2     3     4     5     6     7
   +-----+-----+-----+-----+-----+-----+-----+-----+
0  |SHIFT|BASIC|  W  |SPACE|  @  |  .  |  ,  |  N  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
1  | UP  | LEFT|  C  | RAZ | ENT | CNT | ACC | STOP|
   +-----+-----+-----+-----+-----+-----+-----+-----+
2  |  X  | LEFT|  V  |  Q  |  *  |  A  |  +  |  1  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
3  |     | DOWN|  B  |  S  |  /  |  Z  |  -  |  2  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
4  |     |RIGHT|  M  |  D  |  P  |  E  |  0  |  3  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
5  |     |MERGE|  L  |  F  |  O  |  R  |  9  |  4  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
6  |     | INS |  K  |  G  |  I  |  T  |  8  |  5  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
7  |     | EFF |  J  |  H  |  U  |  Y  |  7  |  6  |
   +-----+-----+-----+-----+-----+-----+-----+-----+
```

## Implementation Details

### State Machine

The keyboard decoder uses a complex state machine to handle key events and special sequences. The main states include:

1. **KBD_IDLE**: Waiting for key events
2. **KBD_FETCH**: Fetching the mapping data for a key
3. **KBD_PROCESS**: Determining the action needed for this key
4. **KBD_SHIFT_PREPARE**: Preparing to change shift state
5. **KBD_SHIFT_DELAY**: Adding delay for proper shift handling
6. **KBD_KEY_SET**: Setting the key state in the matrix
7. **KBD_KEY_HOLD**: Holding the key state for proper timing
8. **KBD_ACC_SET**: Special handling for accented characters
9. **KBD_END**: Completing the key processing cycle

### Keyboard Selection

The implementation supports switching between keyboard layouts via the `mode` input:
- `00`: QWERTY layout
- `01`: AZERTY layout
- Other values: Raw 1:1 mapping

### Key Translation Function

The core of the mapping system uses the `ps2_index` function that creates a lookup index based on:
```vhdl
function ps2_index(code: integer; ext, shift: std_logic) return integer is
    variable result : integer := code;
begin
    if ext   = '1' then result := result + 16#90#; end if;
    if shift = '1' then result := result + 2**8;   end if;
    return result;
end function;
```

This function allows the mapping tables to define different behaviors for:
- Standard vs. extended keys
- Shifted vs. unshifted keys

## Integration with MO5 System

The keyboard component integrates with the MO5 system through the PIA interface:
- The PIA sets row and column selection lines (KB_ROW, KB_COL)
- The keyboard component returns the key state (KBD_DATA)
- The reset signal can be triggered by Ctrl+Alt+Del

## Conclusion

This keyboard implementation creates a seamless bridge between modern PS/2 keyboards and the vintage MO5 computer system. By virtualizing the keyboard matrix and handling the differences in keyboard layouts and special keys, it provides a natural typing experience that matches the original system's behavior while supporting modern input devices.
