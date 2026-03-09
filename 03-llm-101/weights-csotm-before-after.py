import matplotlib.pyplot as plt
import numpy as np

# Create side-by-side comparison
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# BEFORE TRAINING - Random embeddings
vectors_before = {
    "cat": (0.8, -0.3),      # Random position
    "dog": (2.1, 2.8),       # Far from cat
    "mat": (-1.5, 2.5),      # Far from cat
    "floor": (2.8, -0.5),    # Random
    "xylophone": (0.9, -0.2) # Close to cat (wrong!)
}

# AFTER TRAINING - Learned embeddings
vectors_after = {
    "cat": (2.0, 3.0),       # Animals cluster
    "dog": (2.2, 3.1),       # Close to cat (learned!)
    "mat": (1.8, 2.9),       # Close to cat (learned association!)
    "floor": (1.9, 2.7),     # Close to surfaces
    "xylophone": (-1.5, -1.2) # Far away (learned it's unrelated!)
}

# Plot BEFORE
ax1.set_xlim(-3, 4)
ax1.set_ylim(-2, 4)
ax1.axhline(0, color='gray', linewidth=0.5)
ax1.axvline(0, color='gray', linewidth=0.5)
ax1.grid(True, alpha=0.3)

for word, (x, y) in vectors_before.items():
    color = 'red' if word in ['cat', 'xylophone'] else 'blue'
    ax1.arrow(0, 0, x, y, head_width=0.15, head_length=0.1, 
              fc=color, ec=color, alpha=0.6, linewidth=2)
    ax1.text(x, y + 0.2, word, fontsize=12, ha='center', 
             fontweight='bold' if word == 'cat' else 'normal')

# Show distance between cat and mat
cat_before = vectors_before['cat']
mat_before = vectors_before['mat']
distance_before = np.sqrt((cat_before[0] - mat_before[0])**2 + 
                          (cat_before[1] - mat_before[1])**2)
ax1.plot([cat_before[0], mat_before[0]], [cat_before[1], mat_before[1]], 
         'r--', alpha=0.5, linewidth=2)
ax1.text(-0.3, 1.0, f'cat ↔ mat\ndistance: {distance_before:.2f}', 
         fontsize=10, bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.7))

ax1.set_xlabel("Weight 1 (Dimension 1)", fontsize=11)
ax1.set_ylabel("Weight 2 (Dimension 2)", fontsize=11)
ax1.set_title("BEFORE TRAINING\n(Random Embeddings)", fontsize=13, fontweight='bold')

# Plot AFTER
ax2.set_xlim(-3, 4)
ax2.set_ylim(-2, 4)
ax2.axhline(0, color='gray', linewidth=0.5)
ax2.axvline(0, color='gray', linewidth=0.5)
ax2.grid(True, alpha=0.3)

for word, (x, y) in vectors_after.items():
    if word in ['cat', 'dog']:
        color = 'green'  # Animals
    elif word in ['mat', 'floor']:
        color = 'blue'   # Surfaces
    else:
        color = 'red'    # Unrelated
    
    ax2.arrow(0, 0, x, y, head_width=0.15, head_length=0.1, 
              fc=color, ec=color, alpha=0.6, linewidth=2)
    ax2.text(x, y + 0.2, word, fontsize=12, ha='center',
             fontweight='bold' if word == 'cat' else 'normal')

# Show distance between cat and mat (now closer!)
cat_after = vectors_after['cat']
mat_after = vectors_after['mat']
distance_after = np.sqrt((cat_after[0] - mat_after[0])**2 + 
                         (cat_after[1] - mat_after[1])**2)
ax2.plot([cat_after[0], mat_after[0]], [cat_after[1], mat_after[1]], 
         'g--', alpha=0.5, linewidth=2)
ax2.text(2.2, 2.0, f'cat ↔ mat\ndistance: {distance_after:.2f}', 
         fontsize=10, bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.7))

# Draw cluster circles
from matplotlib.patches import Circle
animal_cluster = Circle((2.1, 3.05), 0.4, color='green', fill=False, 
                        linewidth=2, linestyle='--', alpha=0.5)
surface_cluster = Circle((1.85, 2.8), 0.4, color='blue', fill=False, 
                         linewidth=2, linestyle='--', alpha=0.5)
ax2.add_patch(animal_cluster)
ax2.add_patch(surface_cluster)
ax2.text(2.1, 3.6, 'Animals', fontsize=9, ha='center', 
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
ax2.text(1.85, 2.2, 'Surfaces', fontsize=9, ha='center',
         bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.5))

ax2.set_xlabel("Weight 1 (Dimension 1)", fontsize=11)
ax2.set_ylabel("Weight 2 (Dimension 2)", fontsize=11)
ax2.set_title("AFTER TRAINING\n(Learned Patterns)", fontsize=13, fontweight='bold')

plt.suptitle('"The cat sat on the mat" - How Training Brings Related Words Together', 
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.show()

print(f"\nDistance Changes:")
print(f"cat ↔ mat BEFORE: {distance_before:.2f} (far apart)")
print(f"cat ↔ mat AFTER:  {distance_after:.2f} (close together!)")
print(f"\nImprovement: {((distance_before - distance_after) / distance_before * 100):.1f}% closer")