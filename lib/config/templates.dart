class JournalTemplate {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String defaultTitle;
  final String defaultContent;

  const JournalTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.defaultTitle,
    required this.defaultContent,
  });

  static const List<JournalTemplate> templates = [
    JournalTemplate(
      id: 'gratitude',
      name: 'Gratitude',
      icon: '🙏',
      description: 'What are you grateful for today?',
      defaultTitle: 'Gratitude Journal',
      defaultContent:
          'Today I am grateful for:\n\n1. \n2. \n3. \n\nOne thing that made me smile today: ',
    ),
    JournalTemplate(
      id: 'morning',
      name: 'Morning Reflection',
      icon: '🌅',
      description: 'Start your day with intention',
      defaultTitle: 'Morning Thoughts',
      defaultContent:
          'Today\'s date: \n\nHow am I feeling this morning?\n\nMy intentions for today:\n1. \n2. \n3. \n\nI am looking forward to: ',
    ),
    JournalTemplate(
      id: 'evening',
      name: 'Evening Reflection',
      icon: '🌙',
      description: 'Reflect on your day',
      defaultTitle: 'Evening Review',
      defaultContent:
          'Today was...\n\nHighlights of the day:\n\nChallenges I faced:\n\nWhat I learned today:\n\nTomorrow I want to: ',
    ),
    JournalTemplate(
      id: 'goals',
      name: 'Goals & Dreams',
      icon: '🎯',
      description: 'Track your goals and progress',
      defaultTitle: 'Goals Journal',
      defaultContent:
          'My Goal: \n\nWhy this is important to me:\n\nProgress made today:\n\nNext steps:\n\nObstacles to overcome: ',
    ),
    JournalTemplate(
      id: 'feelings',
      name: 'Emotions Check-in',
      icon: '💭',
      description: 'Explore your feelings',
      defaultTitle: 'Emotion Journal',
      defaultContent:
          'Current emotion: \n\nWhat triggered this feeling?\n\nHow is it affecting my body?\n\nWhat do I need right now?\n\nOne thing I can do to help myself: ',
    ),
    JournalTemplate(
      id: 'travel',
      name: 'Travel Memories',
      icon: '✈️',
      description: 'Document your adventures',
      defaultTitle: 'Travel Journal',
      defaultContent:
          'Location: \n\nDate: \n\nWeather: \n\nPlaces visited:\n\nFavorite moment:\n\nSomething new I learned: ',
    ),
    JournalTemplate(
      id: 'creative',
      name: 'Creative Writing',
      icon: '✨',
      description: 'Express yourself freely',
      defaultTitle: 'Creative Writing',
      defaultContent: 'Write your story here...\n\n\n\n\n\n\n\n',
    ),
    JournalTemplate(
      id: 'self_care',
      name: 'Self Care',
      icon: '💆',
      description: 'Track your wellbeing',
      defaultTitle: 'Self Care Journal',
      defaultContent:
          'How did I practice self-care today?\n\nPhysical: \n\nEmotional: \n\nMental: \n\nSocial: \n\nTomorrow I will focus on: ',
    ),
  ];

  static JournalTemplate? getById(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
