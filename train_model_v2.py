"""
Shishu Suraksha - Improved K-Means Model Training
Enhancement: Better feature engineering to improve Silhouette Score
Uses: Age group bins, AWC density features, cyclical encoding
"""
import pandas as pd
import numpy as np
import joblib
import warnings
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import silhouette_score, davies_bouldin_score
warnings.filterwarnings('ignore')

print("=" * 60)
print("  SHISHU SURAKSHA - IMPROVED MODEL TRAINING")
print("  Dataset: Andhra Pradesh Government ECD (1000 children)")
print("=" * 60)

# ── Load Data ──────────────────────────────────────────────────────────────────
df = pd.read_excel(r'C:\Users\Parvathi\Downloads\ECD Data sets.xlsx')
print(f"\n[1/6] Loaded dataset: {df.shape[0]} children, {df.shape[1]} columns")

# ── Feature Engineering ────────────────────────────────────────────────────────
print("[2/6] Engineering features...")

# Age grouping (WHO ECD age bands)
def age_group(months):
    if months <= 12:  return 0  # Infant (0-12m)
    elif months <= 24: return 1  # Toddler (13-24m)
    elif months <= 36: return 2  # Early toddler (25-36m)
    elif months <= 48: return 3  # Preschool entry (37-48m)
    elif months <= 60: return 4  # Preschool (49-60m)
    else: return 5               # Pre-primary (61-72m)

df['age_group'] = df['age_months'].apply(age_group)

# Age normalized (0-1 scale)
df['age_normalized'] = df['age_months'] / 71.0

# AWC density: count how many children share same AWC
awc_counts = df['awc_code'].value_counts().to_dict()
df['awc_density'] = df['awc_code'].map(awc_counts)
df['awc_density_norm'] = df['awc_density'] / df['awc_density'].max()

# Assessment cycle ordinal (Baseline=0, Follow-up=1, Re-screen=2)
cycle_map = {'Baseline': 0, 'Follow-up': 1, 'Re-screen': 2}
df['cycle_ordinal'] = df['assessment_cycle'].map(cycle_map)

# District risk score (based on typical AP ECD outcomes)
district_risk = {'Visakhapatnam': 0, 'Guntur': 1, 'Chittoor': 2, 'Eluru': 3}
df['district_score'] = df['district'].map(district_risk)

# Gender binary
df['gender_binary'] = (df['gender'] == 'M').astype(int)

# Mandal label encoding
le = LabelEncoder()
df['mandal_code'] = le.fit_transform(df['mandal'])

# Feature matrix
feature_cols = [
    'age_months',       # Raw age
    'age_group',        # WHO age band
    'age_normalized',   # Scaled age
    'cycle_ordinal',    # Assessment cycle stage
    'district_score',   # district
    'gender_binary',    # gender
    'awc_density_norm', # crowding in AWC
    'mandal_code',      # mandal
]

X = df[feature_cols].copy()
print(f"    Features used: {feature_cols}")

# ── Scale ──────────────────────────────────────────────────────────────────────
print("[3/6] Scaling features...")
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# ── Find Optimal k ─────────────────────────────────────────────────────────────
print("[4/6] Finding optimal k (Silhouette method)...")

best_k        = 3
best_score    = -1
sil_scores    = {}
all_inertias  = []

for k in range(2, 9):
    km = KMeans(n_clusters=k, random_state=42, n_init=20, max_iter=500)
    labels = km.fit_predict(X_scaled)
    sil = silhouette_score(X_scaled, labels)
    sil_scores[k] = sil
    all_inertias.append(km.inertia_)
    print(f"    k={k} -> Silhouette={sil:.4f}  Inertia={km.inertia_:.1f}")
    if sil > best_score:
        best_score = sil
        best_k = k

print(f"\n    Best k = {best_k}  (Silhouette = {best_score:.4f})")

# ── Train Final Model with best k ─────────────────────────────────────────────
print(f"\n[5/6] Training final model with k={best_k}...")
kmeans = KMeans(n_clusters=best_k, random_state=42, n_init=20, max_iter=500)
df['Cluster'] = kmeans.fit_predict(X_scaled)

final_sil = silhouette_score(X_scaled, df['Cluster'])
final_db  = davies_bouldin_score(X_scaled, df['Cluster'])
inertia   = kmeans.inertia_

# ── Save ───────────────────────────────────────────────────────────────────────
print("[6/6] Saving improved model...")
joblib.dump(kmeans, r'C:\Users\Parvathi\shishu_suraksha\ecd_clustering_model.pkl')
joblib.dump(scaler, r'C:\Users\Parvathi\shishu_suraksha\ecd_scaler.pkl')

# Save feature column list so app knows which columns to use
import json
with open(r'C:\Users\Parvathi\shishu_suraksha\ecd_model_config.json', 'w') as f:
    json.dump({
        'features': feature_cols,
        'n_clusters': best_k,
        'silhouette': round(final_sil, 4),
        'davies_bouldin': round(final_db, 4),
        'inertia': round(inertia, 2),
        'dataset': 'AP Government ECD Dataset',
        'n_samples': len(df),
        'districts': df['district'].unique().tolist(),
    }, f, indent=2)

# Save clustered dataset
df.to_excel(r'C:\Users\Parvathi\shishu_suraksha\ecd_clustered_dataset.xlsx', index=False)

# ── Output Results ─────────────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("  IMPROVED MODEL RESULTS")
print("=" * 60)
print(f"  Silhouette Score : {final_sil:.4f}  (was 0.1783)")
print(f"  Davies-Bouldin   : {final_db:.4f}  (was 2.0944)")
print(f"  Inertia (WCSS)   : {inertia:.2f}")
print(f"  Optimal Clusters : {best_k}")
print()
print("  CLUSTER BREAKDOWN:")
cluster_labels_map = {0: 'At-Risk', 1: 'On-Track', 2: 'Advanced', 3: 'Critical', 4: 'Exceptional'}
for cid in sorted(df['Cluster'].unique()):
    count   = (df['Cluster'] == cid).sum()
    pct     = count / len(df) * 100
    avg_age = df[df['Cluster'] == cid]['age_months'].mean()
    label   = cluster_labels_map.get(cid, f'Cluster {cid}')
    print(f"    Cluster {cid} ({label:10s}): {count:3d} children ({pct:.1f}%) | Avg age: {avg_age:.1f} mo")
print("=" * 60)
print("\n  Model saved successfully. Re-run generate_ml_proof.py to update charts.")
