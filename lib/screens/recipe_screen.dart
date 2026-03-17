import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String? selectedFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildFilterButtons(),
          const SizedBox(height: 20),
          _buildRecipeList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['Tất cả', 'Dễ', 'Trung bình', 'Đủ nguyên liệu'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final filter = filters[index];
            final isSelected = selectedFilter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                backgroundColor: isSelected
                    ? const Color(0xFF22C55E)
                    : Colors.white,
                side: isSelected
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFFE5E7EB)),
                onSelected: (selected) {
                  setState(() {
                    selectedFilter = selected ? filter : null;
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildRecipeCard(
            image:
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SN4w0RadPKtOcjLJ2JJ%2Ff8fbfd30569d65e9e67f9a3814aecaf51863cc35Image%20(Ph%E1%BB%9F%20B%C3%B2).png?alt=media&token=669b5a44-5793-4316-8c6e-a5c9dfb1f7db',
            title: 'Phở Bò',
            difficulty: 'Trung bình',
            time: '45 phút',
            rating: '4.5',
          ),
          const SizedBox(height: 16),
          _buildRecipeCard(
            image:
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SN4w0RadPKtOcjLJ2JJ%2F011b601889fcc4437d98cbc0678a1ffe673f51a5Image%20(B%C3%A1nh%20M%C3%AC%20Th%E1%BB%8Bt%20N%C6%B0%E1%BB%9Bng).png?alt=media&token=dd261184-0749-4d3c-8e6f-526a9ada6c5c',
            title: 'Bánh Mì Thịt Nướng',
            difficulty: 'Dễ',
            time: '30 phút',
            rating: '4.8',
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard({
    required String image,
    required String title,
    required String difficulty,
    required String time,
    required String rating,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.speed,
                        size: 12,
                        color: Color(0xFF1F2937),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        difficulty,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFFCD34D),
                          ),
                          const SizedBox(width: 4),
                          Text(rating, style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(time, style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info,
                        size: 14,
                        color: Color(0xFFCA8A04),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Xem công thức',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFCA8A04),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
