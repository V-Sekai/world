import json
import os

with open("complete-file_names.json", "r") as file:
    completed_files = json.load(file) 
    
dirPath = r"objaverse/gltf_xmp_json_ld"  
for filename in os.listdir(dirPath): 
    filepath = os.path.join(dirPath, filename)
    if os.path.splitext(filename)[0]  in completed_files:
            print("deleting ", filepath)
            os.remove(filepath)