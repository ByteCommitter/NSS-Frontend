import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/pages/base_widget.dart'; // Import the base screen
import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _userResponses = [];
  
  // Track which options are selected for the multi-select question
  List<bool> _multiSelectChoices = [];
  
  // Questions and options for the quiz
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: "How would you describe your experience with sustainable living?",
      options: [
        "Just getting started",
        "I know the basics",
        "I'm already practicing it"
      ],
      isMultiSelect: false,
    ),
    QuizQuestion(
      question: "What motivates you more?",
      options: [
        "Mental clarity and wellness",
        "Doing my part for the planet",
        "Exploring new habits or challenges",
        "Being part of a campus community"
      ],
      isMultiSelect: false,
    ),
    QuizQuestion(
      question: "Which areas would you like help with? (Choose up to 2)",
      options: [
        "Reducing screen time",
        "Finding sustainable habits",
        "Improving my mental health",
        "Staying consistent with small tasks",
        "Joining meaningful campus events"
      ],
      isMultiSelect: true,
      maxSelections: 2,
    ),
    QuizQuestion(
      question: "Would you be open to being nudged off-screen for a while with fun real-world quests?",
      options: [
        "Yes, sounds fun!",
        "Maybe occasionally",
        "Nope, I prefer my digital space"
      ],
      isMultiSelect: false,
    ),
    QuizQuestion(
      question: "How often do you use AI tools like ChatGPT to answer questions you could explore yourself?",
      options: [
        "All the time",
        "Sometimes",
        "Rarely",
        "Never"
      ],
      isMultiSelect: false,
    ),
    QuizQuestion(
      question: "Which of these best describes your food preferences?",
      options: [
        "I eat everything, and I enjoy meat-based dishes",
        "I prefer vegetarian food, but I occasionally eat non-veg",
        "I'm fully vegetarian",
        "I'm vegan or avoid animal products",
        "I'd rather not say"
      ],
      isMultiSelect: false,
    ),
    QuizQuestion(
      question: "Would you be open to trying plant-based or less resource-intensive meals once in a while?",
      options: [
        "Sure, I'm curious",
        "Maybe, if it's easy",
        "Not really"
      ],
      isMultiSelect: false,
      isConditional: true,
      showIfCondition: (responses) {
        // Show this question only if the user selected the first option in question 6
        if (responses.length >= 6) {
          int dietaryIndex = responses[5]['answerIndex'];
          return dietaryIndex == 0;  // Changed from <= 1 to == 0
        }
        return false;
      },
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    // Initialize the multi-select choices list for the questions with the most options
    int maxOptions = _questions.fold(0, (max, question) => 
      question.options.length > max ? question.options.length : max);
    _multiSelectChoices = List.filled(maxOptions, false);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _questions.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _selectOption(int questionIndex, int optionIndex) {
    final question = _questions[questionIndex];
    
    if (question.isMultiSelect) {
      // For multi-select questions
      setState(() {
        _multiSelectChoices[optionIndex] = !_multiSelectChoices[optionIndex];
      });
    } else {
      // For single-select questions
      // Store or update the user's response
      if (_userResponses.length > questionIndex) {
        _userResponses[questionIndex] = {
          'question': question.question,
          'answer': question.options[optionIndex],
          'answerIndex': optionIndex,
        };
      } else {
        _userResponses.add({
          'question': question.question,
          'answer': question.options[optionIndex],
          'answerIndex': optionIndex,
        });
      }
      
      setState(() {});
      
      // Move to next question after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _navigateToNextQuestion(questionIndex);
      });
    }
  }
  
  void _submitMultiSelect(int questionIndex) {
    final question = _questions[questionIndex];
    
    // Get selected options
    List<String> selectedOptions = [];
    List<int> selectedIndices = [];
    
    for (int i = 0; i < question.options.length; i++) {
      if (_multiSelectChoices[i]) {
        selectedOptions.add(question.options[i]);
        selectedIndices.add(i);
      }
    }
    
    // Only proceed if at least one option is selected and not more than maxSelections
    if (selectedOptions.isNotEmpty && 
        (question.maxSelections == null || selectedOptions.length <= question.maxSelections!)) {
      
      // Store the response
      if (_userResponses.length > questionIndex) {
        _userResponses[questionIndex] = {
          'question': question.question,
          'answer': selectedOptions.join(", "),
          'answerIndices': selectedIndices,
        };
      } else {
        _userResponses.add({
          'question': question.question,
          'answer': selectedOptions.join(", "),
          'answerIndices': selectedIndices,
        });
      }
      
      // Reset selections
      setState(() {
        _multiSelectChoices = List.filled(_multiSelectChoices.length, false);
      });
      
      // Navigate to the next question
      _navigateToNextQuestion(questionIndex);
    } else if (selectedOptions.length > (question.maxSelections ?? 999)) {
      // Show error if too many options are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at most ${question.maxSelections} options'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error if no option is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one option'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _navigateToNextQuestion(int currentQuestionIndex) {
    int nextIndex = currentQuestionIndex + 1;
    
    // Skip conditional questions if their conditions are not met
    while (nextIndex < _questions.length && 
           _questions[nextIndex].isConditional && 
           !_questions[nextIndex].showIfCondition!(_userResponses)) {
      nextIndex++;
    }
    
    // Check if we've reached the end of the questions
    if (nextIndex >= _questions.length) {
      // If yes, go to the summary page
      _pageController.animateToPage(
        _questions.length + 1, // +1 for the welcome page
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Otherwise, go to the next applicable question
      _pageController.animateToPage(
        nextIndex + 1, // +1 for the welcome page
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _finishOnboarding() {
    // In a real app, you'd save these responses to a user profile or preferences
    print('User responses:');
    for (var response in _userResponses) {
      print('Q: ${response['question']}');
      print('A: ${response['answer']}');
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Profile Updated'),
        content: const Text(
          'Thank you for completing the quiz! Your responses will help us personalize your experience.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              
              // Navigate directly to the BaseScreen
              Get.offAll(() => const BaseScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue to App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: _currentPage > 0 ? AppColors.primary : Colors.grey, // Use theme color
                    ),
                    onPressed: _currentPage > 0 ? _previousPage : null,
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / (_questions.length + 2), // +2 to account for welcome and summary pages
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary), // Use theme color
                    ),
                  ),
                ],
              ),
            ),
            
            // Quiz content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Welcome page
                  _buildWelcomePage(),
                  
                  // Question pages
                  ..._questions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    QuizQuestion question = entry.value;
                    return _buildQuestionPage(idx, question);
                  }),
                  
                  // Summary page
                  _buildSummaryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use the NSS logo
          Image.asset(
            'assets/images/NSS.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 30),
          Text(
            'Welcome to NSS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Your journey to mental sustainability begins here. Let\'s personalize your experience with a quick questionnaire.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: const Text(
              'Begin Journey',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionPage(int questionIndex, QuizQuestion question) {
    final bool hasAnswered = _userResponses.length > questionIndex;
    
    if (question.isMultiSelect) {
      return _buildMultiSelectQuestionPage(questionIndex, question);
    } else {
      final int? selectedIndex = hasAnswered ? _userResponses[questionIndex]['answerIndex'] : null;
      
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${questionIndex + 1} of ${_questions.length}',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, optionIndex) {
                  final bool isSelected = selectedIndex == optionIndex;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: InkWell(
                      onTap: () => _selectOption(questionIndex, optionIndex),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.grey,
                                  width: 2,
                                ),
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                question.options[optionIndex],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _buildMultiSelectQuestionPage(int questionIndex, QuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${questionIndex + 1} of ${_questions.length}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, optionIndex) {
                final bool isSelected = _multiSelectChoices[optionIndex];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          // Always allow deselecting
                          _multiSelectChoices[optionIndex] = false;
                        } else {
                          // Check if max selections has been reached
                          int currentSelections = _multiSelectChoices.where((selected) => selected).length;
                          if (question.maxSelections == null || currentSelections < question.maxSelections!) {
                            _multiSelectChoices[optionIndex] = true;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('You can only select up to ${question.maxSelections} options'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey,
                                width: 2,
                              ),
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              question.options[optionIndex],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primary : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: ElevatedButton(
                onPressed: () => _submitMultiSelect(questionIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Use theme color
                  foregroundColor: AppColors.white, // Use theme color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Sereine logo at the top
            Image.asset(
              'assets/images/Sereine Logo with Brain and Leaf.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Journey Ready!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Thank you for sharing your preferences. Your mental sustainability journey with Sereine begins now.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            if (_userResponses.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 3),
                      blurRadius: 10,
                    )
                  ]
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Your Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ...List.generate(_userResponses.length, (index) {
                      // Skip conditional questions that weren't shown
                      if (_questions[index].isConditional && 
                          !_questions[index].showIfCondition!(_userResponses)) {
                        return const SizedBox.shrink();
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${_userResponses[index]['question']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text(
                                _userResponses[index]['answer'],
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate directly to the BaseScreen
                Get.offAll(() => const BaseScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: const Text(
                'Begin Your Journey',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final bool isMultiSelect;
  final int? maxSelections;
  final bool isConditional;
  final bool Function(List<Map<String, dynamic>>)? showIfCondition;
  
  QuizQuestion({
    required this.question,
    required this.options,
    this.isMultiSelect = false,
    this.maxSelections,
    this.isConditional = false,
    this.showIfCondition,
  });
}
