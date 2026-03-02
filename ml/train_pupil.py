import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import numpy as np
import os

# --- MOCK DATASET FOR PUPIL SEGMENTATION ---
class MockPupilDataset(Dataset):
    def __init__(self, num_samples=500):
        self.num_samples = num_samples

    def __len__(self):
        return self.num_samples

    def __getitem__(self, idx):
        # Input: 128x128 grayscale eye crop
        img = torch.rand(1, 128, 128)
        
        # Target: 128x128 binary mask of the pupil
        # We'll just generate a random circular-ish mask for mock purposes
        mask = torch.zeros(1, 128, 128)
        center_x, center_y = 64, 64
        radius = torch.randint(10, 30, (1,)).item()
        
        # Draw a simple circle on the mask
        Y, X = torch.meshgrid(torch.arange(128), torch.arange(128), indexing='ij')
        dist = torch.sqrt((X - center_x)**2 + (Y - center_y)**2)
        mask[0][dist <= radius] = 1.0
        
        return img, mask

# --- U-NET LITE MODEL COMPONENT ---
class DepthwiseSeparableConv(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(DepthwiseSeparableConv, self).__init__()
        self.depthwise = nn.Conv2d(in_channels, in_channels, kernel_size=3, padding=1, groups=in_channels)
        self.pointwise = nn.Conv2d(in_channels, out_channels, kernel_size=1)
        self.relu = nn.ReLU(inplace=True)

    def forward(self, x):
        x = self.depthwise(x)
        x = self.pointwise(x)
        return self.relu(x)

class UNetLite(nn.Module):
    def __init__(self):
        super(UNetLite, self).__init__()
        # Encoder
        self.enc1 = DepthwiseSeparableConv(1, 16)
        self.pool1 = nn.MaxPool2d(2, 2)
        self.enc2 = DepthwiseSeparableConv(16, 32)
        self.pool2 = nn.MaxPool2d(2, 2)
        
        # Bottleneck
        self.bottleneck = DepthwiseSeparableConv(32, 64)
        
        # Decoder
        self.up1 = nn.ConvTranspose2d(64, 32, kernel_size=2, stride=2)
        self.dec1 = DepthwiseSeparableConv(64, 32) # 32 + 32 (skip)
        
        self.up2 = nn.ConvTranspose2d(32, 16, kernel_size=2, stride=2)
        self.dec2 = DepthwiseSeparableConv(32, 16) # 16 + 16 (skip)
        
        self.final = nn.Conv2d(16, 1, kernel_size=1)

    def forward(self, x):
        # Encoder
        e1 = self.enc1(x)
        p1 = self.pool1(e1)
        
        e2 = self.enc2(p1)
        p2 = self.pool2(e2)
        
        # Bottleneck
        b = self.bottleneck(p2)
        
        # Decoder
        d1 = self.up1(b)
        c1 = torch.cat([d1, e2], dim=1) # skip connection
        d1 = self.dec1(c1)
        
        d2 = self.up2(d1)
        c2 = torch.cat([d2, e1], dim=1) # skip connection
        d2 = self.dec2(c2)
        
        out = torch.sigmoid(self.final(d2))
        return out

# --- LOSS FUNCTION (Dice + BCE per recipe) ---
class DiceBCELoss(nn.Module):
    def __init__(self):
        super(DiceBCELoss, self).__init__()
        self.bce = nn.BCELoss()

    def forward(self, inputs, targets, smooth=1):
        inputs = inputs.view(-1)
        targets = targets.view(-1)
        
        intersection = (inputs * targets).sum()                            
        dice_loss = 1 - (2.*intersection + smooth)/(inputs.sum() + targets.sum() + smooth)  
        BCE = self.bce(inputs, targets)
        
        return BCE + dice_loss

def train_model():
    print("--- Starting Pupil Segmentation Training Pipeline ---")
    
    # 1. Device configuration
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")

    # 2. Hyperparameters & Architecture
    epochs = 5 
    learning_rate = 1e-3
    
    model = UNetLite().to(device)

    # 3. Load Dataset
    print("Generating Mock OpenEDS and clinic video Dataset...")
    train_dataset = MockPupilDataset(num_samples=500)
    train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)

    # 4. Loss and Optimizer
    criterion = DiceBCELoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    print("--- Training Started ---")
    
    # 5. Training Loop
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        
        # Batch Loop
        for i, (images, masks) in enumerate(train_loader):
            images, masks = images.to(device), masks.to(device)
            
            # Forward pass
            outputs = model(images)
            loss = criterion(outputs, masks)
            
            # Backward and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()

        print(f"Epoch [{epoch+1}/{epochs}], Dice+BCE Loss: {running_loss/len(train_loader):.4f}")

    # 6. Export Model
    # Next step in recipe is TFLite float16/int8, so we export to ONNX first
    # or save the raw generic PyTorch dict as asked in python.
    save_path = "pupil_model.pt"
    torch.save(model.state_dict(), save_path)
    print(f"--- Training Complete. Model saved to {save_path} ---")

if __name__ == '__main__':
    train_model()
