import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const List<Map<String, dynamic>> _faqs = [
    {
      'icon': Icons.info_outline_rounded,
      'question': 'What is this app?',
      'answer':
      'Our app connects you with local restaurants and home cooks in Jordan. You can browse menus, place orders, and get food delivered right to your door — fast and easy.',
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'question': 'How do I place an order?',
      'answer':
      'Browse categories or restaurants, add items to your cart, then proceed to checkout. Confirm your delivery address and payment method, and your order is on its way!',
    },
    {
      'icon': Icons.payment_outlined,
      'question': 'What payment methods are accepted?',
      'answer':
      'We currently support cash on delivery. Online payment options will be available soon.',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'question': 'How long does delivery take?',
      'answer':
      'Delivery usually takes between 20–45 minutes depending on your location and restaurant preparation time.',
    },
    {
      'icon': Icons.cancel_outlined,
      'question': 'Can I cancel my order?',
      'answer':
      'You can cancel your order within 2 minutes of placing it. After that, the restaurant has already started preparing your food.',
    },
    {
      'icon': Icons.star_outline_rounded,
      'question': 'How do I rate a restaurant?',
      'answer':
      'After your order is delivered, you will receive a prompt to rate your experience. Your feedback helps us improve the service.',
    },
    {
      'icon': Icons.lock_outline_rounded,
      'question': 'Is my personal data safe?',
      'answer':
      'Absolutely. We use secure encryption to protect your data and never share it with third parties without your consent.',
    },
    {
      'icon': Icons.headset_mic_outlined,
      'question': 'How do I contact support?',
      'answer':
      'You can reach our support team through the Contact Us section in the app, or email us at support@ourapp.jo. We respond within 24 hours.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Help & FAQs",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                      itemCount: _faqs.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final faq = _faqs[index];
                        return _FaqCard(
                          icon: faq['icon'] as IconData,
                          question: faq['question'] as String,
                          answer: faq['answer'] as String,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final IconData icon;
  final String question;
  final String answer;

  const _FaqCard({
    required this.icon,
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _iconTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _expanded
            ? const Color(0xFFFFF3DC)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded
              ? Colors.deepOrange.withOpacity(0.35)
              : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: _expanded
            ? [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.deepOrange.withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _expanded
                          ? Colors.deepOrange.withOpacity(0.12)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 19,
                      color: _expanded
                          ? Colors.deepOrange
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: _expanded
                            ? Colors.brown.shade700
                            : Colors.black87,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurn,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _expanded
                          ? Colors.deepOrange
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    widget.answer,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.65,
                      color: Colors.brown.shade400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}