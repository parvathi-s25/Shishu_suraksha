import pandas as pd

file_path = r"C:\Users\Parvathi\Downloads\ECD Data sets.xlsx"
try:
    df = pd.read_excel(file_path)
    with open("dataset_info.txt", "w", encoding="utf-8") as f:
        f.write(f"Shape: {df.shape}\n\n")
        f.write("Columns:\n")
        f.write(", ".join(df.columns.tolist()) + "\n\n")
        f.write("First 5 rows:\n")
        f.write(df.head().to_string() + "\n\n")
        
        import io
        buffer = io.StringIO()
        df.info(buf=buffer)
        f.write("Info:\n")
        f.write(buffer.getvalue() + "\n\n")
        
        f.write("Missing values:\n")
        missing = df.isnull().sum()
        f.write(missing[missing > 0].to_string())
except Exception as e:
    with open("dataset_info.txt", "w", encoding="utf-8") as f:
        f.write(str(e))
