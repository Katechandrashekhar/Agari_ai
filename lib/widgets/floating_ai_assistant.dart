import 'package:flutter/material.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/agriai_chat_screen.dart';

class FloatingAIAssistant extends StatefulWidget {
  const FloatingAIAssistant({super.key});

  @override
  State<FloatingAIAssistant> createState() => _FloatingAIAssistantState();
}

class _FloatingAIAssistantState extends State<FloatingAIAssistant>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isExpanded = false;
  bool _isDragging = false;
  Offset _position = const Offset(300, 500);

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _navigateToChat(Widget chatScreen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => chatScreen,
      ),
    );
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
          _pulseController.stop();
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(0.0, 
                    MediaQuery.of(context).size.width - 120),
                (_position.dy + details.delta.dy).clamp(0.0, 
                    MediaQuery.of(context).size.height - 120),
              );
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          _pulseController.repeat(reverse: true);
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isDragging ? 1.1 : _pulseAnimation.value,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(_isExpanded ? 24 : 30),
                color: Colors.transparent,
                child: Container(
                  width: _isExpanded ? 200 : 60,
                  height: _isExpanded ? 180 : 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF42A5F5),
                        Color(0xFF1E88E5),
                        Color(0xFF1565C0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_isExpanded ? 24 : 30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCollapsedView() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 28,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _toggleExpanded,
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Chat Options
          Expanded(
            child: Column(
              children: [
                _buildChatOption(
                  'AgriAI Expert',
                  'Farming advice',
                  Icons.agriculture,
                  const Color(0xFF66BB6A),
                  () => _navigateToChat(const AgriAIChatScreen()),
                ),
                const SizedBox(height: 8),
                _buildChatOption(
                  'General AI',
                  'General help',
                  Icons.chat_bubble_outline,
                  const Color(0xFFFF9800),
                  () => _navigateToChat(const AIChatScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOption(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget to add floating AI assistant to any screen
class ScreenWithFloatingAI extends StatelessWidget {
  final Widget child;
  final bool showFloatingAI;

  const ScreenWithFloatingAI({
    super.key,
    required this.child,
    this.showFloatingAI = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showFloatingAI) const FloatingAIAssistant(),
      ],
    );
  }
}