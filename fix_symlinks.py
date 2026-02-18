import os
import shutil

def fix_symlinks(directory):
    for root, dirs, files in os.walk(directory):
        for name in files:
            path = os.path.join(root, name)
            # On Windows, we use os.path.islink but it might not always detect reparse points 
            # as symlinks depending on how they were created. 
            # However, os.readlink() or just checking if it can be opened and its attributes is better.
            
            # Use os.stat to check for reparse point attribute on Windows if possible,
            # but usually os.path.islink is enough for git-created symlinks.
            if os.path.islink(path):
                print(f"Fixing symlink: {path}")
                try:
                    # Read target content. 
                    # If it's a symlink created by git on Windows without symlink support enabled,
                    # it's usually a small text file containing the path. 
                    # But here the 'view_file' showed the actual XML, 
                    # so the symlink is actually working in the OS.
                    
                    target_path = os.readlink(path)
                    # If the link is relative, we need to resolve it relative to the symlink's directory
                    absolute_target = os.path.join(os.path.dirname(path), target_path)
                    
                    if os.path.exists(absolute_target):
                        if os.path.isdir(absolute_target):
                            # It's a directory link, might need different handling but usually it's files
                            print(f"Skipping directory link: {path}")
                            continue
                        
                        # Copy content from target
                        with open(absolute_target, 'rb') as f:
                            content = f.read()
                        
                        os.remove(path)
                        with open(path, 'wb') as f:
                            f.write(content)
                        print(f"  Successfully replaced with content from {target_path}")
                    else:
                        print(f"  Target does not exist: {absolute_target}")
                except Exception as e:
                    print(f"  Failed to fix {path}: {e}")

if __name__ == "__main__":
    # Also handle the case where git "symlinks" are just text files with paths
    # (common on Windows if symlinks are disabled)
    # But the 'view_file' showed XML, so they are likely real OS symlinks.
    
    # We will try a robust approach: if it's a link, resolve it.
    fix_symlinks("android")
