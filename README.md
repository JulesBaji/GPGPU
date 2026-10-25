# Ligne de vue sur carte de hauteur (CUDA)

Projet de programmation GPU du master Informatique ISICG (Université de Limoges, 2024).

À partir d'une carte de hauteur (image PPM) et d'un point d'observation, le programme calcule les points visibles (test de ligne de vue par tracé de segments discrets, DDA) puis une carte réduite par tuiles. Chaque calcul existe en version CPU séquentielle et en plusieurs versions GPU, chronométrées pour comparaison.

## Versions comparées

- **Test de visibilité** : CPU séquentiel, GPU naïf (un thread par point de la carte), deux versions GPU optimisées qui lancent les segments vers les points du bord.
- **Carte par tuiles** (maximum par tuile) : CPU séquentiel, GPU naïf, GPU optimisé.
- Paramètres des noyaux en **mémoire constante** (temps d'exécution divisé par 5 d'après mes mesures).

Le sujet est dans `Projet/2023_GPGPU___Projet___Ligne_de_vue.pdf`.

## Compilation et exécution

```bash
cd Projet
make
./prog
```

Nécessite le CUDA Toolkit (`nvcc`). Les résultats sont écrits en PPM dans `Projet/`.

## Technologies

CUDA, C++.
