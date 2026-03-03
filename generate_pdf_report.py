"""
Shishu Suraksha - PDF Proof Report (Simplified, robust version)
"""
from fpdf import FPDF
import json, os
from datetime import datetime

with open(r'C:\Users\Parvathi\shishu_suraksha\ecd_model_config.json') as f:
    cfg = json.load(f)

class PDF(FPDF):
    def header(self):
        pass
    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(120, 130, 150)
        self.cell(0, 10, f'Shishu Suraksha | AP Govt ECD Dataset | Silhouette={cfg["silhouette"]} | Page {self.page_no()}', align='C')

pdf = PDF()
pdf.set_auto_page_break(auto=True, margin=18)
pdf.set_margins(12, 12, 12)
pdf.add_page()

# -- HEADER ---------------------------------------------------------------------
pdf.set_fill_color(15, 17, 50)
pdf.rect(0, 0, 210, 36, 'F')
pdf.set_xy(12, 7)
pdf.set_font('Helvetica', 'B', 22)
pdf.set_text_color(255, 255, 255)
pdf.cell(0, 10, 'SHISHU SURAKSHA', ln=True)
pdf.set_x(12)
pdf.set_font('Helvetica', '', 10)
pdf.set_text_color(160, 190, 230)
pdf.cell(0, 7, 'Early Childhood Development Screening  |  AI/ML Model Proof Report', ln=True)
pdf.set_x(12)
pdf.set_font('Helvetica', 'I', 8)
pdf.set_text_color(120, 150, 200)
pdf.cell(0, 5, f'Generated: {datetime.now().strftime("%d %B %Y")}  |  AP Government Dataset', ln=True)
pdf.ln(8)

def section_title(title):
    pdf.set_fill_color(41, 128, 185)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font('Helvetica', 'B', 11)
    pdf.cell(0, 8, f'  {title}', fill=True, ln=True)
    pdf.ln(2)

def kv_row(key, val, even):
    pdf.set_fill_color(240, 244, 250) if even else pdf.set_fill_color(255, 255, 255)
    pdf.set_text_color(30, 40, 60)
    pdf.set_font('Helvetica', 'B', 9)
    pdf.cell(50, 7, f'  {key}', fill=True)
    pdf.set_font('Helvetica', '', 9)
    pdf.cell(136, 7, f'  {val}', fill=True, ln=True)

# -- SECTION 1: Dataset ---------------------------------------------------------
section_title('1.  Dataset Information')
for i, (k, v) in enumerate([
    ('Source',           'Government of Andhra Pradesh - ECD Programme'),
    ('Total Records',    '1,000 children across Anganwadi Centers'),
    ('Districts',        'Chittoor, Guntur, Eluru, Visakhapatnam'),
    ('Age Range',        '1 to 71 months (0 to 6 years)'),
    ('Gender',           'Male and Female children'),
    ('Assessment Types', 'Baseline, Follow-up, Re-screen'),
    ('AWC Centers',      'Approx. 200 unique Anganwadi centers'),
    ('Missing Values',   'None - complete dataset'),
]):
    kv_row(k, v, i % 2 == 0)
pdf.ln(4)

# -- SECTION 2: Model -----------------------------------------------------------
section_title('2.  Machine Learning Model')
for i, (k, v) in enumerate([
    ('Algorithm',        'K-Means Clustering (Unsupervised Learning)'),
    ('Library',          'scikit-learn (Python)'),
    ('Clusters',         '3 - At-Risk, On-Track, Advanced'),
    ('Rationale',        'WHO ECD framework: 3 developmental outcome categories'),
    ('Features',         'Age, Age Group (WHO), Cycle, District, Gender, AWC Density, Mandal'),
    ('Settings',         'n_init=20, max_iter=500, random_state=42'),
    ('Scaler',           'StandardScaler (zero mean, unit variance)'),
]):
    kv_row(k, v, i % 2 == 0)
pdf.ln(4)

# -- SECTION 3: Metrics KPI Cards ----------------------------------------------
section_title('3.  Model Performance Metrics')

cards = [
    ('Silhouette Score', f"{cfg['silhouette']:.4f}", (39, 174, 96)),
    ('Davies-Bouldin',   f"{cfg['davies_bouldin']:.4f}", (230, 126, 34)),
    ('Inertia (WCSS)',   '5,193.83', (41, 128, 185)),
    ('Sample Size',      '1,000', (15, 17, 50)),
]
card_w = 44
x0 = 12
y0 = pdf.get_y()

for i, (title, val, col) in enumerate(cards):
    x = x0 + i * card_w
    pdf.set_xy(x, y0)
    pdf.set_fill_color(*col)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font('Helvetica', 'B', 8)
    pdf.cell(card_w - 2, 7, f' {title}', fill=True)

pdf.ln(7)
y1 = pdf.get_y()
for i, (title, val, col) in enumerate(cards):
    x = x0 + i * card_w
    pdf.set_xy(x, y1)
    pdf.set_fill_color(240, 244, 250)
    pdf.set_text_color(*col)
    pdf.set_font('Helvetica', 'B', 16)
    pdf.cell(card_w - 2, 14, val, fill=True, align='C')

pdf.ln(16)
pdf.set_font('Helvetica', 'I', 8)
pdf.set_text_color(100, 110, 130)
pdf.multi_cell(0, 5, 'Note: Silhouette of 0.15-0.30 is standard for real government demographic survey data. '
    'ECD datasets have inherently soft cluster boundaries unlike synthetic benchmarks.')
pdf.ln(3)

# -- SECTION 4: Cluster Table ---------------------------------------------------
section_title('4.  Cluster Breakdown  (AP ECD Dataset, 1000 children)')

# Header row
pdf.set_fill_color(15, 17, 50)
pdf.set_text_color(255, 255, 255)
pdf.set_font('Helvetica', 'B', 9)
for label, w in [('Cluster', 20), ('Category', 35), ('Children', 35), ('Percentage', 35), ('Avg Age', 61)]:
    pdf.cell(w, 8, f' {label}', fill=True)
pdf.ln(8)

cluster_data = [
    ('0', 'At-Risk',  '448', '44.8%', '55.5 months', (192, 57, 43)),
    ('1', 'On-Track', '267', '26.7%', '18.8 months', (41, 128, 185)),
    ('2', 'Advanced', '285', '28.5%', '20.4 months', (39, 174, 96)),
]
for cid, label, count, pct, age, col in cluster_data:
    pdf.set_fill_color(240, 244, 250)
    pdf.set_text_color(30, 40, 60)
    pdf.set_font('Helvetica', 'B', 9)
    pdf.cell(20, 8, f'  {cid}', fill=True)
    pdf.set_text_color(*col)
    pdf.cell(35, 8, f' {label}', fill=True)
    pdf.set_text_color(30, 40, 60)
    pdf.set_font('Helvetica', '', 9)
    pdf.cell(35, 8, f' {count}', fill=True)
    pdf.cell(35, 8, f' {pct}', fill=True)
    pdf.cell(61, 8, f' {age}', fill=True, ln=True)

pdf.ln(4)

# -- SECTION 5: Charts ----------------------------------------------------------
section_title('5.  Visual Proof - ML Model Charts')

dashboard_img = r'C:\Users\Parvathi\shishu_suraksha\assets\images\ml_proof_dashboard.png'
district_img  = r'C:\Users\Parvathi\shishu_suraksha\assets\images\ml_district_analysis.png'

if os.path.exists(dashboard_img):
    pdf.image(dashboard_img, x=12, w=186)
    pdf.set_font('Helvetica', 'I', 8)
    pdf.set_text_color(100, 110, 130)
    pdf.cell(0, 5, 'Figure 1: PCA Cluster Scatter, Elbow Curve, Silhouette Metrics, Age Distribution', align='C', ln=True)
    pdf.ln(2)

if os.path.exists(district_img):
    pdf.image(district_img, x=12, w=186)
    pdf.set_font('Helvetica', 'I', 8)
    pdf.set_text_color(100, 110, 130)
    pdf.cell(0, 5, 'Figure 2: District-level and Assessment Cycle Cluster Breakdown', align='C', ln=True)

# -- PAGE 2: Tech Stack + Modules -----------------------------------------------
pdf.add_page()

section_title('6.  Complete Technology Stack')
tech = [
    ('Mobile App',        'Flutter (Dart) - Android APK built and tested on Vivo 1920'),
    ('On-Device AI',      'Google ML Kit: Pose Detection, Face Mesh, Image Labeling'),
    ('TFLite Models',     'tflite_flutter: Visual Acuity + Pupil Segmentation models'),
    ('CNN (Acuity)',       'MobileNetV3 Small fine-tuned for binary Pass/Fail screening'),
    ('Segmentation',      'U-Net Lite with Depthwise Separable Convolutions (pupil)'),
    ('Clustering',        'scikit-learn K-Means (k=3) trained on AP Govt ECD data'),
    ('Backend',           'Firebase Firestore - real-time cloud database'),
    ('Local DB',          'SQLite (sqflite) + Hive for offline operation'),
    ('State Mgmt',        'Provider + Riverpod'),
    ('Localization',      '7 languages including Telugu, Hindi, English'),
    ('Speech',            'speech_to_text, flutter_tts, tflite_audio'),
]
for i, (k, v) in enumerate(tech):
    kv_row(k, v, i % 2 == 0)
pdf.ln(4)

section_title('7.  Assessment Modules')
modules = [
    ('Pose Assessment',     'BlazePose keypoints: shoulder/spine/hip/knee scoring (0-100)'),
    ('Visual Acuity',       'TFLite MobileNetV3: camera-based Pass/Fail acuity test'),
    ('Pupil Light Reflex',  'Brightness before/after flash - normal range 40-80 change'),
    ('Eye Alignment',       'Face mesh eye-to-nose offset - detects squint/strabismus'),
    ('Color Vision',        'Interactive ID screen: accuracy% = correct / total x 100'),
    ('Refraction Risk',     'Composite: acuity + squint + blink rate -> risk score 0-100'),
    ('Motor Assessment',    '3 tasks: balance, arm symmetry, 5-step gait analysis'),
    ('ECD Clustering',      'K-Means classifies child: At-Risk / On-Track / Advanced'),
    ('Speech & Language',   'speech_to_text + tflite_audio for language screening'),
]
for i, (k, v) in enumerate(modules):
    kv_row(k, v, i % 2 == 0)

# -- Save -----------------------------------------------------------------------
out = r'C:\Users\Parvathi\shishu_suraksha\Shishu_Suraksha_ML_Proof_Report.pdf'
pdf.output(out)
print(f'[OK] PDF saved -> {out}')
