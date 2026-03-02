import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import models, transforms
from torch.utils.data import Dataset, DataLoader
import numpy as np
import os

# --- MOCK DATASET FOR VISUAL ACUITY ---
class MockAcuityDataset(Dataset):
    def __init__(self, num_samples=500, transform=None):
        self.num_samples = num_samples
        self.transform = transform
        
        # MOCK APP COLLECTED DATA: (level_shown, correct_or_not)
        # Represents passes (1) or fails (0) at various acuity levels (0-10)
        self.labels = torch.randint(0, 2, (num_samples,))

    def __len__(self):
        return self.num_samples

    def __getitem__(self, idx):
        # Generate a random 224x224 RGB "face patch" image representing camera data
        img = torch.rand(3, 224, 224) 
        
        label = self.labels[idx]
        return img, label

def train_model():
    print("--- Starting Visual Acuity Training Pipeline ---")
    
    # 1. Device configuration
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")

    # 2. Hyperparameters & Architecture (MobileNetV3-Lite backbone per recipe)
    num_classes = 2 # Pass or Fail at a given level
    epochs = 5 # Set low for simulation
    learning_rate = 1e-3
    
    # Load Pre-trained MobileNetV3 Small (Lite version)
    model = models.mobilenet_v3_small(weights='DEFAULT')
    # Modify the final classification layer for our binary target
    model.classifier[3] = nn.Linear(model.classifier[3].in_features, num_classes)
    model = model.to(device)

    # 3. Data Transformations (Augmentations per recipe: scale, brightness, etc)
    # Using basic RandomResizedCrop as a proxy for scale/rotation augmentations
    base_transform = transforms.Compose([
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    # 4. Load Dataset
    print("Generating App-Collected Mock Dataset...")
    train_dataset = MockAcuityDataset(num_samples=800, transform=base_transform)
    val_dataset = MockAcuityDataset(num_samples=200, transform=base_transform)
    
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False)

    # 5. Loss and Optimizer (Categorical cross-entropy equivalent)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    
    # LR Scheduler (1e-3 -> 1e-4) -> Simple StepLR for simulation
    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=2, gamma=0.1)

    print("--- Training Started ---")
    
    # 6. Training Loop
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        
        # Batch Loop
        for i, (images, labels) in enumerate(train_loader):
            images, labels = images.to(device), labels.to(device)
            
            # Forward pass
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            # Backward and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            
        # Validation Phase
        model.eval()
        val_acc = 0
        with torch.no_grad():
            correct = 0
            total = 0
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
            val_acc = 100 * correct / total

        print(f"Epoch [{epoch+1}/{epochs}], Loss: {running_loss/len(train_loader):.4f}, Val Acc: {val_acc:.2f}%")
        scheduler.step()

    # 7. Export Model
    save_path = "acuity_model.pt"
    torch.save(model.state_dict(), save_path)
    print(f"--- Training Complete. Model saved to {save_path} ---")

if __name__ == '__main__':
    train_model()
