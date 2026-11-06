import 'package:flutter/material.dart';
import '../utils/app_color.dart';

class MbgAppBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showProfile;

  const MbgAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                )
              else
                Image.asset('assets/images/logo.png', width: 40, height: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MBG Finance',
                      style: TextStyle(
                        color: AppColor.BackgroundUtama,
                        fontFamily: 'DaysOne',
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'DaysOne',
                      ),
                    ),
                  ],
                ),
              ),
              if (showProfile)
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.BackgroundUtama,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
