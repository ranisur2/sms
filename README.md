# sms
School Management System

## MySQL Database Design

এই রিপোতে `schema.sql` ফাইলে multi-institution school management system-এর জন্য একটি relational database schema যোগ করা হয়েছে।

### কাভার করা মডিউল
- বহু শিক্ষা প্রতিষ্ঠান (multi-tenant প্রতিষ্ঠান)
- ব্যবহারকারী ও role ভিত্তিক অ্যাক্সেস (admin, operator, teacher, guardian, staff, student)
- শিক্ষার্থী, শিক্ষক/স্টাফ, অভিভাবক প্রোফাইল
- একাডেমিক সেশন, শিফট, ক্লাস, সেকশন, গ্রুপ
- শ্রেণিভিত্তিক বিষয় বণ্টন
- পরীক্ষা, বিষয়ভিত্তিক পরীক্ষার কাঠামো, ফলাফল
- হাজিরা সেশন ও শিক্ষার্থী হাজিরা রেকর্ড

### ফাইল
- `schema.sql`: সম্পূর্ণ DDL (CREATE TABLE + constraints + indexes)
