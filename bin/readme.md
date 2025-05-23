# MO5 FPGA Implementation - Loading Instructions
# Implémentation MO5 sur FPGA - Instructions de Chargement

## English Instructions

### Loading DE1_MO5.sof (Volatile Programming)

This method programs the FPGA directly. The configuration will be lost when power is removed from the board.

1. Connect your DE1 board to your computer using the USB cable
2. Launch Quartus Programmer
3. Click "Add File" and select the `DE1_MO5.sof` file
4. Check the "Program/Configure" box
5. Click "Start" to program the FPGA
6. The MO5 system will start immediately if programming is successful

### Flashing DE1_MO5.pof (Non-volatile Programming)

This method programs the flash memory on the DE1 board. The configuration will persist across power cycles.

1. Connect your DE1 board to your computer using the USB cable
2. Launch Quartus Programmer
3. Set the programming mode to "Active Serial Programming"
4. Click "Add File" and select the `DE1_MO5.pof` file
5. Check the "Program/Configure" and "Verify" boxes
6. Click "Start" to program the flash memory
7. Wait for the programming and verification to complete
8. Power cycle the DE1 board to start the MO5 system

### Flashing the MO5 ROM (Important)

The MO5 system requires that the ROM file be properly loaded into the DE1 flash chip:

1. Locate the file `bin/DE1-FLASH.bin` in this GitHub repository
2. The file must be flashed to the DE1 flash chip using the DE1 Control Panel utility
3. This utility can be found on the Terasic DE1 CD that came with your board
4. Follow the DE1 Control Panel instructions to load the binary file to the flash chip
5. This step is essential for the MO5 system to boot properly

### Usage Notes

- The system should boot into MO5 BASIC automatically
- Set the keyboard layout using the switches SW[1:0]:
  - 00: QWERTY layout
  - 01: AZERTY (French) layout
  - 10/11: Direct mapping
- Set the CPU speed using switch SW[2]:
  - 0: 1MHz (original MO5 speed)
  - 1: 10MHz (accelerated mode)
- If the system doesn't boot, press KEY[0] to perform a hardware reset
- Use Ctrl+Alt+Del to perform a software reset

---

## Instructions en Français

### Chargement de DE1_MO5.sof (Programmation Volatile)

Cette méthode programme directement le FPGA. La configuration sera perdue lors de la mise hors tension de la carte.

1. Connectez votre carte DE1 à votre ordinateur via le câble USB
2. Lancez Quartus Programmer
3. Cliquez sur "Add File" et sélectionnez le fichier `DE1_MO5.sof`
4. Cochez la case "Program/Configure"
5. Cliquez sur "Start" pour programmer le FPGA
6. Le système MO5 démarrera immédiatement si la programmation est réussie

### Programmation Flash avec DE1_MO5.pof (Programmation Non-volatile)

Cette méthode programme la mémoire flash de la carte DE1. La configuration persistera après les cycles d'alimentation.

1. Connectez votre carte DE1 à votre ordinateur via le câble USB
2. Lancez Quartus Programmer
3. Configurez le mode sur "Active Serial Programming"
4. Cliquez sur "Add File" et sélectionnez le fichier `DE1_MO5.pof`
5. Cochez les cases "Program/Configure" et "Verify"
6. Cliquez sur "Start" pour programmer la mémoire flash
7. Attendez que la programmation et la vérification soient terminées
8. Redémarrez la carte DE1 pour lancer le système MO5

### Programmation de la ROM MO5 (Important)

Le système MO5 nécessite que le fichier ROM soit correctement chargé dans la puce flash DE1 :

1. Localisez le fichier `bin/DE1-FLASH.bin` dans ce dépôt GitHub
2. Ce fichier doit être programmé dans la puce flash DE1 en utilisant l'utilitaire DE1 Control Panel
3. Cet utilitaire se trouve sur le CD Terasic DE1 fourni avec votre carte
4. Suivez les instructions du DE1 Control Panel pour charger le fichier binaire dans la puce flash
5. Cette étape est essentielle pour que le système MO5 démarre correctement

### Notes d'Utilisation

- Le système devrait démarrer automatiquement dans le BASIC MO5
- Définissez la disposition du clavier à l'aide des interrupteurs SW[1:0] :
  - 00 : Disposition QWERTY
  - 01 : Disposition AZERTY (Français)
  - 10/11 : Mappage direct
- Définissez la vitesse du CPU à l'aide de l'interrupteur SW[2] :
  - 0 : 1MHz (vitesse originale du MO5)
  - 1 : 10MHz (mode accéléré)
- Si le système ne démarre pas, appuyez sur KEY[0] pour effectuer une réinitialisation matérielle
- Utilisez Ctrl+Alt+Suppr pour effectuer une réinitialisation logicielle

---

## Additional Resources / Ressources Supplémentaires

- [Complete MO5 FPGA Setup Guide (English)](https://github.com/6502addict/MO5-VHDL/blob/main/Documentation/MO5%20FPGA%20Setup%20Guide%20(English).pdf)
- [Guide d'Installation Complet MO5 FPGA (Français)](https://github.com/6502addict/MO5-VHDL/blob/main/Documentation/MO5%20FPGA%20Setup%20Guide%20(French).pdf)
- [Technical Manual (English)](https://github.com/6502addict/MO5-VHDL/blob/main/Documentation/MO5%20FPGA%20Technical%20Manual%20(English).pdf)
- [Manuel Technique (Français)](https://github.com/6502addict/MO5-VHDL/blob/main/Documentation/MO5%20FPGA%20Technical%20Manual%20(French).pdf)
