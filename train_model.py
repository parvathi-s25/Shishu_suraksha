import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import joblib

# Load the dataset
file_path = r"C:\Users\Parvathi\Downloads\ECD Data sets.xlsx"
df = pd.read_excel(file_path)
print(f"Original dataset shape: {df.shape}")

# Preprocessing
# 1. Drop columns that are unique identifiers or redundant
features = df.drop(columns=['child_id', 'dob'])

# 2. One-hot encode categorical variables
features_encoded = pd.get_dummies(features, columns=['gender', 'mandal', 'district', 'assessment_cycle'], drop_first=True)
print(f"Encoded dataset shape: {features_encoded.shape}")

# 3. Standardize the features
scaler = StandardScaler()
features_scaled = scaler.fit_transform(features_encoded)

# Train the K-Means clustering model
# We will use 3 clusters as a starting point
num_clusters = 3
print(f"Training K-Means model with {num_clusters} clusters...")
kmeans = KMeans(n_clusters=num_clusters, random_state=42, n_init=10)
df['Cluster'] = kmeans.fit_predict(features_scaled)

print("Cluster centers:")
print(kmeans.cluster_centers_)

print("\nCluster counts:")
print(df['Cluster'].value_counts())

# Save the model and scaler
model_path = r"C:\Users\Parvathi\shishu_suraksha\ecd_clustering_model.pkl"
scaler_path = r"C:\Users\Parvathi\shishu_suraksha\ecd_scaler.pkl"

joblib.dump(kmeans, model_path)
joblib.dump(scaler, scaler_path)

print(f"\nModel saved to {model_path}")
print(f"Scaler saved to {scaler_path}")

# Optionally save the clustered dataset
output_dataset = r"C:\Users\Parvathi\shishu_suraksha\ecd_clustered_dataset.xlsx"
df.to_excel(output_dataset, index=False)
print(f"Clustered dataset saved to {output_dataset}")
