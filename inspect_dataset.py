import pandas as pd

file_path = r"C:\Users\Parvathi\Downloads\ECD Data sets.xlsx"
print("Loading dataset...")
try:
    df = pd.read_excel(file_path)
    print(f"\nDataset shape: {df.shape}")
    print("\n--- Columns ---")
    print(df.columns.tolist())
    
    print("\n--- First 5 Rows ---")
    print(df.head())
    
    print("\n--- Dataset Info ---")
    df.info()
    
    print("\n--- Missing Values ---")
    print(df.isnull().sum()[df.isnull().sum() > 0])
except Exception as e:
    print(f"Error reading file: {e}")
