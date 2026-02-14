import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/child_model.dart';
import '../../../core/data/models/assessment_result_models.dart';
import '../../app/theme/colors.dart';

/// Assessment Flow Screen - Main entry point for child assessments
/// 
/// Displays available assessment types and guides Anganwadi worker through
/// the assessment process for a selected child.
class AssessmentFlowScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const AssessmentFlowScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<AssessmentFlowScreen> createState() => _AssessmentFlowScreenState();
}

class _AssessmentFlowScreenState extends ConsumerState<AssessmentFlowScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment - ${widget.child.name}'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        children: [
          _buildAssessmentMenu(),
          _buildMotorSkillsGuide(),
          _buildSpeechLanguageGuide(),
          _buildCognitiveGuide(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildAssessmentMenu() {
    const assessmentTypes = [
      {
        'title': 'Motor Skills',
        'description': 'Balance, coordination, jumping, walking',
        'icon': 'run',
        'color': AppColors.primary,
        'estimatedTime': '10-15 min'
      },
      {
        'title': 'Speech & Language',
        'description': 'Vocabulary, clarity, pronunciation',
        'icon': 'mic',
        'color': AppColors.secondary,
        'estimatedTime': '10-15 min'
      },
      {
        'title': 'Cognitive',
        'description': 'Memory, patterns, problem-solving',
        'icon': 'school',
        'color': AppColors.accent,
        'estimatedTime': '10-15 min'
      },
      {
        'title': 'Social-Emotional',
        'description': 'Eye contact, emotions, interactions',
        'icon': 'sentiment_satisfied',
        'color': AppColors.secondary,
        'estimatedTime': '5-10 min'
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comprehensive Development Assessment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Age: ${widget.child.dob.difference(DateTime.now()).inDays ~/ 365} years',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${_currentPage + 1} / 4 complete',
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Assessment Type:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...assessmentTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final assessment = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAssessmentCard(
                index: index,
                title: assessment['title'] as String,
                description: assessment['description'] as String,
                color: assessment['color'] as Color,
                time: assessment['estimatedTime'] as String,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard({
    required int index,
    required String title,
    required String description,
    required Color color,
    required String time,
  }) {
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForAssessment(index),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(time),
                    backgroundColor: color.withOpacity(0.2),
                  ),
                  Icon(Icons.arrow_forward, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForAssessment(int index) {
    const icons = [
      Icons.directions_run,
      Icons.mic,
      Icons.school,
      Icons.sentiment_satisfied_alt,
    ];
    return icons[index];
  }

  Widget _buildMotorSkillsGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Motor Skills Assessment', Icons.directions_run),
          _buildInstructionsCard(
            title: 'Instructions for Anganwadi Worker',
            instructions: [
              'Ensure child is in comfortable clothing',
              'Use a flat, safe surface (indoor or outdoor)',
              'Start with simple movements to warm up',
              'Record each test with phone camera if possible',
              'Encourage child with positive comments',
              'Stop immediately if child is tired or distressed',
            ],
          ),
          const SizedBox(height: 20),
          _buildTestCard(
            title: 'Test 1: Jump Test',
            description: 'Measures height, arm swing, and landing stability',
            steps: [
              '1. Ask child to stand with feet together',
              '2. Say "Jump as high as you can!"',
              '3. Note height reached and arm positioning',
              '4. Observe landing - balance and stability',
              '5. Repeat 3 times, record best attempt',
            ],
            expectedInput: 'Jump height (cm), Arm swing quality (0-100)',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 2: Balance Test',
            description: 'Single-leg stand duration and stability',
            steps: [
              '1. Ask child to stand on one leg (either leg)',
              '2. Say "Stand still like a flamingo"',
              '3. Start timer when child begins',
              '4. Count wobbles (foot touch-downs)',
              '5. Stop when child loses balance',
            ],
            expectedInput: 'Duration (seconds), Wobble count',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 3: Walk Test',
            description: 'Gait coordination and symmetry',
            steps: [
              '1. Draw or mark a straight line on ground',
              '2. Ask child to walk along the line',
              '3. Observe left-right symmetry',
              '4. Note step coordination',
              '5. Gradually increase distance',
            ],
            expectedInput: 'Gait symmetry (0-100), Coordination score (0-100)',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 4: Throw & Catch',
            description: 'Eye-hand coordination',
            steps: [
              '1. Use a soft ball or cloth ball',
              '2. Gently throw to child at chest level',
              '3. Count successful catches out of 10 attempts',
              '4. Note hand preference',
              '5. Observe eye tracking',
            ],
            expectedInput: 'Successful catches (out of 10)',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ Ready to Start?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startMotorAssessment(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Motor Assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechLanguageGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Speech & Language Assessment', Icons.mic),
          _buildInstructionsCard(
            title: 'Setup Requirements',
            instructions: [
              'Quiet room with minimal background noise',
              'Good phone microphone or external mic',
              'Have picture cards or images ready',
              'Prepare age-appropriate word lists',
              'Ensure child is comfortable and relaxed',
            ],
          ),
          const SizedBox(height: 20),
          _buildTestCard(
            title: 'Test 1: Word Clarity',
            description: 'Pronunciation and articulation',
            steps: [
              '1. Show pictures of common objects',
              '2. Ask "What is this?" for each picture',
              '3. Record child\'s responses',
              '4. Rate clarity of each word (0-100)',
              '5. Note any articulation errors',
            ],
            expectedInput: 'Word clarity scores, Number of words',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 2: Vocabulary Assessment',
            description: 'Understanding and naming words',
            steps: [
              '1. Show 15-20 picture cards',
              '2. Ask child to name each object',
              '3. If child can\'t name, ask them to point',
              '4. Count total unique words',
              '5. Note understanding vs expression',
            ],
            expectedInput: 'Vocabulary size, Vocabulary age equivalent',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 3: Sentence Formation (3+ years)',
            description: 'Grammar and syntax development',
            steps: [
              '1. Ask open-ended questions about pictures',
              '2. "Tell me about this picture"',
              '3. Record child\'s responses naturally',
              '4. Measure average sentence length',
              '5. Note grammar errors',
            ],
            expectedInput: 'Average sentence length, Grammar errors count',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ Ready to Start?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startSpeechAssessment(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Speech Assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCognitiveGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Cognitive Assessment', Icons.school),
          _buildInstructionsCard(
            title: 'Assessment Setup',
            instructions: [
              'Minimize distractions',
              'Have materials ready (shapes, colors, objects)',
              'One-on-one interaction with child',
              'Be patient and encouraging',
              'Use simple, clear instructions',
            ],
          ),
          const SizedBox(height: 20),
          _buildTestCard(
            title: 'Test 1: Memory Game',
            description: 'Short-term memory and recall',
            steps: [
              '1. Show 3-5 objects for 30 seconds',
              '2. Cover them and wait 10 seconds',
              '3. Ask child to recall what they saw',
              '4. Score based on accuracy',
              '5. Gradually increase complexity',
            ],
            expectedInput: 'Items recalled (count), Memory score (0-100)',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 2: Pattern Recognition',
            description: 'Understanding sequences and patterns',
            steps: [
              '1. Show simple patterns (colors, shapes)',
              '2. Ask child to continue the pattern',
              '3. Create gradually harder patterns',
              '4. Note problem-solving approach',
              '5. Score accuracy',
            ],
            expectedInput: 'Patterns completed, Pattern score (0-100)',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Test 3: Attention Span',
            description: 'Duration and quality of focus',
            steps: [
              '1. Give a focused task (puzzle, drawing)',
              '2. Start a timer',
              '3. Observe attention every 30 seconds',
              '4. Note distractions',
              '5. Record total duration',
            ],
            expectedInput: 'Duration (seconds), Distraction count',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              border: Border.all(color: Colors.purple),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ Ready to Start?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startCognitiveAssessment(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Cognitive Assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInstructionsCard({
    required String title,
    required List<String> instructions,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...instructions.map((instruction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        instruction,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required List<String> steps,
    required String expectedInput,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ...steps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  step,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Input: $expectedInput',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
          Text('Page ${_currentPage + 1} of 4'),
          ElevatedButton.icon(
            onPressed: _currentPage < 3
                ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _startMotorAssessment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting Motor Skills Assessment...')),
    );
    // Navigation to actual assessment screen would happen here
  }

  void _startSpeechAssessment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting Speech & Language Assessment...')),
    );
  }

  void _startCognitiveAssessment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting Cognitive Assessment...')),
    );
  }
}
