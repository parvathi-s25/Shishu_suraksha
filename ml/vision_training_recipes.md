Vision Module Training Recipes

This folder contains high-level training recipes and dataset manifests for each vision sub-test.

1) Visual Acuity (level classifier)
- Task: classify whether child reads letter at each level -> output level passed
- Model: MobileNetV3-Lite backbone, input face patch 224x224
- Loss: categorical cross-entropy
- Dataset: App-collected sessions (letter_id, response_correct, device_meta)
- Augment: scale, brightness, blur, rotation
- Training: 50-100 epochs, LR schedule 1e-3 -> 1e-4, early stopping

2) Pupil Segmentation (U-Net Lite)
- Task: binary mask of pupil
- Model: U-Net Lite with depthwise separable convs
- Input: 128x128 grayscale eye crop
- Loss: Dice + BCE
- Dataset: OpenEDS, custom clinic videos
- Augment: illumination, gaussian blur, occlusions
- Export: TFLite Float16/INT8 quantized model

3) Eye Alignment (regressor / classifier)
- Task: predict symmetry deviation or binary strabismus flag
- Model: small MLP on hand-crafted features (iris centers, normalized offsets) or LightGBM
- Dataset: labeled images with alignment scores

4) Field of Vision
- Task: classify per-zone miss vs normal
- Model: Gradient Boost / LightGBM
- Dataset: app-collected touch responses with timestamps

5) Refraction Risk (regression/class)
- Task: predict risk score / diopter proxy
- Model: MobileNet features + dense regressor
- Dataset: clinic autorefraction paired with app tests

Labeling Roadmap
- Start with rule-based labels (teacher taps) to collect initial dataset.
- Clinician annotation for edge cases and to collect ground truth refraction.
- Use active learning to prioritize uncertain samples for labeling.

Licensing and sources
- OpenEDS for eye segmentation
- MPIIGaze / Columbia for gaze data
- Ishihara plates: verify licensing before distribution

*** End File