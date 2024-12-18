"""Fixes the taxonomy file from qiime2"""

## note: if you run this 2x or more you'll get an error since the files that are made are placed in the same directory as the unprocessed files.
import pandas as pd
import glob

files = glob.glob("./csv_files/combine/*")
print(f"found files: {files}")

for file in files:
    df = pd.read_csv(file, sep="\t", skiprows = 1)

    # split taxnonmy into multiple columns
    split_taxonomy = ["Domain", "Phylum", "Class","Order" ,"Family", "Genus","Species" ]
    df[split_taxonomy] = df["taxonomy"].str.split(";", expand=True)
    
    # remove taxnonmy column
    df.drop("taxonomy", axis=1, inplace=True)
    df.reset_index(drop=True)

    # remove d__, p__, etc.
    for column in split_taxonomy:
        df[column] = (df[column].str.split("__", expand=True)[1])

	# select only Bacteria with no mitochondira or chloroplasts
    df = df[(df.Domain.isin(["Bacteria"]))]
    df = df[ ~df["Genus"].isin(["Mitochondria", "Chloroplast"]) ]
    df = df.dropna(subset=["Genus"])

    # remove every taxnonmy column but genus
    split_taxonomy =  [taxonomy for taxonomy in split_taxonomy if taxonomy != "Genus"]
    df.drop(split_taxonomy, axis = 1, inplace=True)

    # remove OTU ID column
    df.pop("#OTU ID")

    # move genus to the front
    genus_column = df.pop("Genus")
    df.insert(0,"Genus", genus_column)

    filename = file.split("/")[-1].split(".")[0]
    df.to_csv(f'./csv_files/combine/single_{filename}.csv', index=False)

    print(f"done with file: {filename}")

print("done with all.")
