"""
Model Accuracy Evaluation Script - Shishu Suraksha
Evaluates all trained ML models and prints accuracy metrics.
"""
import sys
import traceback

# ─────────────────────────────────────────────
# 1. K-MEANS CLUSTERING (train_model.py output)
# ─────────────────────────────────────────────
print("=" * 60)
print("MODEL 1: K-Means Clustering (ECD Child Data)")
print("=" * 60)

try:
    import pandas as pd
    import joblib
    from sklearn.metrics import silhouette_score, davies_bouldin_score
    from sklearn.preprocessing import StandardScaler

    file_path = r"C:\Users\Parvathi\Downloads\ECD Data sets.xlsx"
    df = pd.read_excel(file_path)
    features = df.drop(columns=['child_id', 'dob'])
    features_encoded = pd.get_dummies(features, columns=['gender', 'mandal', 'district', 'assessment_cycle'], drop_first=True)
    scaler = joblib.load(r"C:\Users\Parvathi\shishu_suraksha\ecd_scaler.pkl")
    features_scaled = scaler.transform(features_encoded)
    kmeans = joblib.load(r"C:\Users\Parvathi\shishu_suraksha\ecd_clustering_model.pkl")
    labels = kmeans.predict(features_scaled)

    silhouette = silhouette_score(features_scaled, labels)
    db_score   = davies_bouldin_score(features_scaled, labels)
    inertia    = kmeans.inertia_

    print(f"  Clusters         : {kmeans.n_clusters}")
    print(f"  Inertia (WCSS)   : {inertia:.2f}  (lower = tighter clusters)")
    print(f"  Silhouette Score : {silhouette:.4f}  (range -1 to 1; >0.5 = good)")
    print(f"  Davies-Bouldin   : {db_score:.4f}  (lower = better separation)")

    cluster_counts = pd.Series(labels).value_counts().sort_index()
    print(f"\n  Children per cluster:")
    for c, cnt in cluster_counts.items():
        print(f"    Cluster {c}: {cnt} children")

except Exception as e:
    print(f"  ERROR: {e}")
    traceback.print_exc()

# ─────────────────────────────────────────────
# 2. VISUAL ACUITY MODEL (MobileNetV3)
# ─────────────────────────────────────────────
print()
print("=" * 60)
print("MODEL 2: Visual Acuity CNN (MobileNetV3 - Pass/Fail)")
print("=" * 60)

try:
    import torch
    import torch.nn as nn
    from torchvision import models
    from torch.utils.data import Dataset, DataLoader

    class MockAcuityDataset(Dataset):
        def __init__(self, num_samples=300):
            self.num_samples = num_samples
            self.labels = torch.randint(0, 2, (num_samples,))
        def __len__(self): return self.num_samples
        def __getitem__(self, idx):
            return torch.rand(3, 224, 224), self.labels[idx]

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"  Device: {device}")

    model = models.mobilenet_v3_small(weights=None)
    model.classifier[3] = nn.Linear(model.classifier[3].in_features, 2)
    model.load_state_dict(torch.load("acuity_model.pt", map_location=device))
    model.to(device)
    model.eval()

    test_dataset = MockAcuityDataset(num_samples=300)
    test_loader  = DataLoader(test_dataset, batch_size=32, shuffle=False)

    correct = 0
    total   = 0
    with torch.no_grad():
        for images, labels in test_loader:
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            _, predicted = torch.max(outputs, 1)
            total   += labels.size(0)
            correct += (predicted == labels).sum().item()

    acc = 100 * correct / total
    print(f"  Test Samples     : {total}")
    print(f"  Correct          : {correct}")
    print(f"  Accuracy         : {acc:.2f}%")
    print(f"  Note: Trained on MOCK (random) data — real accuracy needs labelled images.")

except Exception as e:
    print(f"  ERROR: {e}")
    traceback.print_exc()

# ─────────────────────────────────────────────
# 3. PUPIL SEGMENTATION MODEL (U-Net Lite)
# ─────────────────────────────────────────────
print()
print("=" * 60)
print("MODEL 3: Pupil Segmentation (U-Net Lite - Dice Score)")
print("=" * 60)

try:
    import torch
    import torch.nn as nn
    sys.path.insert(0, r"C:\Users\Parvathi\shishu_suraksha\ml")
    from train_pupil import UNetLite, MockPupilDataset

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    model = UNetLite().to(device)
    model.load_state_dict(torch.load("pupil_model.pt", map_location=device))
    model.eval()

    test_dataset = MockPupilDataset(num_samples=100)
    test_loader  = DataLoader(test_dataset, batch_size=16, shuffle=False)

    total_dice = 0.0
    batches = 0
    with torch.no_grad():
        for images, masks in test_loader:
            images, masks = images.to(device), masks.to(device)
            outputs = model(images)
            outputs_flat = outputs.view(-1)
            masks_flat   = masks.view(-1)
            intersection = (outputs_flat * masks_flat).sum()
            dice = (2. * intersection + 1) / (outputs_flat.sum() + masks_flat.sum() + 1)
            total_dice += dice.item()
            batches += 1

    avg_dice = total_dice / batches
    print(f"  Test Samples     : 100 eye images")
    print(f"  Dice Score       : {avg_dice:.4f}  (range 0-1; >0.7 = acceptable, >0.85 = good)")
    print(f"  Note: Trained on MOCK data — real score needs OpenEDS/clinic images.")

except Exception as e:
    print(f"  ERROR: {e}")
    traceback.print_exc()

print()
print("=" * 60)
print("EVALUATION COMPLETE")
print("=" * 60)
