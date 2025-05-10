# SDDrive SD Card Setup Guide
# Guide de Préparation de Carte SD pour SDDrive

## English Instructions

### Compatible SD Cards

- microSD (up to 2GB)
- microSDHC (up to 32GB)
- microSDXC (>32GB) are NOT supported unless you create a primary partition smaller than 32GB

### Step 1: Format the SD Card

1. Format the SD card on your PC or Mac using FAT or FAT32 file system
2. Select the largest possible allocation unit size to avoid fragmentation of the root directory
3. **Important**: Formatting is essential before using the card to prevent file fragmentation. SDDrive will not work with a fragmented .sd file

### Step 2: Copy the File Selector Program

1. Download the latest version of the sddrive.sel file from [dcmoto.free.fr](http://dcmoto.free.fr/bricolage/sddrive/index.html)
2. Copy sddrive.sel to the SD card **as the first file** after formatting
3. The current recommended version is [sddrive.sel_20230708](http://dcmoto.free.fr/bricolage/sddrive/_prg/sddrive.sel_20230708.zip)
   - This version is compatible with all SDDrive controllers manufactured since 2019
   - If you're using an older controller (pre-2019), use the sddrive.sel file that came with your EPROM

### Step 3: Prepare Disk Image Files

1. Copy your Thomson disk images in .sd format to the root directory of the SD card
2. These files can be:
   - Downloaded from the Programs section of [dcmoto.free.fr](http://dcmoto.free.fr)
   - Created from .fd (floppy disk) files using the utility [FD2SD](http://dcmoto.free.fr/bricolage/sddrive/_prg/fd2sd_2014.exe)

#### Creating .sd Files from .fd Files

1. Download the FD2SD utility from [dcmoto.free.fr](http://dcmoto.free.fr/bricolage/sddrive/_prg/fd2sd_2014.exe)
2. Run the utility on your PC
3. Select your .fd file as input
4. Choose a destination for the .sd file
5. The resulting .sd file will be 2560KB in size (fixed)

#### Creating .sd Files from .k7 (Cassette) Files

Thomson cassette games can be loaded with SDDrive by either:
- Converting them to disk format
- Using a .sd format save from the dcmoto emulator

For assistance with conversion, visit the [system-cfg forum](https://forum.system-cfg.com/viewtopic.php?f=27&t=11262)

### Step 4: Structure and Limitations

1. **Root Directory Only**: SDDrive can only access files in the root directory
2. **No File Fragmentation**: Files must not be fragmented
3. **No Write Protection**: The SD card has no write protection; backup your SD card contents regularly
4. **File Limit**: Maximum 273 .sd files per card (with sddrive.sel version 2023.02.03 or newer)

### Step 5: Creating Personal Disks

To create a writable disk for your own programs and data:
1. Copy the basic-dos.sd file to your PC
2. Rename it (e.g., my_disk.sd)
3. Copy it back to your SD card
4. This disk will work with all BASIC versions as it contains the DOS and will load it automatically if needed
5. When selected, it provides 4 units (0-3) accessible for reading and writing

---

## Instructions en Français

### Cartes SD Compatibles

- microSD (jusqu'à 2 Go)
- microSDHC (jusqu'à 32 Go)
- microSDXC (>32 Go) ne sont PAS supportées sauf si vous créez une partition principale de moins de 32 Go

### Étape 1 : Formatage de la Carte SD

1. Formatez la carte SD sur PC (ou Mac) en FAT ou en FAT32
2. Choisissez la taille d'unité d'allocation la plus grande possible pour éviter le fractionnement du répertoire principal
3. **Important** : Le formatage est indispensable avant d'utiliser la carte pour éviter le fractionnement des fichiers. SDDRIVE ne fonctionne pas avec un fichier .sd fractionné

### Étape 2 : Copie du Programme de Sélection

1. Téléchargez la dernière version du fichier sddrive.sel depuis [dcmoto.free.fr](http://dcmoto.free.fr/bricolage/sddrive/index.html)
2. Copiez sddrive.sel sur la carte **en premier** après le formatage
3. La version actuelle recommandée est [sddrive.sel_20230708](http://dcmoto.free.fr/bricolage/sddrive/_prg/sddrive.sel_20230708.zip)
   - Cette version est compatible avec tous les contrôleurs SDDRIVE fabriqués depuis 2019
   - Avec les contrôleurs plus anciens (avant 2019), utilisez le fichier sddrive.sel fourni avec votre EPROM

### Étape 3 : Préparation des Images de Disquettes

1. Copiez vos images de disquettes Thomson au format .sd dans le répertoire racine de la carte SD
2. Ces fichiers peuvent être :
   - Téléchargés depuis la section Programmes du site [dcmoto.free.fr](http://dcmoto.free.fr)
   - Créés à partir de fichiers .fd (disquette) avec l'utilitaire [FD2SD](http://dcmoto.free.fr/bricolage/sddrive/_prg/fd2sd_2014.exe)

#### Création de Fichiers .sd à partir de Fichiers .fd

1. Téléchargez l'utilitaire FD2SD depuis [dcmoto.free.fr](http://dcmoto.free.fr/bricolage/sddrive/_prg/fd2sd_2014.exe)
2. Exécutez l'utilitaire sur votre PC
3. Sélectionnez votre fichier .fd comme entrée
4. Choisissez une destination pour le fichier .sd
5. Le fichier .sd résultant aura une taille de 2560 Ko (fixe)

#### Création de Fichiers .sd à partir de Fichiers .k7 (Cassette)

Les jeux Thomson sur cassette peuvent être chargés avec SDDRIVE en :
- Les convertissant au format disquette
- Utilisant une sauvegarde au format .sd de l'émulateur dcmoto

Pour obtenir de l'aide pour la conversion, visitez le [forum system-cfg](https://forum.system-cfg.com/viewtopic.php?f=27&t=11262)

### Étape 4 : Structure et Limitations

1. **Répertoire Racine Uniquement** : SDDRIVE accède uniquement au répertoire principal
2. **Pas de Fractionnement** : Les fichiers ne doivent pas être fractionnés
3. **Pas de Protection en Écriture** : La carte SD n'est pas protégée en écriture ; sauvegardez régulièrement le contenu de votre carte SD
4. **Limite de Fichiers** : Maximum 273 fichiers .sd par carte (avec sddrive.sel version 2023.02.03 ou plus récente)

### Étape 5 : Création de Disquettes Personnelles

Pour créer une disquette inscriptible pour vos propres programmes et données :
1. Copiez le fichier basic-dos.sd sur votre PC
2. Renommez-le (par exemple, ma_disquette.sd)
3. Copiez-le sur votre carte SD
4. Cette disquette fonctionnera avec tous les BASIC, car elle contient le DOS et le chargera automatiquement si nécessaire
5. Une fois sélectionnée, elle fournit 4 unités (0-3) accessibles en lecture et en écriture

## File Types / Types de Fichiers

### English

SDDrive uses two types of .sd files:

1. **Disk Image Files**:
   - Similar to .fd files, but each 256-byte sector is padded with 256 bytes of 0xFF
   - Always contains four floppy sides
   - Fixed size of 2560KB
   - Used for most applications, games, and systems

2. **Sequential Files**:
   - No file structure
   - Variable size
   - Used for streaming applications (music and video)
   - Contains a launcher program followed by data

### Français

SDDRIVE utilise deux types de fichiers .sd :

1. **Images de Disquettes** :
   - Semblable à un fichier .fd, mais chaque secteur de 256 octets est complété par 256 octets de 0xFF
   - Contient toujours quatre faces de disquettes
   - Taille fixe de 2560 Ko
   - Utilisé pour la plupart des applications, jeux et systèmes

2. **Fichiers Séquentiels** :
   - Pas de structure de fichiers
   - Taille variable
   - Utilisé pour les applications de streaming (musique et vidéo)
   - Contient généralement un programme de lancement suivi de données

## Resources / Ressources

- [SDDrive on dcmoto.free.fr](http://dcmoto.free.fr/bricolage/sddrive/index.html)
- [System-cfg Forum](https://forum.system-cfg.com/viewtopic.php?f=27&t=11262)
- [FD2SD Conversion Tool](http://dcmoto.free.fr/bricolage/sddrive/_prg/fd2sd_2014.exe)
- [SD2FD Conversion Tool](http://dcmoto.free.fr/bricolage/sddrive/_prg/sd2fd_2014.exe)
- [BASIC-DOS for MO](http://dcmoto.free.fr/bricolage/sddrive/_prg/dos-3.5_mo5.sd)
- [BASIC-DOS for TO](http://dcmoto.free.fr/bricolage/sddrive/_prg/dos-3.5_to7.sd)

---

*This guide was created for the MO5 FPGA implementation but applies to all SDDrive hardware and software implementations.*

*Ce guide a été créé pour l'implémentation FPGA du MO5 mais s'applique à toutes les implémentations matérielles et logicielles de SDDrive.*
