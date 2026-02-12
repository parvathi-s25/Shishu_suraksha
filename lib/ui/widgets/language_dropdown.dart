import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  final ValueChanged<String> onLanguageChanged;
  const LanguageDropdown({super.key, required this.onLanguageChanged});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String selectedLanguage = "English";
  bool isExpanded = false;

  final List<String> languages = [
    "English",
    "తెలుగు",
    "हिंदी",
    "தமிழ்",
    "മലയാളം",
    "ಕನ್ನಡ",
    "বাংলা",
    "मराठी",
    "ગુજરાતી",
    "ਪੰਜਾਬੀ",
    "ଓଡ଼ିଆ",
  ];

  void toggleDropdown() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
      isExpanded = false;
    });
    widget.onLanguageChanged(language);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownWidth = screenWidth * 0.8;

    return Center(
      child: GestureDetector(
        onTap: () {
          if (isExpanded) {
            setState(() => isExpanded = false);
          }
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: dropdownWidth.clamp(280.0, 400.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // COLLAPSED DROPDOWN HEADER
                  GestureDetector(
                    onTap: toggleDropdown,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedLanguage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // EXPANDED LANGUAGE LIST
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    height: isExpanded ? languages.length * 48.0 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isExpanded ? 1.0 : 0.0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: languages.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEFEFEF),
                            ),
                            itemBuilder: (context, index) {
                              final language = languages[index];
                              final isSelected = language == selectedLanguage;

                              return InkWell(
                                onTap: () => selectLanguage(language),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE2F4F1)
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        language,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected
                                              ? const Color(0xFF0C6C75)
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check,
                                          color: Color(0xFF0C6C75),
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
