Dataset Manifest — Vision Module

vision_acuity:
  source: app_collected
  fields: [session_id, child_id, level_shown, correct, distance_ok, attention_ok, device_meta]
  size_target: 10000

pupil_segmentation:
  source: OpenEDS + clinic_videos
  fields: [image_id, eye_crop, pupil_mask]
  size_target: 5000

alignment:
  source: clinic_labels
  fields: [image_id, left_iris_center, right_iris_center, symmetry_score, strabismus_flag]
  size_target: 2000

field_of_vision:
  source: app_collected
  fields: [session_id, stimulus_zone, reaction_time, hit]
  size_target: 5000

refraction:
  source: clinic_autorefraction + app
  fields: [session_id, acuity_levels, blur_level, autorefraction_diopters]
  size_target: 2000

*** End File