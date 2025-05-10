# SDDrive - SD Card Controller for Thomson Computers

This directory contains the implementation of SDDrive, a component developed by Daniel Coulom for integrating SD card functionality into Thomson computer FPGA recreations.

## Overview

SDDrive is a system designed to replace Thomson floppy disks with microSD card storage. It enables loading and saving programs, games, and educational software, similar to a floppy drive but with modern storage capabilities.

The original SDDrive hardware controller connects directly to the Thomson computer's Minibus extension port, providing a storage solution that requires no internal floppy controller. In this FPGA implementation, the same functionality is achieved through VHDL code.

## Features

- Direct replacement for the Thomson floppy disk system
- Faster operation than original floppy drives
- Continuous reading capability for streaming music and video
- Compatible with all Thomson computers except the TO9
- Support for microSD and microSDHC cards up to 32GB
- Uses standard .sd file format for disk images
- Includes both disk image and sequential file support

## Original Author

SDDrive was created by Daniel Coulom and continues to be maintained and improved by him. The original hardware and software project can be found at:

- [SDDrive on dcmoto.free.fr](http://dcmoto.free.fr/bricolage/sddrive/index.html)

## Implementation

This FPGA implementation of SDDrive includes:

- Controller logic for interfacing with microSD cards
- SPI protocol implementation for SD card communication
- ROM-based driver
- Thomson floppy controller emulation
- Logic for disk image selection and management

## Usage

The SDDrive component in this FPGA implementation functions similarly to the original hardware controller:

1. On system startup, the SD card is initialized
2. The file selector (sddrive.sel) is loaded and executed
3. Users can choose a .sd disk image file to use
4. The system emulates a Thomson floppy controller accessing the selected disk image

## File Format

SDDrive uses two types of .sd files:

1. **Disk image files**: Similar to .fd files but with each 256-byte sector padded to 512 bytes with 0xFF values. These always contain four floppy sides and have a fixed size of 2560KB.

2. **Sequential files**: No file structure and variable size. Used primarily for streaming applications (music and video) and for restoring emulator states.

## Credits

The SDDrive implementation was created by Daniel Coulom. The original project website contains extensive documentation, software, and support resources:
- Website: [http://dcmoto.free.fr/bricolage/sddrive/index.html](http://dcmoto.free.fr/bricolage/sddrive/index.html)
- Forum: [https://forum.system-cfg.com/](https://forum.system-cfg.com/)

## License

The original SDDrive code is distributed freely for non-commercial use, with the requirement that all modifications and distributions must maintain the author's references. Commercial exploitation is prohibited.

```
;**************************************************;
; S D D R I V E _ C O N T R O L                   ;
;                                                  ;
; (c) 2025 - Daniel Coulom                         ;
;                                                  ;
; http://dcmoto.free.fr/                           ;
;                                                  ;
; http://forum.system-cfg.com/                     ;
;--------------------------------------------------; 
; Ce code est distribue gratuitement dans l'espoir ;
; qu'il sera utile, mais sans aucune garantie et   ;
; sans engager la responsabilite de l'auteur.      ;
; Vous pouvez l' utiliser, le modifier et le       ;
; diffuser librement, en conservant cette licence  ;
; et les references de l'auteur dans toutes les    ;
; copies. L'exploitation commerciale est interdite.;
;**************************************************;
```

## Integration in MO5 FPGA Implementation

In this project, the SDDrive component provides SD card storage functionality for the Thomson MO5 FPGA implementation, allowing the loading of software from microSD cards instead of emulated cassettes or floppy disks.
