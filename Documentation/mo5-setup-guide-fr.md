# Guide d'Installation de l'Implémentation MO5 sur FPGA

## Matériel Requis

- Carte de développement DE1 avec FPGA Altera/Intel
- Clavier PS/2
- Moniteur VGA
- Carte SD
- Câble Micro USB pour la programmation
- Haut-parleurs ou écouteurs (optionnel)

## Logiciels Requis

- Quartus Prime Programmer (ou Quartus II)
- Fichier de configuration FPGA pour MO5 (.sof ou .pof)
- Image ROM du BASIC MO5
- Logiciel utilitaire pour carte SD

## Procédure d'Installation

### 1. Préparation de la Configuration FPGA

#### Utilisation du fichier .sof (Programmation Volatile)

1. Connectez votre carte DE1 à votre ordinateur via le câble USB
2. Lancez Quartus Programmer
3. Cliquez sur "Add File" et sélectionnez le fichier .sof du MO5
4. Cochez la case "Program/Configure"
5. Cliquez sur "Start" pour programmer le FPGA
6. La configuration sera perdue lors de la mise hors tension

#### Utilisation du fichier .pof (Programmation Non-volatile)

1. Connectez votre carte DE1 à votre ordinateur via le câble USB
2. Lancez Quartus Programmer
3. Configurez le mode sur "Active Serial Programming"
4. Cliquez sur "Add File" et sélectionnez le fichier .pof du MO5
5. Cochez les cases "Program/Configure" et "Verify"
6. Cliquez sur "Start" pour programmer la mémoire flash
7. La configuration persistera après les cycles d'alimentation

### 2. Configuration de la Mémoire Flash

La mémoire flash de la carte DE1 doit être programmée avec la ROM BASIC du MO5 :

1. Préparez votre image ROM du BASIC MO5 (format .bin)
2. Convertissez l'image ROM en format hex compatible si nécessaire :
   ```
   $ bin2hex basic.bin basic.hex
   ```
3. Programmez la mémoire flash avec la ROM BASIC à l'adresse correcte (soit via Quartus, soit en utilisant le programmeur flash d'Altera)
4. Vérifiez que la programmation a réussi

### 3. Préparation de la Carte SD

Selon les informations disponibles sur dcmoto.free.fr :

1. Formatez une carte SD en FAT16 ou FAT32
2. Créez une structure de répertoire correspondant à l'organisation des disques MO5 :
   ```
   SD_CARD/
   ├── MO5/
   │   ├── BASIC/
   │   ├── JEUX/
   │   └── APPLIS/
   ```
3. Téléchargez des logiciels MO5 depuis dcmoto.free.fr
4. Convertissez les logiciels au format approprié :
   - Pour les fichiers cassette (.k7), utilisez les outils de conversion mentionnés sur dcmoto.free.fr
   - Pour les images disque (.fd), extrayez-les en utilisant l'utilitaire approprié
5. Placez les fichiers convertis dans les répertoires correspondants

### 4. Connexions Physiques

1. Insérez la carte SD préparée dans le slot SD de la carte DE1
2. Connectez un clavier PS/2 au port PS/2
3. Connectez un moniteur VGA au port VGA
4. Connectez des haut-parleurs à la sortie audio (si souhaité)
5. Connectez l'alimentation à la carte DE1

### 5. Configuration du Système

Après avoir allumé la carte DE1 :

1. Définissez la disposition du clavier à l'aide des interrupteurs SW[1:0] :
   - 00 : Disposition QWERTY
   - 01 : Disposition AZERTY (Français)
   - 10/11 : Mappage direct

2. Définissez la vitesse du CPU à l'aide de l'interrupteur SW[2] :
   - 0 : 1MHz (vitesse originale du MO5)
   - 1 : 10MHz (mode accéléré)

3. Le système devrait démarrer automatiquement dans le BASIC MO5

### 6. Dépannage

- Si le système ne démarre pas, appuyez sur KEY[0] pour effectuer une réinitialisation matérielle
- Vérifiez les indicateurs LED pour l'état du système :
  - LEDG[4-5] : État du crayon optique
  - LEDR : État des interrupteurs
  - LEDG[3:0] : État des touches
- Les afficheurs 7 segments montrent l'adresse CPU actuelle pour le débogage

## Notes d'Utilisation

- Utilisez Ctrl+Alt+Suppr pour effectuer une réinitialisation logicielle
- Les commandes BASIC du MO5 devraient fonctionner comme dans le système original
- Pour accéder aux fichiers sur la carte SD, utilisez les commandes BASIC appropriées ou les utilitaires de dcmoto.free.fr
- Le système émule le matériel original du MO5 mais avec des capacités améliorées (résolution plus élevée, option CPU plus rapide, etc.)

## Ressources Supplémentaires

- dcmoto.free.fr : Source de logiciels et de documentation MO5
- Manuel de la carte DE1 : Pour les détails sur la configuration de la carte FPGA
- Manuel utilisateur MO5 : Pour des informations sur les commandes BASIC MO5 et leur utilisation

## Problèmes Courants

- Carte SD non reconnue : Assurez-vous qu'elle est correctement formatée et contient la structure de répertoire appropriée
- Clavier ne fonctionne pas : Vérifiez la connexion PS/2 et le paramètre de disposition du clavier
- Pas d'affichage : Vérifiez la connexion VGA et la compatibilité du moniteur
- Problèmes de mémoire flash : Reprogrammez la flash avec la ROM BASIC
