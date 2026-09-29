import os
import glob

def fix_pubspec(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    in_env = False
    sdk_found = False
    
    for line in lines:
        # Remove existing resolution: workspace to avoid duplicates
        if 'resolution: workspace' in line:
            continue
        
        if 'environment:' in line:
            in_env = True
            new_lines.append(line)
            continue
        
        if in_env and line.strip() == '':
            in_env = False
            
        if in_env and 'sdk:' in line:
            new_lines.append("  sdk: '>=3.6.0 <4.0.0'\n  resolution: workspace\n")
            sdk_found = True
        else:
            new_lines.append(line)
            
    if not sdk_found:
        # Fallback if environment was missing or sdk not found
        # Just prepend it if necessary, but usually SDK is there
        pass

    with open(file_path, 'w') as f:
        f.writelines(new_lines)

if __name__ == "__main__":
    files = glob.glob('packages/*/pubspec.yaml')
    for f in files:
        fix_pubspec(f)
